class CheckoutController < CurrentUserController
  DEBUG = (RAILS_ENV != "production")

  def start
    @order = Order.shopping.find(:first, :conditions => [ "id = ?", session[:order_id] ])
    if @order.nil? or @order.empty? or (@order.user and @order.user != @user)
      raise t('checkout.common.failed_msg')
    end
    @order.update_attributes( {:user => @user }) if @order.user.nil?
    @order.build_billing_address if @order.billing_address.nil?
    @order.build_shipping_address if @order.shipping_address.nil?
  rescue Exception => e
    flash[:notice] = e
    redirect_to cart_url
  end

  def update_address
    raise t('checkout.common.failed_msg') unless request.put?
    @order = Order.shopping.by_user(@user).find(:first, :conditions => [ "id = ?", session[:order_id] ])
    if @order.update_attributes(params[:order])
        prepare_order_for_checkout(@order)
        flash[:notice] = t('checkout.update_address.success_msg')
        redirect_to :action => 'payment'
    else
      render :action => "start"
    end
  rescue Exception => e
    flash[:notice] = e
    redirect_to cart_url
  end

  def payment
    @order = Order.not_checked_out.by_state("assigned").by_user(@user).
                find(:first, :conditions => [ "id = ?", session[:order_id] ])
    raise t('checkout.common.failed_msg') unless ( @order and @order.can_pay?)
    prepare_order_for_checkout(@order)
    unless @order.total > 0.0
        @order.update_attributes( {:note => t('checkout.common.payment_not_required_msg') })
        @order.pay!
        @order.ship!
        flash[:notice] = t('checkout.payment.no_payment_msg')
        redirect_to order_path(@order.order_num)
    end
  rescue Exception => e
    flash[:notice] = e
    redirect_to cart_url
  end

  # start paypal express checkout
  def pay_ec
    raise t('checkout.common.failed_msg') unless request.put?
    order = Order.not_checked_out.by_state("assigned").by_user(@user).
                find(:first, :conditions => [ "id = ?", session[:order_id] ])
    if order.can_pay? and order.total > 0.0
      clear_session_data
      serverURL = get_server_path
      order.update_attributes( {:recipient => @user.full_description })
      order.reset_token!

      options = { "method"           => 'SetExpressCheckout',
                  "allownote"        => '0',
                  "buyeremail"       => @user.email,
                  "paymentaction"    => 'Sale',        #  Sale | Authorization | Order
                  "localecode"       => 'HK',          #  e.g. AU FR IT GB US HK CN
      }
      options.merge!(order.set_ec_options)

      cancelURL="#{serverURL}/checkout/payment"
      returnURL="#{serverURL}/checkout/review/#{order.token}?locale=#{I18n.locale}"
      options.merge!({ "cancelurl" => cancelURL,
                       "returnurl" => returnURL  })
      dump_options(options)                                             if DEBUG
      order.payments.create({ "token" => "#{order.token}", "state" => "pending",
            "method_type" => "PayPal", "set_ec_request_params" => options})
      payment = order.current_payment
      caller = PayPalSDK::Caller.new(false)
      @transaction = caller.call( options )
      payment.update_attributes({"set_ec_response_params" => @transaction.response})
      dump_response(@transaction.response, "SetExpressCheckout")        if DEBUG
      if @transaction.success?
        session[:pp_errors] = nil
        token = @transaction.response["TOKEN"].to_s
        redirect_to(PAYPAL_EC_URL + token)
      else
        session[:pp_errors] = @transaction.response
        flash[:notice] = "SetExpressCheckout Failed: " + session[:pp_errors]["L_LONGMESSAGE0"].to_s
        redirect_to payment_url
      end
    else
      raise t('checkout.common.failed_msg')
    end
  rescue Exception => e
    flash[:notice] = e
    redirect_to payment_url
  end


  def review
    raise t('checkout.common.failed_msg') unless (params[:id] and params[:token] and params[:PayerID])
    @order = Order.not_checked_out.by_state("assigned").by_user(@user).by_token(params[:id]).
                find(:first, :conditions => [ "id = ?", session[:order_id] ])
    raise t('checkout.common.failed_msg') unless @order
    dump_params("GetExpressCheckoutDetails")                            if DEBUG
    token = params[:token]
    payerid = params[:PayerID]
    options = { :method  => 'GetExpressCheckoutDetails',
                :token   => token,
                :payerid => payerid }
    dump_options(options)                                               if DEBUG
    @payment = @order.current_payment
    @payment.update_attributes({"get_ec_request_params" => options})
    caller = PayPalSDK::Caller.new(false)
    @transaction = caller.call( options )
    @payment.update_attributes({"get_ec_response_params" => @transaction.response})
    dump_response(@transaction.response, "GetExpressCheckoutDetails")   if DEBUG
    if @transaction.success?
      session[:pp_errors] = nil
      session[:ec_response] = @ec_response = @transaction.response

      # Further verification
      error = false
      error_message = ''
      if @ec_response["CUSTOM"].to_s != @order.token
        error_message += t('checkout.review.order_num_not_match_msg')
        error = true
      end
      if @ec_response["PAYERSTATUS"].to_s != "verified"
        error_message += t('checkout.review.payer_not_verified_msg')
        error = true
      end
      if @ec_response["CURRENCYCODE"].to_s != @order.currency_code
        error_message += t('checkout.review.currency_not_match_msg')
        error = true
      end
