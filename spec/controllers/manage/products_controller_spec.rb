require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Manage::ProductsController do
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
        get :index
        response.should be_success
        response.should render_template('index')
        assigns[:search].should_not be_nil
        assigns[:products].should_not be_nil
        assigns[:product_count].should_not be_nil
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
        response.should be_success
        assigns[:search].should_not be_nil
        assigns[:products].should_not be_nil
        assigns[:products].size.should > 0
        assigns[:product_count].should > 0
        response.should be_success
        response.should render_template('index')
      end
    end
  end
end

