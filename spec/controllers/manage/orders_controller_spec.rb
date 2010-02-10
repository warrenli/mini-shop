require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Manage::OrdersController do
  describe "Not login" do
    describe "GET 'index'" do
      it "should be redirect to new_user_session_url" do
        get :index
        response.flash[:notice].should_not be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
    describe "GET 'index' using XMLHttpRequest" do
      it "should redirect to root_url" do
        xhr :get, :index
        response.flash[:notice].should_not be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
    describe "GET 'show'" do
      it "should be redirect to new_user_session_url" do
        get :show, :id => 123
        response.flash[:notice].should_not be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
    describe "PUT 'pay'" do
      it "should be redirect to new_user_session_url" do
        put :pay, :id => 123
        response.flash[:notice].should_not be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
    describe "PUT 'ship'" do
      it "should be redirect to new_user_session_url" do
        put :ship, :id => 123
        response.flash[:notice].should_not be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
    describe "PUT 'void'" do
      it "should be redirect to new_user_session_url" do
        put :void, :id => 123
        response.flash[:notice].should_not be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
    describe "DELETE 'destroy'" do
      it "should be redirect to new_user_session_url" do
        delete :destroy, :id => 123
        response.flash[:notice].should_not be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
    describe "PUT 'resend_receipt'" do
      it "should be redirect to new_user_session_url" do
        put :resend_receipt, :id => 123
        response.flash[:notice].should_not be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "Login as general user" do
    before(:each) do
      @user = User.make
      activate_authlogic
      UserSession.create(@user)
    end
    describe "GET 'index'" do
      it "should redirect to root_url" do
        get :index
        response.flash[:notice].should_not be_nil
        response.should redirect_to(root_url)
      end
    end
    describe "GET 'index' using XMLHttpRequest" do
      it "should redirect to root_url" do
        xhr :get, :index
        response.flash[:notice].should_not be_nil
        response.should redirect_to(root_url)
      end
    end
    describe "GET 'get'" do
      it "should redirect to root_url" do
        get :show, :id => 123
        response.flash[:notice].should_not be_nil
        response.should redirect_to(root_url)
      end
    end
    describe "PUT 'pay'" do
      it "should redirect to root_url" do
        put :pay, :id => 123
        response.flash[:notice].should_not be_nil
        response.should redirect_to(root_url)
      end
    end
    describe "PUT 'ship'" do
      it "should redirect to root_url" do
        put :ship, :id => 123
        response.flash[:notice].should_not be_nil
        response.should redirect_to(root_url)
      end
    end
    describe "PUT 'void'" do
      it "should redirect to root_url" do
        put :void, :id => 123
        response.flash[:notice].should_not be_nil
        response.should redirect_to(root_url)
      end
    end
    describe "DELETE 'destroy'" do
      it "should redirect to root_url" do
        delete :destroy, :id => 123
        response.flash[:notice].should_not be_nil
        response.should redirect_to(root_url)
      end
    end
    describe "PUT 'resend_receipt'" do
      it "should redirect to root_url" do
        put :resend_receipt, :id => 123
        response.flash[:notice].should_not be_nil
        response.should redirect_to(root_url)
      end
    end
  end

  describe "Login as site_admin" do
    before(:each) do
      @user = User.make
      @user.has_role 'site_admin'
      @user.roles[0].to_s.should eql('Is_Site_admin')
      activate_authlogic
      UserSession.create(@user)
    end
    describe "GET 'index'" do
      it "should return products and product_count" do
        order = Order.make(:ip_address => "127.0.0.1", :user_id=>@user.id, :order_num=>"123",
                           :state=>"pending", :total=>0.0, :product_total=>0.0, :has_checked_out=>1)
        get :index
        assigns[:search].should_not be_nil
        assigns[:orders].should_not be_nil
        assigns[:order_count].should_not be_nil
        response.should be_success
        response.should render_template('index')
      end
    end
    describe "GET 'index' using XMLHttpRequest" do
      it "should fetch all orders when search criteria is null" do
        order = Order.make(:ip_address => "127.0.0.1", :user_id=>@user.id, :order_num=>"123",
                           :state=>"pending", :total=>0.0, :product_total=>0.0, :has_checked_out=>1)