# May fail in some case e.g. Comparing 35.0 to 35.00 returns false
#      if @ec_response["AMT"].to_s != @order.total.to_s
#        error_message += t('checkout.review.total_amt_not_match_msg')
#        error = true
#      end
      if error
          raise error_message
      end
    else
      session[:pp_errors] = @transaction.response
      flash[:notice] = "GetExpressCheckoutDetails Failed: " + session[:pp_errors]["L_LONGMESSAGE0"].to_s
      redirect_to payment_url
    end
  rescue Exception => e
    flash[:notice] = e
    redirect_to payment_url
  end


  def confirm
    raise t('checkout.common.failed_msg') unless request.post?
    order = Order.not_checked_out.by_state("assigned").by_user(@user).
                find(:first, :conditions => [ "id = ?", session[:order_id] ])
    raise t('checkout.common.failed_msg') unless order
    notifyURL="#{get_server_path}/ppservice/ipn"
    options = { :method        => 'DOExpressCheckoutPayment',
                :token         => session[:ec_response]["TOKEN"],
                :payerid       => session[:ec_response]["PAYERID"],
                :paymentaction => 'Sale',
                :notifyurl     => notifyURL   }
    options.merge!(order.basic_options)
    dump_options(options)                                                   if DEBUG
    payment = order.current_payment
    payment.update_attributes({"do_ec_request_params" => options})
    caller = PayPalSDK::Caller.new(false)
    @transaction = caller.call( options )
    payment.update_attributes({"do_ec_response_params" => @transaction.response})
    dump_response(@transaction.response, "DOExpressCheckoutPayment")        if DEBUG
    if @transaction.success?
      session[:pp_errors] = nil
      puts "+++++++++[" + @transaction.response["PAYMENTSTATUS"].to_s + "]++++++++++"  if DEBUG
      case @transaction.response["PAYMENTSTATUS"].to_s
      when 'Completed'
        order.transaction do
          payment.update_attributes({"txn_id" => @transaction.response["TRANSACTIONID"][0]})
          payment.accept!
          order.update_attributes( {:note => t('checkout.common.payment_accept_msg') })
          order.pay!
          order.ship!
        end
        flash[:notice] = t('checkout.common.payment_accept_msg')
      when 'Pending'
        order.transaction do
          payment.update_attributes({"txn_id" => @transaction.response["TRANSACTIONID"][0]})
          payment.accept!
          order.update_attributes( {:note => t('checkout.common.payment_need_verification_msg') })
          order.checkout!
        end
        flash[:notice] = t('checkout.common.payment_need_verification_msg')
      else
        order.transaction do
          payment.update_attributes({"txn_id" => @transaction.response["TRANSACTIONID"][0]})
          payment.accept!
          order.update_attributes( {:note => t('checkout.common.payment_need_investigation_msg') })
          order.checkout!
        end
        raise  t('checkout.common.payment_need_investigation_msg')
      end
      redirect_to order_path(order.order_num)
    else
      payment.reject!
      session[:pp_errors] = @transaction.response
      flash[:notice] = "DOExpressCheckoutPayment Failed: " + session[:pp_errors]["L_LONGMESSAGE0"].to_s
      redirect_to payment_url
    end
  rescue Exception => e
    flash[:notice] = e
    redirect_to payment_url
  end

  # start paypal direct payment
  def pay_dp
    raise t('checkout.common.failed_msg') unless request.put?
    order = Order.not_checked_out.by_state("assigned").by_user(@user).
                find(:first, :conditions => [ "id = ?", session[:order_id] ])
    if order.can_pay? and order.total > 0.0
      order.update_attributes( {:recipient => @user.full_description })
      order.reset_token!
      notifyURL="#{get_server_path}/ppservice/ipn"
      options = { "method"           => 'DoDirectPayment',
                  "ip_address"       => request.remote_ip,
                  "paymentaction"    => 'Sale',
                  "notifyurl"        => notifyURL,
                  "email"            => @user.email,
                  "firstname"        => @user.fullname,
                  "lastname"         => '(' + @user.email + ')',
              #    "cardowner"        => params["cardowner"],
                  "creditcardtype"   => params["creditcardtype"],
                  "acct"             => params["acct"],
                  "expdate"          => params["date"]["month"] + params["date"]["year"],
                  "cvv2"             => params["cvv2"]    }
      options.merge!(order.basic_options)
