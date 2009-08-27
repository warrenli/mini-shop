class PpserviceController < ApplicationController
  protect_from_forgery :except => :ipn

  def ipn
    txn_id = params[:txn_id]
    token  = params[:custom]
    @PayPalLog ||= PayPalSDKUtils::Logger.getLogger(PAYPAL_IPN_LOG)
    @PayPalLog.info "IPN_notify: #{CGI.unescape(params.inspect)}"

    if token.nil?
      @PayPalLog.info "IPN_notify_error: missing token"
      raise_error
    end

    if txn_id.nil?
      @PayPalLog.info "IPN_notify_error: missing txn_id"
      raise_error
    end

    order = Order.by_token(token).first
    order_id = order ? order.id : nil
    PaymentNotification.create!(:params => params, :token => token, :order_id => order_id,
          :status => params[:payment_status], :txn_id => txn_id)

    ipn = PayPalSDK::IpnNotifier.new(request.raw_post)
    if ["VERIFIED", "INVALID"].include?(ipn.result)
        @params = ipn.params
        if @params["test_ipn"] == "1"
          # This is a test in sandbox
          @PayPalLog.info "IPN_notify: test in sandbox"
        end
        if ["Completed","Denied","Failed","Pending"].include?(@params["payment_status"])
           #add your business logic here
           # For a complete list of valid payment_status, refer to PayPal API Reference
          @PayPalLog.info "IPN_notify: valid status"
        else
           #Reason to be suspicious
          @PayPalLog.info "IPN_notify: invalid status"
        end
        render :text => '', :status => 204        # 204 for no content
    else
        @PayPalLog.info "IPN_unknown_result: #{ipn.result}"
        raise_error
    end

  rescue Errno::ENOENT => exception
    @PayPalLog.info "IPN_exception: " + exception
    raise_error
  end

  private

  def raise_error
    render :file => "#{RAILS_ROOT}/public/500.html", :status => 500
  end
end
