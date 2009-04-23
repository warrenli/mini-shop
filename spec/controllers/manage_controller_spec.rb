require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ManageController do
  describe "Not login - GET 'index'" do
    describe "GET 'index'" do
      it "should be redirect to new_user_session_url" do
        get :index
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
      it "should render 'index' template" do
        get :index
        response.should be_success
        response.should render_template('index')
      end
    end
  end
end