#      options.merge!(order.ship_options)
      dump_options(options)                                             if DEBUG
      order.payments.create({ "token" => "#{order.token}", "state" => "pending",
            "method_type" => "Card"})
      payment = order.current_payment
      payment.update_attributes({"do_dp_request_params" => options.merge({"acct"=>"XXXXXX",
                                                                          "expdate"=>"XXXXXX",
                                                                          "cvv2"=>"XXXXXX",
                                                                          "creditcardtype"=>"XXXXXX"
                                                                         })
                                })
      @caller = PayPalSDK::Caller.new(false)
      @transaction = @caller.call( options )
      payment.update_attributes({"do_dp_response_params" => @transaction.response})
      dump_response(@transaction.response, "DoDirectPayment")           if DEBUG
      if @transaction.success?
        session[:pp_errors] = nil
        puts "+++++++++[" + @transaction.response["AVSCODE"].to_s + "]++++++++++"  if DEBUG
        case @transaction.response["AVSCODE"].to_s
        when 'X'
          order.transaction do
            # payment must be updated after order, otherwise payment params will be lost
            order.update_attributes( {:note => t('checkout.common.payment_accept_msg') })
            order.pay!
            order.ship!
            payment.update_attributes({"txn_id" => @transaction.response["TRANSACTIONID"][0]})
            payment.accept!
          end
          flash[:notice] = t('checkout.common.payment_accept_msg')
        else
          order.transaction do
            order.update_attributes( {:note => t('checkout.common.payment_need_investigation_msg') })
            order.checkout!
            payment.accept!
          end
          raise  t('checkout.common.payment_need_investigation_msg')
        end
        redirect_to order_path(order.order_num)
      else
        session[:pp_errors] = @transaction.response
        flash[:notice] = "DoDirectPayment Failed: " + session[:pp_errors]["L_LONGMESSAGE0"].to_s
        redirect_to payment_url
      end
    else
      raise t('checkout.common.failed_msg')
    end
  rescue Exception => e
    flash[:notice] = e
    redirect_to payment_url
  end

  def sub_layout
    'col_1_22_1'
  end

  private

  def prepare_order_for_checkout(order)
    if order.initialized? 
#      order.ip_address = request.env['REMOTE_ADDR']
      order.ip_address = request.remote_ip  unless order.ip_address
      order.save!
      order.generate_order_number! unless order.order_num
      order.assign!
    end
    #re-calculate total 
    order.save_total_from_order_lines!
  end

  def get_server_path
    host = request.host.to_s
    port = request.port.to_s
    protocol = request.protocol
    serverURL="#{protocol}#{host}"
    serverURL = serverURL + ":#{port}"  unless port == "80"
    serverURL
  end

  def clear_session_data
    session[:ec_response] = nil
  end

  def dump_params(method)
    puts "\n*** Invoking " + method
    puts "   Parameters"
    for k,v in params
       puts "#{k}: #{v}" unless ( "#{k}" == "ec")
    end
    puts "*****************************\n\n"
  end

  def dump_response(response, method)
    puts "\n*** Response for invoking " + method
    puts "   Response"
    for k,v in response
       puts "#{k}: #{v}"
    end
    puts "*****************************\n\n"
  end

  def dump_options(options)
    puts "\n*** Making PayPal Call with the following options  "
    for k,v in options
       puts "#{k}: #{v}"
    end
    puts "*****************************\n\n"
  end
end
