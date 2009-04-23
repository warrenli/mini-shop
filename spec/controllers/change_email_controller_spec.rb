require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ChangeEmailController do
  describe "GET 'new'" do
    it "should redirect to new_user_session_url whenever not login" do
      get 'new'
      response.should redirect_to(new_user_session_url)
    end

    it "should should render 'new' template  when login" do
      user = User.make
      activate_authlogic
      UserSession.create(user)
      get 'new'
      assigns(:user).login.should eql(user.login)
      response.flash[:notice].should be_nil
      response.should be_success
      response.should render_template('new')
    end
  end

  describe "POST 'create'" do
    it "should redirect to new_user_session_url whenever not login" do
      post 'create'
      response.should redirect_to(new_user_session_url)
    end

    describe "after login" do
      before(:each) do
        @user = User.make
        activate_authlogic
        UserSession.create(@user)
      end

      it "should render 'show' template if new email is valid" do
        new_email = 'abc@example.com'
        post 'create', :new_email => new_email
        assigns(:user).login.should eql(@user.login)
        assigns(:new_email).should eql(new_email)
        response.flash[:notice].should be_nil
        response.should be_success
        response.should render_template('show')
      end

      it "should render 'new' template  if new email equals original email" do
        new_email = @user.email
        post 'create', :new_email => new_email
        assigns(:user).login.should eql(@user.login)
        assigns(:new_email).should eql(new_email)
        response.flash[:notice].should_not be_nil
        response.should be_success
        response.should render_template('new')
      end

      it "should 'new' template if new email equals another user's email" do
        @another_user = User.make( :login => 'testing_user', :email => 'tester@example.com')
        @another_user.email.should eql('tester@example.com')

        new_email = @another_user.email
        post 'create', :new_email => new_email
        assigns(:user).login.should eql(@user.login)
        assigns(:new_email).should eql(new_email)
        response.flash[:notice].should_not be_nil
        response.should be_success
        response.should render_template('new')
      end

      it "should render 'new' template  if new email is invalid" do
        new_email = 'abc'
        post 'create', :new_email => new_email
        assigns(:user).login.should eql(@user.login)
        assigns(:new_email).should eql(new_email)
        response.flash[:notice].should_not be_nil
        response.should be_success
        response.should render_template('new')
      end
    end
  end

  describe "GET 'show'" do
    it "should redirect to new_user_session_url whenever not login" do
      get 'show'
      response.should redirect_to(new_user_session_url)
    end

    it "should should render 'show' template  when login" do
      user = User.make
      activate_authlogic
      UserSession.create(user)
      get 'show'
      assigns(:user).login.should eql(user.login)
      response.flash[:notice].should be_nil
      response.should be_success
      response.should render_template('show')
    end
  end

  describe "GET 'edit'" do
    it "should redirect to new_user_session_url whenever not login" do
      get 'edit'
      response.should redirect_to(new_user_session_url)
    end

    describe "after login" do
      before(:each) do
        @user = User.make
        activate_authlogic
        UserSession.create(@user)
        @new_email = 'valid@example.com'
        @request_code = @user.request_changing_email(@new_email)
      end

      it "should should render 'edit' template if request code is valid" do
        get 'edit', :request_code => @request_code
        assigns(:user).login.should eql(@user.login)
        assigns(:request_code).should eql(@request_code)
        assigns(:user_email).should_not be_nil
        response.flash[:notice].should be_nil
        response.should be_success
      response.should render_template('edit')
      end

      it "should should redirect to account_url if request code is invalid" do
        invalid_request_code = "invalid"
        get 'edit', :request_code => invalid_request_code
        assigns(:user).login.should eql(@user.login)
        assigns(:request_code).should eql(invalid_request_code)
        assigns(:user_email).should be_nil
        response.flash[:notice].should_not be_nil
        response.should redirect_to(account_url)
      end
    end
  end

  describe "POST 'update'" do
    it "should redirect to new_user_session_url whenever not login" do
      put 'update'
      response.should redirect_to(new_user_session_url)
    end

    describe "after login" do
      before(:each) do
        @user = User.make
        activate_authlogic
        UserSession.create(@user)
        @new_email = 'valid@example.com'
        @request_code = @user.request_changing_email(@new_email)
      end

      it "should should redirect to account_url if request code is valid" do
        put 'update', :request_code => @request_code
        assigns(:user).login.should eql(@user.login)
        assigns(:request_code).should eql(@request_code)
        assigns(:user_email).should_not be_nil
        response.flash[:notice].should_not be_nil
        response.should redirect_to(account_url)
        @user.reload
        @user.email.should == @new_email
      end

      it "should should redirect to account_url if request code is invalid" do
        invalid_request_code = "invalid"
        put 'update', :request_code => invalid_request_code
        assigns(:user).login.should eql(@user.login)
        assigns(:request_code).should eql(invalid_request_code)
        assigns(:user_email).should be_nil
        response.flash[:notice].should_not be_nil
        response.should redirect_to(account_url)
      end
    end
  end
end
