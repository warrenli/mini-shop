require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController do

  describe "responding to GET new" do
    it "should render 'new' template and expose a new user as @user" do
      get :new
      response.should be_success
      response.should render_template('new')
      assigns[:user].should_not be_nil
    end
  end

  describe "responding to POST create and :auto_activate is false" do
    before(:each) do
      APP_CONFIG[:auto_activate]= false
    end

    describe "with valid params (login and email)" do
      it "should create a new user and redirect to root_url" do
        assert_difference('User.count') do
          post :create, :user => { "fullname" => "Some Body",
             "login" => 'somebody_else', "email" => 'somebody@example.com' }
        end
        assigns(:user).login.should eql("somebody_else")
        assigns(:user).email.should eql("somebody@example.com")
        assigns(:user).active.should be_false
        response.flash[:notice].should_not be_nil
        response.should redirect_to(root_url)
      end
    end

    describe "with invalid params" do
      it "should re-render 'new' template" do
        assert_no_difference 'User.count' do
          post :create, :user => { "login" => '', "email" => '' }
        end
        response.should be_success
        response.should render_template('new')
      end
    end
  end

  describe "responding to POST create and :auto_activate is true" do
    before(:each) do
      APP_CONFIG[:auto_activate]= true
    end

    describe "with valid params (login, email and password)" do
      it "should create a new user and redirect to root_url" do
        assert_difference('User.count') do
          post :create, :user => { "fullname" => "Some Body",
                "login" => 'somebody_else', "email" => 'somebody@example.com',
                "password" => "secretpassword", "password_confirmation" => "secretpassword" }
        end
        assigns(:user).login.should eql("somebody_else")
        assigns(:user).email.should eql("somebody@example.com")
        assigns(:user).active.should be_true
        response.flash[:notice].should_not be_nil
        response.should redirect_to(root_url)
      end
    end

    describe "with invalid params" do
      it "should re-render 'new' template" do
        assert_no_difference 'User.count' do
          post :create, :user => { "firstname" => "Some", "lastname" => "Body",
                                   "login" => 'abcdefgh', "email" => 'abcdefgh@example.com' }
        end
        response.should be_success
        response.should render_template('new')
      end

      it "should not accept reserved word as login" do
        assert_no_difference 'User.count' do
          post :create, :user => { "firstname" => "Some", "lastname" => "Body", 
                                   "login" => 'webmaster', "email" => 'abc@example.com' }
        end
        response.should be_success
        response.should render_template('new')
      end

    end
  end

  describe "responding to GET show" do
    it "should render 'edit' template" do
      user = User.make
      activate_authlogic
      UserSession.create(user)
      get :show
      assigns(:user).login.should eql(user.login)
      response.should be_success
      response.should render_template('edit')
    end

    it "should redirect to new_user_session_url whenever not login" do
      get :show
      response.flash[:notice].should_not be_nil
      response.should redirect_to(new_user_session_url)
    end
  end

  describe "responding to GET edit" do
    it "should render 'edit' template'" do
      user = User.make
      activate_authlogic
      UserSession.create(user)
      get :edit, :id => user.id
      assigns(:user).login.should eql(user.login)
      response.should be_success
      response.should render_template('edit')
    end
  end

  describe "responding to PUT update" do
    describe "with valid params (login and email)" do
      it "should redirect to 'show' template" do
        user = User.make
        activate_authlogic
        UserSession.create(user)
        put :update, :id => user.id,
            :user => { :password => 'secretpassword', :password_confirmation => 'secretpassword' }
        response.should redirect_to(account_url)
      end
    end
    describe "with invalid params" do
      it "should re-render 'edit' template" do
        user = User.make
        activate_authlogic
        UserSession.create(user)
        put :update, :id => user.id, :user => { :email => '' }
        response.should be_success
        response.should render_template('edit')
      end
    end
  end

end

