require File.dirname(__FILE__) + '/../spec_helper'

describe UserSessionsController do
  describe "responding to GET new" do
    it "should render 'new' template" do
      get :new
      response.should be_success
      response.should render_template('new')
      assigns(:user_session).should_not be_nil
    end
  end

  describe "responding to GET show" do
    it "should render 'new' template" do
      get :show
      response.should be_success
      response.should render_template('new')
      assigns(:user_session).should_not be_nil
    end
  end

  describe "responding to POST create" do
    describe "with valid login and password" do
      it "should create user session" do
        user = User.make
        post :create, :user_session => { :login => user.login, :password => user.password }
        user_session = UserSession.find
        user_session.user.login.should eql(user.login)
        response.flash[:notice].should_not be_nil
        response.should redirect_to(edit_account_url)
      end
    end

    describe "with invalid params" do
      it "should re-render 'new' template" do
        post :create, :user_session => { :login => "abc", :password => "" }
        assigns(:user_session).should_not be_nil
        response.should be_success
        response.should render_template('new')
      end
    end
  end

  describe "responding to POST create" do
    describe "with valid email and password" do
      it "should create user session" do
        user = User.make
        post :create, :user_session => { :login => user.email, :password => user.password }
        user_session = UserSession.find
        user_session.user.login.should eql(user.login)
        response.flash[:notice].should_not be_nil
        response.should redirect_to(edit_account_url)
      end
    end
  end

  describe "responding to DELETE destroy" do
    it "should destroy user session" do
        user = User.make
        activate_authlogic
        UserSession.create(user)
        post :create, :user_session => { :login => user.login, :password => user.password }
        user_session = UserSession.find
        user_session.should_not be_nil

        delete :destroy
        response.flash[:notice].should_not be_nil
        UserSession.find.should be_nil
        response.should be_redirect
    end
  end
end
