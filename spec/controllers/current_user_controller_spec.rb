require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CurrentUserController do

  describe "Not login" do
    describe "GET 'index'" do
      it "should be redirect to new_user_session_url" do
        get :index
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

    describe "GET 'index'" do
      it "should render template 'index'" do
        get :index
        response.should be_redirect
        response.should redirect_to({:controller => 'orders', :action => 'index'})
      end
    end

  end
end
