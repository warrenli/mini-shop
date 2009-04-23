require File.dirname(__FILE__) + '/../spec_helper'

describe ActivationsController do
  fixtures :users
  before(:all) do
    APP_CONFIG[:auto_activate]= false
  end

  describe "GET 'new'" do
    before(:each) do
      @inactive = User.find_by_login('inactive_user')
    end

    it "should render 'new' template using perishable_token of inactive user" do
      @inactive.active?.should be_false
      get :new, :activation_code => @inactive.perishable_token
      response.should be_success
      response.should render_template('new')
      assigns(:user).login.should eql(@inactive.login)
      assigns(:user).active.should be_false
      end

    it "should redirect to root_url using invalid activation_code" do
      get :new, :activation_code => "xxx"
      response.should be_redirect
      response.should redirect_to(root_url)
    end

    it "should redirect to root_url using perishable token of an active user" do
      user = User.make
      user.active?.should be_true
      get :new, :activation_code => user.perishable_token
      response.should be_redirect
    end
  end

  describe "POST 'create'" do
    before(:each) do
      @inactive = User.find_by_login('inactive_user')
    end

    it "should re-render 'new' template using invalid password" do
      @inactive.active?.should be_false
      post :create, :id => @inactive.id, 
           :user => { :password => 'secretpassword', :password_confirmation => 'word'}
      response.should be_success
      response.should render_template('new')
    end

    it "should redirect to account_url using valid password" do
      @inactive.active?.should be_false
      post :create, :id => @inactive.id, 
           :user => { :password => 'secretpassword', :password_confirmation => 'secretpassword'}
      assigns(:user).login.should eql(@inactive.login)
      assigns(:user).active.should be_true
      response.flash[:notice].should_not be_nil
      response.should redirect_to(account_url)
    end
  end

  describe "POST 'create' for already activated user" do
    it "should redirect to root_url" do
      user = User.make
      user.active?.should be_true
      post :create, :id => user.id, 
           :user => { :password => 'secretpassword', :password_confirmation => 'secretpassword'}
      response.should redirect_to(root_url)
    end
  end
end
