require File.dirname(__FILE__) + '/../spec_helper'

describe PasswordResetsController do
  describe "responding to GET index" do
    it "should render 'new' template" do
      get :index
      response.should be_success
      response.should render_template('new')
    end
  end

  describe "responding to GET show" do
    it "should render 'edit' template" do
      user = User.make
      get :show, :id => user.perishable_token
      response.should redirect_to("/password_resets/#{user.perishable_token}/edit")
    end
  end

  describe "responding to GET new" do
    it "should render 'new' template" do
      get :new
      response.should be_success
      response.should render_template('new')
    end
  end

  describe "responding to GET edit" do
    describe "with valid perishable_token" do
        it "should render 'edit' template" do
        user = User.make
        get :edit, :id => user.perishable_token
        assigns(:user).login.should eql(user.login)
        response.should be_success
        response.should render_template('edit')
      end
    end
    describe "with invalid perishable_token" do
      it "should redirect to root_url" do
        get :edit, :id => "xxx"
        assigns(:user).should be_nil
        response.flash[:notice].should_not be_nil
        response.should redirect_to(root_url)
      end
    end
  end

  describe "responding to POST create" do
    describe "with valid email" do
      it "should redirect to root_url" do
        user = User.make
        post :create, :email => user.email
        assigns(:user).login.should eql(user.login)
        response.flash[:notice].should_not be_nil
        response.should redirect_to(root_url)
      end
    end

    describe "with invalid email" do
      it "should re-render 'new' template" do
        post :create, :email => 'abc'
        assigns(:user).should be_nil
        response.flash[:notice].should_not be_nil
        response.should render_template('new')
      end
    end
  end

  describe "responding to PUT udpate" do
    describe "with valid password" do
      it "should redirect to account_url" do
        user = User.make
        put :update, :id => user.perishable_token, 
            :user => {:password => 'secretpassword', :password_confirmation => 'secretpassword'}
        assigns(:user).login.should eql(user.login)
        response.flash[:notice].should_not be_nil
        response.should redirect_to(account_url)
      end
    end

    describe "with invalid password" do
      it "should re-render 'edit' template" do
        user = User.make
        put :update, :id => user.perishable_token, 
            :user => {:password => 'secretpassword', :password_confirmation => 'word'}
        assigns(:user).login.should eql(user.login)
        response.should render_template('edit')
      end
    end
  end

end
