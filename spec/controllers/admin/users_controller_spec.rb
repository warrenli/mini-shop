require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::UsersController do
  describe "responding to GET index" do
    describe "without login" do
      it "should be redirect to new_user_session_url" do
        get :index
        response.flash[:notice].should_not be_nil
        response.should redirect_to(new_user_session_url)
      end
    end

    describe "after login but not User admin/site_admin" do
      it "should be redirect to root_url" do
        user = User.make
        activate_authlogic
        UserSession.create(user)
        get :index
        response.flash[:notice].should_not be_nil
        response.should redirect_to(root_url)
      end
    end

    describe "login as User admin" do
      it "should be render 'index' template " do
        user = User.make
        user.has_role 'admin', User
        user.roles[0].to_s.should eql('Is_Admin_of_User')
        activate_authlogic
        UserSession.create(user)
        get :index
        response.should be_success
        response.should render_template('index')
        assigns[:users].should_not be_nil
        assigns[:users_count].should_not be_nil
        assigns[:search].should_not be_nil
      end

      describe "search role 'admin'" do
        it "should found some users" do
          user = User.make
          user.has_role 'admin', User
          activate_authlogic
          UserSession.create(user)
          get :index, :role_name=>"admin"
          response.should be_success
          response.should render_template('index')
          assigns[:users_count].should eql(1)
        end
      end
    end

    describe "login as site_admin" do
      it "should be render 'index' template " do
        user = User.make
        user.has_role 'site_admin'
        activate_authlogic
        UserSession.create(user)
        get :index
        response.should be_success
        response.should render_template('index')
        assigns[:users].should_not be_nil
        assigns[:users_count].should_not be_nil
        assigns[:search].should_not be_nil
      end
    end
  end

  describe "responding to GET show" do
    describe "without login" do
      it "should be redirect to new_user_session_url" do
        get :show, :id => "37"
        response.flash[:notice].should_not be_nil
        response.should redirect_to(new_user_session_url)
      end
    end

    describe "after login but not User admin/site_admin" do
      it "should be redirect to root_url" do
        user = User.make
        activate_authlogic
        UserSession.create(user)
        get :show, :id => "37"
        response.flash[:notice].should_not be_nil
        response.should redirect_to(root_url)
      end
    end

    describe "login as User admin" do
      it "should be render 'show' template " do
        user = User.make
        user.has_role 'admin', User
        activate_authlogic
        UserSession.create(user)
        get :show, :id => user.id
        response.should be_success
        response.should render_template('show')
        assigns[:user].login.should eql(user.login)
      end
    end

    describe "login as site_admin" do
      it "should be render 'show' template " do
        user = User.make
        user.has_role 'site_admin'
        activate_authlogic
        UserSession.create(user)
        get :show, :id => user.id
        response.should be_success
        response.should render_template('show')
        assigns[:user].login.should eql(user.login)
      end
    end
  end

  describe "responding to GET new" do
    describe "without login" do
      it "should be redirect to new_user_session_url" do
        get :new
        response.flash[:notice].should_not be_nil
        response.should redirect_to(new_user_session_url)
      end
    end

    describe "after login but not User admin/site_admin" do
      it "should be redirect to root_url" do
        user = User.make
        activate_authlogic
        UserSession.create(user)
        get :new
        response.flash[:notice].should_not be_nil
        response.should redirect_to(root_url)
      end
    end

    describe "login as User admin" do
      it "should be render 'new' template " do
        user = User.make
        user.has_role 'admin', User
        activate_authlogic
        UserSession.create(user)
        get :new
        response.should be_success
        response.should render_template('new')
        assigns[:user].should_not be_nil
      end
    end

    describe "login as site_admin" do
      it "should be render 'new' template " do
        user = User.make
        user.has_role 'site_admin'
        activate_authlogic
        UserSession.create(user)
        get :new
        response.should be_success
        response.should render_template('new')
        assigns[:user].should_not be_nil
      end
    end
  end


  describe "responding to GET edit" do
    describe "without login" do
      it "should be redirect to new_user_session_url" do
        get :edit, :id => "37"
        response.flash[:notice].should_not be_nil
        response.should redirect_to(new_user_session_url)
      end
    end

    describe "after login but not User admin/site_admin" do
      it "should be redirect to root_url" do
        user = User.make
        activate_authlogic
        UserSession.create(user)
        get :edit, :id => "37"
        response.flash[:notice].should_not be_nil
        response.should redirect_to(root_url)
      end
    end

    describe "login as User admin" do
      it "should be render 'edit' template " do
        user = User.make
        user.has_role 'admin', User
        activate_authlogic
        UserSession.create(user)
        get :edit, :id => user.id
        response.should be_success
        response.should render_template('edit')
        assigns[:user].login.should eql(user.login)
      end
    end

    describe "login as site_admin" do
      it "should be render 'edit' template " do
        user = User.make
        user.has_role 'site_admin'
        activate_authlogic
        UserSession.create(user)
        get :edit, :id => user.id
        response.should be_success
        response.should render_template('edit')
        assigns[:user].login.should eql(user.login)
      end
    end
  end

  describe "responding to POST create" do
    describe "without login" do
      it "should be redirect to new_user_session_url" do
        assert_no_difference 'User.count' do
          post :create, :user => { "login" => '', "email" => '', "password" => '',
            "password_confirmation" => '', "active" => '1'}
        end
        response.flash[:notice].should_not be_nil
        response.should redirect_to(new_user_session_url)
      end
    end

    describe "after login but not User admin/site_admin" do
      it "should be redirect to root_url" do
        user = User.make
        activate_authlogic
        UserSession.create(user)
        assert_no_difference 'User.count' do
          post :create, :user => { "login" => '', "email" => '', "password" => '',
            "password_confirmation" => '', "active" => '1'}
        end
        response.flash[:notice].should_not be_nil
        response.should redirect_to(root_url)
      end
    end

    describe "login as User admin" do
      describe "with valid params" do
        it "should create a new user and redirect to admin_user_path" do
          user = User.make
          user.has_role 'admin', User
          activate_authlogic
          UserSession.create(user)
          assert_difference('User.count') do
            post :create, :user => { "fullname" => "Some Body",
              "login" => 'somebody_else', "email" => 'somebody@example.com',
              "password" => 'secretpassword', "password_confirmation" => 'secretpassword', "active" => '1'}
          end
          response.flash[:notice].should_not be_nil
          response.should be_redirect
