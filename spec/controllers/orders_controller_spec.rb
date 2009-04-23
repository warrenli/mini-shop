require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OrdersController do

  describe "Not login" do
    describe "GET 'show'" do
      it "should be redirect to new_user_session_url" do
        get :show
        response.flash[:notice].should_not be_nil
        response.should redirect_to(new_user_session_url)
      end
    end

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
  end

  describe "Login as user" do
    before(:each) do
      @user = User.make
      @order = Order.make(:ip_address => "127.0.0.1", :user_id=>@user.id, :order_num=>"123",
                          :state=>"pending", :total=>0.0, :product_total=>0.0, :has_checked_out=>1)
      activate_authlogic
      UserSession.create(@user)
    end

    describe "GET 'show'" do
      it "should render template 'show'" do
        @order.user.should == @user
        @order.checked_out?.should be_true
        get :show, :order_num=>'123'
        assigns[:order].should == @order
        response.should be_success
        response.should render_template('show')
      end
    end

    describe "GET 'index'" do
      it "should render template 'index'" do
        get :index
        assigns[:search].should_not be_nil
        assigns[:orders].should_not be_nil
        assigns[:orders][0].should == @order
        assigns[:orders_count].should == 1
        response.should be_success
        response.should render_template('index')
      end
    end

    describe "GET 'index' using XMLHttpRequest" do
      it "should fetch all items when search criteria is null" do
#        request.env['HTTP_ACCEPT'] = 'application/json, text/javascript, */*'
#        request.env['HTTP_X_REQUESTED_WITH'] = 'XMLHttpRequest'
#        get :search_item
        xhr :get, :index
        assigns[:search].should_not be_nil
        assigns[:orders].should_not be_nil
        assigns[:orders][0].should == @order
        assigns[:orders_count].should == 1
        response.should be_success
        response.should render_template('index')
      end
    end

  end
end
