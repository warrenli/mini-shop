require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CheckoutController do

  describe "Not login" do
    describe "GET 'start'" do
      it "should be redirect to new_user_session_url" do
        get :start
        assigns[:order].should be_nil
        response.flash[:notice].should_not be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
    describe "POST 'start'" do
      it "should be redirect to new_user_session_url" do
        post :start
        assigns[:order].should be_nil
        response.flash[:notice].should_not be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
    describe "PUT 'update_address'" do
      it "should be redirect to new_user_session_url" do
        get :update_address
        assigns[:order].should be_nil
        response.flash[:notice].should_not be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
    describe "GET 'payment'" do
      it "should be redirect to new_user_session_url" do
        get :payment
        assigns[:order].should be_nil
        response.flash[:notice].should_not be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
    describe "PUT 'pay_ec'" do
      it "should be redirect to new_user_session_url" do
        put :pay_ec
        assigns[:order].should be_nil
        response.flash[:notice].should_not be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
    describe "GET 'review'" do
      it "should be redirect to new_user_session_url" do
        get :review
        assigns[:order].should be_nil
        response.flash[:notice].should_not be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
    describe "POST 'confirm'" do
      it "should be redirect to new_user_session_url" do
        put :confirm
        assigns[:order].should be_nil
        response.flash[:notice].should_not be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
  end


  describe "Login as user 'example' and execute 'start'" do
    fixtures :users, :orders, :order_lines

    before(:each) do
      @inactive = User.find_by_login("inactive_user")
      @example_user = User.find_by_login("example_user")
      activate_authlogic
      UserSession.create(@example_user)
      @order = Order.find(1)
    end

    it "should be redirected to cart_path when using GET method" do
      get :start
      assigns[:order].should be_nil
      response.should be_redirect
      response.should redirect_to(cart_path)
    end

    it "should be redirected to cart_path when order not find" do
      post :start
      assigns[:order].should be_nil
      response.should be_redirect
      response.should redirect_to(cart_path)
    end

    it "should be redirected to cart_path when order is owned by another user" do
      @order.update_attributes( {:user => @inactive })
      session[:order_id] = @order.id
      post :start
      assigns[:order].should == @order
      assigns[:order].user.should == @inactive
      response.should be_redirect
      response.should redirect_to(cart_path)
    end

    it "should be redirected to cart_path when order has no order lines" do
      @order.order_lines.destroy_all
      session[:order_id] = @order.id
      post :start
      assigns[:order].should == @order
      assigns[:order].order_lines.count.should == 0
      response.should be_redirect
      response.should redirect_to(cart_path)
    end

    it "should assign current user and render template 'start' when order is initialized" do
      @order.order_lines.count.should == 1
      @order.user.should be_nil
      @order.initialized?.should be_true
      @order.user.should be_nil
      @order.ip_address.should be_nil
      @order.order_num.should be_nil
      @order.can_assign?.should be_false
      @order.total.should be_nil
      @order.product_total.should be_nil
      session[:order_id] = @order.id

      post :start

      order = assigns[:order]
      order.should_not be_nil
      order.user.should == @example_user

      response.should be_success
      response.should render_template("start")
    end

    it "should render template 'start' when order is assigned" do
      @order.order_lines.count.should == 1
      @order.user = @example_user
      @order.ip_address = "127.0.0.1"
      @order.save!
      @order.generate_order_number!
      @order.assign!
      @order.total.should be_nil
      @order.product_total.should be_nil
      session[:order_id] = @order.id

      post :start

      order = assigns[:order]
      order.user.should == @example_user
      order.assigned?.should be_true

      response.should be_success
      response.should render_template("start")
    end
  end


  describe "Login as user 'example' and execute 'under_address'" do
    fixtures :users, :orders, :countries

    before(:each) do
      @example_user = User.find_by_login("example_user")
      activate_authlogic
      UserSession.create(@example_user)
      @order = Order.find(1)
      usa = Country.find(840)
      @addr_attribute = {
        "street_1"=>"address line 1",
        "street_2"=>"address line 2",
        "city"=>"city name",
        "postal_code"=>"zip",
        "country_id"=>usa.id
      }
    end

    it "should be redirected to cart_url using GET" do
      get :update_address
      assigns[:order].should be_nil
      response.should be_redirect
      response.should redirect_to(cart_url)
    end

    it "should be redirected to cart_url using POST" do
      post :update_address
      assigns[:order].should be_nil
      response.should be_redirect
      response.should redirect_to(cart_url)
    end

    it "should be redirected to cart_path when order not find" do
      put :update_address, :order => {"shipping_address_attributes"=>@addr_attribute,
                                      "billing_address_attributes"=>@addr_attribute}
      assigns[:order].should be_nil
      response.should be_redirect
      response.should redirect_to(cart_path)
    end

    it "should update billing address and shipping address for order 'initialized'" do
      @order.user = @example_user
      @order.save!
      @order.initialized?
      session[:order_id] = @order.id
      put :update_address , :order => {"shipping_address_attributes"=>@addr_attribute,
                                        "billing_address_attributes"=>@addr_attribute}
      response.flash[:notice].should_not be_nil
      order = assigns[:order]
      order.total.should_not be_nil
      order.product_total.should_not be_nil
      order.assigned?.should be_true
      order.billing_address.should_not be_nil
      order.shipping_address.should_not be_nil
      response.should be_redirect
      response.should redirect_to( :controller=>'checkout', :action=>'payment' )
    end

    it "should update billing address and shipping address for order 'assigned'" do
      @order.user = @example_user
      @order.ip_address = '127.0.0.1'
      @order.save!
      @order.generate_order_number!
      @order.assign!
      session[:order_id] = @order.id
      put :update_address , :order => {"shipping_address_attributes"=>@addr_attribute,
                                        "billing_address_attributes"=>@addr_attribute}
      order = assigns[:order]
      order.total.should_not be_nil
      order.product_total.should_not be_nil
      order.assigned?.should be_true

      response.flash[:notice].should_not be_nil
      response.should be_redirect
      response.should redirect_to( :controller=>'checkout', :action=>'payment' )
    end
  end


  describe "Login as user 'example' and execute 'payment'" do
    fixtures :users, :orders, :order_lines

    before(:each) do
      @example_user = User.find_by_login("example_user")
      activate_authlogic
      UserSession.create(@example_user)
      @order = Order.find(1)
      addr_attribute = {
        "street_1"=>"address line 1",
        "street_2"=>"address line 2",
        "city"=>"city name",
        "postal_code"=>"zip",
        "country_id"=>840
      }
      @order.build_billing_address(addr_attribute)
    end

    it "should be redirected to cart_path when order not find" do
      put :payment
      assigns[:order].should be_nil
      response.should be_redirect
      response.should redirect_to(cart_path)
    end

    it "should redirect to cart_url if order is not assigned" do
      @order.initialized?
      session[:order_id] = @order.id
      get :payment
        assigns[:order].should be_nil
      response.should be_redirect
      response.should redirect_to(cart_url)
    end

    it "should be render template 'payment'" do
      @order.order_lines.count.should == 1
      @order.user = @example_user
      @order.ip_address = '127.0.0.1'
      @order.save!
      @order.generate_order_number!
      @order.assign!
      @order.save_total_from_order_lines!

      session[:order_id] = @order.id
      get :payment
      order = assigns[:order]
      order.can_pay?.should be_true
      response.should render_template('payment')
    end

    it "should pay!, ship! and then redirect to order_path if order total == 0" do
      @order.order_lines.count.should == 1
      order_line = @order.order_lines[0]
      @order.order_product_lines_attributes = [ { :id => order_line.id, :price => 0.0 } ]

      @order.user = @example_user
      @order.ip_address = '127.0.0.1'
      @order.save!
      @order.generate_order_number!
      @order.assign!
      @order.save_total_from_order_lines!
      @order.reload
      @order.order_lines[0].line_total.should eql(0.0)
      @order.display_total.should =~ /0.0/

      session[:order_id] = @order.id
      get :payment
      order = assigns[:order]
      response.should be_redirect
      response.should redirect_to( order_url(order.order_num) )

      order.shipped?.should be_true
    end
  end


  describe "Login as user 'example' and execute 'pay_ec'" do
    fixtures :users, :orders, :order_lines

    before(:each) do
      @example_user = User.find_by_login("example_user")
      activate_authlogic
      UserSession.create(@example_user)
      @order = Order.find(1)
      addr_attribute = {
        "street_1"=>"address line 1",
        "street_2"=>"address line 2",
        "city"=>"city name",
        "postal_code"=>"zip",
        "country_id"=>840
      }
      @order.build_billing_address(addr_attribute)
      @order.user = @example_user
      @order.ip_address = '127.0.0.1'
      @order.order_num = Time.now.to_s   # Make it unique
      @order.save!
      @order.assign!
      @order.save_total_from_order_lines!
      @order.reload
    end

    it "should be redirected to payment_url using GET" do
      get "pay_ec"
      assigns[:order].should be_nil
      response.should be_redirect
      response.should redirect_to(payment_url)
    end

    it "should be redirected to payment_url using POST" do
      post "pay_ec"
      assigns[:order].should be_nil
      response.should be_redirect
      response.should redirect_to(payment_url)
    end

    it "should be redirected to payment_path when order not find" do
      put :pay_ec
      assigns[:order].should be_nil
      response.should be_redirect
      response.should redirect_to(payment_path)
    end

    it "should redirect to PayPal site when order is valid" do
      session[:order_id] = @order.id
      put "pay_ec"
      txn = assigns[:transaction]
      txn.success?.should be_true

      token = txn.response["TOKEN"].to_s
      token.should_not be_nil
      response.should be_redirect
      response.should redirect_to(PAYPAL_EC_URL + token)
    end
  end


  describe "Login as user 'example' and execute 'review'" do
    fixtures :users, :orders, :order_lines

    before(:each) do
      @example_user = User.find_by_login("example_user")
      activate_authlogic
      UserSession.create(@example_user)
      @order = Order.find(1)
      addr_attribute = {
        "street_1"=>"address line 1",
        "street_2"=>"address line 2",
        "city"=>"city name",
        "postal_code"=>"zip",
        "country_id"=>840
      }
      @order.build_billing_address(addr_attribute)
      @order.user = @example_user
      @order.ip_address = '127.0.0.1'
      @order.order_num = Time.now.to_s   # Make it unique
      @order.save!
      @order.assign!
      @order.save_total_from_order_lines!
      @order.reset_token!
      @order.reload
    end

    it "should be redirected to payment_path when order not find" do
      get :review
      assigns[:order].should be_nil
      response.should be_redirect
      response.should redirect_to(payment_path)
    end

    it "should be redirected to payment_path when paypal processing failed" do
      @order.payments.create({ "token" => "#{@order.token}", "state" => "pending",
                      "method_type" => "PayPal", "set_ec_request_params" => {} })
      session[:order_id] = @order.id
      get :review,:id => @order.token, :token => '123', :PayerID => 'abc'
      assigns[:order].should_not be_nil
      assigns[:payment].should_not be_nil
      txn = assigns(:transaction)
      txn.success?.should be_false
      txn.response["L_SHORTMESSAGE0"].should == ["Invalid token"]
      response.should be_redirect
      response.should redirect_to(payment_path)
    end
  end


  describe "Login as user 'example' and execute 'confirm'" do
    fixtures :users, :orders, :order_lines

    before(:each) do
      @example_user = User.find_by_login("example_user")
      activate_authlogic
      UserSession.create(@example_user)
      @order = Order.find(1)
      addr_attribute = {
        "street_1"=>"address line 1",
        "street_2"=>"address line 2",
        "city"=>"city name",
        "postal_code"=>"zip",
        "country_id"=>840
      }
      @order.build_billing_address(addr_attribute)
      @order.user = @example_user
      @order.ip_address = '127.0.0.1'
      @order.order_num = Time.now.to_s   # Make it unique
      @order.save!
      @order.assign!
      @order.save_total_from_order_lines!
      @order.reset_token!
      @order.reload
    end

    it "should be redirected to payment_path when order not find" do
      post :confirm
      assigns[:order].should be_nil
      response.should be_redirect
      response.should redirect_to(payment_path)
    end

    it "should be redirected to payment_path when paypal processing failed" do
      @order.payments.create({ "token" => "#{@order.token}", "state" => "pending",
                      "method_type" => "PayPal", "set_ec_request_params" => {} })

      session[:order_id] = @order.id
      session[:ec_response] = { "TOKEN" => "test_token", "PAYERID" => "abc" }

      post :confirm
      txn = assigns(:transaction)
      txn.success?.should be_false
      txn.response["L_SHORTMESSAGE0"].should == ["Invalid token"]
      response.should be_redirect
      response.should redirect_to(payment_path)
    end

  end

  describe "Login as user 'example' and execute 'pay_dp'" do
    fixtures :users, :orders, :order_lines

    before(:each) do
      @example_user = User.find_by_login("example_user")
      activate_authlogic
      UserSession.create(@example_user)
      @order = Order.find(1)
      addr_attribute = {
        "street_1"=>"address line 1",
        "street_2"=>"address line 2",
        "city"=>"city name",
        "postal_code"=>"zip",
        "country_id"=>840
      }
      @order.build_billing_address(addr_attribute)
      @order.user = @example_user
      @order.ip_address = '127.0.0.1'
      @order.order_num = Time.now.to_s   # Make it unique
      @order.save!
      @order.assign!
      @order.save_total_from_order_lines!
      @order.reload
    end

    it "should be redirected to payment_path when order cannot be paid" do
      order = Order.create( :user => @example_user, :state => 'assigned',
                     :has_checked_out => 0, :currency_code => "HKD", :total => 0.0)
      order.should_not be_nil
      order.can_pay?.should be_false
      session[:order_id] = order.id
      put :pay_dp, "acct"=>"4916322182862824", "date"=>{"month"=>"4", "year"=>"2011"},
                   "cvv2"=>"999", "creditcardtype"=>"Visa"
      response.flash[:notice].should_not be_nil
      response.should redirect_to(payment_url)
    end

    it "should be failed and redirected to payment_path because of unsupported Currency" do
      @order.currency_code.should == 'HKD'
      @order.can_pay?.should be_true
      session[:order_id] = @order.id
      put :pay_dp, "acct"=>"4916322182862824", "date"=>{"month"=>"4", "year"=>"2011"},
                   "cvv2"=>"999", "creditcardtype"=>"Visa"
      assigns(:caller).should be_true
      txn = assigns(:transaction)
      txn.success?.should be_false
#      txn.response["L_SHORTMESSAGE0"].should == ["Unsupported Currency."]
       txn.response["L_SHORTMESSAGE0"].to_s.should =~ /transaction cannot be processed/
      response.should redirect_to(payment_url)
    end
  end
end