#          response.should redirect_to(admin_user_path(user))
#          assigns[:user].login.should eql(user.login)
        end
      end
    end

    describe "login as User admin" do
      describe "with invalid params" do
        it "should re-render 'new' template" do
          user = User.make
          user.has_role 'site_admin'
          activate_authlogic
          UserSession.create(user)
          assert_no_difference('User.count') do
            post :create, :user => { "login" => 'somebody_else', "email" => 'somebody@example.com',
              "password" => 'secretpassword', "password_confirmation" => '', "active" => '1'}
          end
          response.should be_success
          response.should render_template('new')
        end
      end
    end
  end

  describe "responding to PUT update" do
    before do
      @siteadmin1 = User.make( :login => 'siteadministrator1', :email => 'siteadmin1@example.com')
      @siteadmin1.has_role 'site_admin'
      @siteadmin2 = User.make( :login => 'siteadministrator2', :email => 'siteadmin2@example.com')
      @siteadmin2.has_role 'site_admin'
      @adminone = User.make( :login => 'administratorone', :email => 'adminone@example.com')
      @adminone.has_role 'admin', User
      @admintwo = User.make( :login => 'administratortwo', :email => 'admintwo@example.com')
      @admintwo.has_role 'admin', User
    end

    describe "without login" do
      it "should be redirect to new_user_session_url" do
        put :update, :id => "37",
            :user => { "login" => '', "email" => '', "password" => '',
                       "password_confirmation" => '', "active" => '1'}
        response.flash[:notice].should_not be_nil
        response.should redirect_to(new_user_session_url)
      end
    end

    describe "after login but not User admin/site_admin" do
      it "should be redirect to root_url" do
        user = User.make
        activate_authlogic
        UserSession.create(user)
        put :update, :id => "37",
            :user => { "login" => '', "email" => '', "password" => '',
                       "password_confirmation" => '', "active" => '1'}
        response.flash[:notice].should_not be_nil
        response.should redirect_to(root_url)
      end
    end

    describe "login as User admin" do
      describe "change password of current user " do
        it "should redirect to 'show' template" do
          activate_authlogic
          UserSession.create(@adminone)
          put :update, :id => @adminone.id,
              :user => { "password" => 'newpassword', "password_confirmation" => 'newpassword' }
          response.flash[:notice].should_not be_nil
          response.should redirect_to(admin_user_path(@adminone))
        end
      end
      describe "change password of current user but invalid" do
        it "should re-render 'edit' template" do
          activate_authlogic
          UserSession.create(@adminone)
          put :update, :id => @adminone.id,
              :user => { "password" => 'password', "password_confirmation" => 'newpassword' }
          response.flash[:notice].should be_nil
        response.should be_success
        response.should render_template('edit')
        end
      end
      describe "change password of another User admin" do
        it "should re-render 'edit' template" do
          activate_authlogic
          UserSession.create(@adminone)

          put :update, :id => @admintwo.id,
              :user => { "password" => 'newpassword', "password_confirmation" => 'newpassword' }
          response.flash[:notice].should_not be_nil
          response.should be_success
          response.should render_template('edit')
        end
      end
      describe "change password of site admin" do
        it "should re-render 'edit' template" do
          activate_authlogic
          UserSession.create(@adminone)
          put :update, :id => @siteadmin1.id,
              :user => { "password" => 'newpassword', "password_confirmation" => 'newpassword' }
        response.flash[:notice].should_not be_nil
        response.should be_success
        response.should render_template('edit')
        end
      end
    end

    describe "login as site admin" do
      describe "change password of current user" do
        it "should redirect to 'show' template" do
          activate_authlogic
          UserSession.create(@siteadmin1)
          put :update, :id => @siteadmin1.id,
              :user => { "password" => 'newpassword', "password_confirmation" => 'newpassword' }
          response.flash[:notice].should_not be_nil
          response.should redirect_to(admin_user_path(@siteadmin1))
        end
      end
      describe "change password of another site admin" do
        it "should redirect to 'show' template" do
          activate_authlogic
          UserSession.create(@siteadmin1)
          put :update, :id => @siteadmin2.id,
              :user => { "password" => 'newpassword', "password_confirmation" => 'newpassword' }
          response.flash[:notice].should_not be_nil
          response.should redirect_to(admin_user_path(@siteadmin2))
        end
      end
    end
  end

  describe "responding to DELETE destroy" do
    before do
      @siteadmin1 = User.make( :login => 'siteadministrator1', :email => 'siteadmin1@example.com')
      @siteadmin1.has_role 'site_admin'
      @siteadmin2 = User.make( :login => 'siteadministrator2', :email => 'siteadmin2@example.com')
      @siteadmin2.has_role 'site_admin'
      @adminone = User.make( :login => 'administratorone', :email => 'adminone@example.com')
      @adminone.has_role 'admin', User
      @admintwo = User.make( :login => 'administratortwo', :email => 'admintwo@example.com')
      @admintwo.has_role 'admin', User
    end

    describe "without login" do
      it "should be redirect to new_user_session_url" do
        delete :destroy, :id => "37"
        response.flash[:notice].should_not be_nil
        response.should redirect_to(new_user_session_url)
      end
    end

    describe "after login but not User admin/site_admin" do
      it "should be redirect to root_url" do
        user = User.make
        activate_authlogic
        UserSession.create(user)
        delete :destroy, :id => "37"
        response.flash[:notice].should_not be_nil
        response.should redirect_to(root_url)
      end
    end

    describe "login as User admin" do
      describe "try to destroy a normal user" do
        it "should be success, redirect to admin_users_url" do
          user = User.make
          activate_authlogic
          UserSession.create(@adminone)
          delete :destroy, :id => user.id
          response.flash[:notice].should =~/#{user.login}/
          response.should redirect_to(admin_users_url)
        end
      end
      describe "try to destroy another User admin" do
        it "should ignore the action" do
          activate_authlogic
          UserSession.create(@adminone)
          delete :destroy, :id => @admintwo.id
          response.flash[:notice].should_not =~/#{@admintwo.login}/
          response.should redirect_to(admin_users_url)
        end
      end
      describe "try to destroy site admin" do
        it "should ignore the action" do
          user = User.make
          activate_authlogic
          UserSession.create(@adminone)
          delete :destroy, :id => @siteadmin1.id
          response.flash[:notice].should_not =~/#{@admintwo.login}/
          response.should redirect_to(admin_users_url)
        end
      end
    end

    describe "login as site admin" do
      describe "try to destroy another site admin" do
        it "should be success, redirect to admin_users_url" do
          activate_authlogic
          UserSession.create(@siteadmin1)
          delete :destroy, :id => @siteadmin2.id
          response.flash[:notice].should =~/#{@siteadmin2.login}/
          response.should redirect_to(admin_users_url)
        end
      end
    end
  end

  describe "responding to PUT change_role" do
    before do
      @siteadmin1 = User.make( :login => 'siteadministrator1', :email => 'siteadmin1@example.com')
      @siteadmin1.has_role 'site_admin'
      @siteadmin2 = User.make( :login => 'siteadministrator2', :email => 'siteadmin2@example.com')
      @siteadmin2.has_role 'site_admin'
      @adminone = User.make( :login => 'administratorone', :email => 'adminone@example.com')
      @adminone.has_role 'admin', User
      @admintwo = User.make( :login => 'administratortwo', :email => 'admintwo@example.com')
      @admintwo.has_role 'admin', User
      @user = User.make
    end

    describe "without login" do
      it "should be redirect to new_user_session_url" do
        put :change_role, :id => "37",
            :opt => "Add", :role_name => "modulator", :class_name => "user"
        response.flash[:notice].should_not be_nil
        response.should redirect_to(new_user_session_url)
      end
    end

    describe "after login but not User admin/site_admin" do
      it "should be redirect to root_url" do
        activate_authlogic
        UserSession.create(@user)
        put :change_role, :id => "37",
            :opt => "Add", :role_name => "modulator", :class_name => "user"
        response.flash[:notice].should_not be_nil
        response.should redirect_to(root_url)
      end
    end

    describe "login as User admin" do
      describe "try to add modulator to a normal user and then remove it afterward" do
        it "should be success, redirect to admin_users_url" do
          @user.is_modulator?.should be_false
          activate_authlogic
          UserSession.create(@adminone)
          put :change_role, :id => @user.id,
              :opt => "Add", :role_name => "modulator"
          response.flash[:notice].should_not be_nil
          response.should redirect_to(edit_admin_user_url(@user))
          @user.is_modulator?.should be_true

          put :change_role, :id => @user.id,
              :opt => "Remove", :role_name => "modulator"
          response.flash[:notice].should_not be_nil
          response.should redirect_to(edit_admin_user_url(@user))
          @user.is_modulator?.should be_false
        end
      end

      describe "try to add modulator_of_user to a normal user and then remove it afterward" do
        it "should be success, redirect to admin_users_url" do
          @user.is_modulator_of?(User).should be_false
          activate_authlogic
          UserSession.create(@adminone)
          put :change_role, :id => @user.id,
              :opt => "Add", :role_name => "modulator", :class_name => "user"
          response.flash[:notice].should_not be_nil
          response.should redirect_to(edit_admin_user_url(@user))
          @user.is_modulator_of?(User).should be_true

          put :change_role, :id => @user.id,
              :opt => "Remove", :role_name => "modulator", :class_name => "user"
          response.flash[:notice].should_not be_nil
          response.should redirect_to(edit_admin_user_url(@user))
          @user.is_modulator_of?(User).should be_false
        end
      end

      describe "try to perform invalid action" do
        it "should be ignore, redirect to admin_users_url" do
          @user.is_modulator?.should be_false
          activate_authlogic
          UserSession.create(@adminone)
          put :change_role, :id => @user.id,
              :opt => "Plus", :role_name => "modulator"
          response.flash[:notice].should_not be_nil
          response.should redirect_to(edit_admin_user_url(@user))
          @user.is_modulator?.should be_false
        end
      end

      describe "try to add modulator to another User admin" do
        it "should be ignore, redirect to admin_users_url" do
          @admintwo.is_modulator?.should be_false
          activate_authlogic
          UserSession.create(@adminone)
          put :change_role, :id => @admintwo.id,
              :opt => "Add", :role_name => "modulator"
          response.flash[:notice].should_not be_nil
          response.should redirect_to(edit_admin_user_url(@admintwo))
          @user.is_modulator?.should be_false
        end
      end
    end
  end

end