#        request.env['HTTP_ACCEPT'] = 'application/json, text/javascript, */*'
#        request.env['HTTP_X_REQUESTED_WITH'] = 'XMLHttpRequest'
#        get :search_item
        xhr :get, :index
        assigns[:search].should_not be_nil
        assigns[:orders].should_not be_nil
        assigns[:orders].size.should > 0
        assigns[:order_count].should > 0
        response.should be_success
        response.should render_template('index')
      end
    end

    describe "GET 'show'" do
      it "should render template 'show'" do
        order = Order.make(:ip_address => "127.0.0.1", :user_id=>@user.id, :order_num=>"123",
                           :state=>"pending", :total=>0.0, :product_total=>0.0, :has_checked_out=>1)
        get :show, :id => order.id
        assigns[:order].should == order
        response.should be_success
        response.should render_template('show')
      end
    end

    describe "PUT 'pay'" do
      it "should be paid and redirect to manage_order_path" do
        order = Order.make(:ip_address => "127.0.0.1", :user_id=>@user.id, :order_num=>"123",
                           :state=>"pending", :total=>0.0, :product_total=>0.0, :has_checked_out=>1)
        order.can_pay?.should be_true
        put :pay, :id => order.id
        assigns[:order].should == order
        order.reload
        order.paid?.should be_true
        response.flash[:notice].should_not be_nil
        response.should redirect_to(manage_order_path(order))
      end
      it "should be unchanged and redirect to manage_order_path if order can't pay" do
        order = Order.make(:ip_address => "127.0.0.1", :user_id=>@user.id, :order_num=>"123",
                           :state=>"voided", :total=>0.0, :product_total=>0.0, :has_checked_out=>1)
        order.can_pay?.should be_false
        put :pay, :id => order.id
        assigns[:order].should == order
        order.reload
        order.paid?.should be_false
        response.flash[:notice].should_not be_nil
        response.should redirect_to(manage_order_path(order))
      end
    end
    describe "PUT 'ship'" do
      it "should be shipped and redirect to mange_order_path" do
        order = Order.make(:ip_address => "127.0.0.1", :user_id=>@user.id, :order_num=>"123",
                           :state=>"paid", :total=>0.0, :product_total=>0.0, :has_checked_out=>1)
        order.can_ship?.should be_true
        put :ship, :id => order.id
        assigns[:order].should == order
        order.reload
        order.shipped?.should be_true
        response.flash[:notice].should_not be_nil
        response.should redirect_to(manage_order_path(order))
      end
      it "should be unchanged and redirect to mange_order_path if order can't ship" do
        order = Order.make(:ip_address => "127.0.0.1", :user_id=>@user.id, :order_num=>"123",
                           :state=>"voided", :total=>0.0, :product_total=>0.0, :has_checked_out=>1)
        order.can_ship?.should be_false
        put :ship, :id => order.id
        assigns[:order].should == order
        order.reload
        order.shipped?.should be_false
        response.flash[:notice].should_not be_nil
        response.should redirect_to(manage_order_path(order))
      end
    end
    describe "PUT 'void'" do
      it "a pending order should be voided and redirect to mange_order_path" do
        order = Order.make(:ip_address => "127.0.0.1", :user_id=>@user.id, :order_num=>"123",
                           :state=>"pending", :total=>0.0, :product_total=>0.0, :has_checked_out=>1)
        order.can_void?.should be_true
        put :void, :id => order.id
        assigns[:order].should == order
        order.reload
        order.voided?.should be_true
        response.flash[:notice].should_not be_nil
        response.should redirect_to(manage_order_path(order))
      end
      it "an assigned order should be voided and redirect to mange_order_path" do
        order = Order.make(:ip_address => "127.0.0.1", :user_id=>@user.id, :order_num=>"123",
                           :state=>"assigned", :total=>0.0, :product_total=>0.0, :has_checked_out=>0)
        order.can_void?.should be_true
        put :void, :id => order.id
        assigns[:order].should == order
        order.reload
        order.voided?.should be_true
        response.flash[:notice].should_not be_nil
        response.should redirect_to(manage_order_path(order))
      end
      it "should be unchanged and redirect to mange_order_path if order can't void" do
        order = Order.make(:ip_address => "127.0.0.1", :user_id=>@user.id, :order_num=>"123",
                           :state=>"voided", :total=>0.0, :product_total=>0.0, :has_checked_out=>0)
        order.can_void?.should be_false
        put :void, :id => order.id
        assigns[:order].should == order
        order.reload
        order.can_void?.should be_false
        response.flash[:notice].should_not be_nil
        response.should redirect_to(manage_order_path(order))
      end
    end
    describe "DELETE 'destroy'" do
      it "an initialized order should be destroyed and redirect to manage_orders_path" do
        order = Order.make(:ip_address => "127.0.0.1", :user_id=>@user.id,
                           :state=>"initialized", :has_checked_out=>0)
        order.can_destroy?.should be_true
        delete :destroy, :id => order.id
        assigns[:order].should == order
        response.flash[:notice].should_not be_nil
        response.should redirect_to(manage_orders_path)
        lambda { Order.find(order.id)}.should raise_error(ActiveRecord::RecordNotFound)
      end
      it "an assigned order should not be destroyed and redirect to manage_orders_path" do
        order = Order.make(:ip_address => "127.0.0.1", :user_id=>@user.id, :order_num=>"123",
                           :state=>"assigned", :total=>0.0, :product_total=>0.0, :has_checked_out=>0)
        order.can_destroy?.should be_false
        delete :destroy, :id => order.id
        assigns[:order].should == order
        order.reload
        order.assigned?.should be_true
        response.flash[:notice].should_not be_nil
        response.should redirect_to(manage_orders_path)
      end
    end
    describe "PUT 'resend_receipt'" do
      it "receipt should be sent and redirect to mange_order_path" do
        ActionMailer::Base.delivery_method = :test
        ActionMailer::Base.deliveries = []
        order = Order.make(:ip_address => "127.0.0.1", :user_id=>@user.id, :order_num=>"123",
                           :state=>"pending", :total=>0.0, :product_total=>0.0, :has_checked_out=>1)
        assert_difference('ActionMailer::Base.deliveries.length', 1) do
          put :resend_receipt, :id => order.id
        end
        assigns[:order].should == order
        ActionMailer::Base.deliveries.first.subject.should =~ /RESEND/#correct subject
        response.flash[:notice].should == I18n.t("manage.orders.resend_receipt.success_msg")
        response.should redirect_to(manage_order_path(order))
      end
      it "no receipt should be sent and redirect to mange_order_path if order is voided" do
        ActionMailer::Base.delivery_method = :test
        ActionMailer::Base.deliveries = []
        order = Order.make(:ip_address => "127.0.0.1", :user_id=>@user.id, :order_num=>"123",
                           :state=>"voided", :total=>0.0, :product_total=>0.0, :has_checked_out=>1)
        assert_no_difference('ActionMailer::Base.deliveries.length') do
          put :resend_receipt, :id => order.id
        end
        assigns[:order].should == order
        response.flash[:notice].should == I18n.t("manage.orders.resend_receipt.failed_msg")
        response.should redirect_to(manage_order_path(order))
      end
    end
  end

end
