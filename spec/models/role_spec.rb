require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Role do
  before(:each) do
    @valid_attributes = {
      :name => "value for name"
    }
    @test_role = Role.create!(@valid_attributes)
  end

  it "should create a new instance given valid attributes" do
    Role.create!(@valid_attributes)
  end

  it "should have many roles_users" do
      @test_role.should have_many(:roles_users)
  end

  it "should have many users" do
      @test_role.should have_many(:users)
  end

  it "should belongs to authorizable" do
      @test_role.should belong_to(:authorizable)
  end

  describe "with scopes - application, class, instance" do
    before do
      @site_admin = User.create!( :fullname => "Web Master",
                                  :login     => "siteadministrator",
                                  :email     => "siteadmin@example.com",
                                  :password  => "secretpassword",
                                  :password_confirmation=> "secretpassword",
                                  :active    => true)
      @site_admin.has_role 'admin'

      @user_admin = User.create!( :fullname => "User Admin",
                                  :login     => "useradministrator",
                                  :email     => "useradmin@example.com",
                                  :password  => "secretpassword",
                                  :password_confirmation=> "secretpassword",
                                  :active    => true)
      @user_admin.has_role 'admin', User

      @user_modulator = User.create!(:fullname => "User Modulator",
                                     :login     => "usermodulator",
                                     :email     => "usermodulator@example.com",
                                     :password  => "secretpassword",
                                     :password_confirmation=> "secretpassword",
                                     :active    => true)

      @simple_user = User.create!( :fullname => "Hello World",
                                   :login     => "helloworld",
                                   :email     => "helloworld@example.com",
                                   :password  => "secretpassword",
                                   :password_confirmation=> "secretpassword",
                                   :active    => true)
      @simple_user.accepts_role 'modulator', @user_modulator
    end

    it "should have @site_admin referring to nil object"  do
      @site_admin.is_admin_for_what.length.should eql(1)
      @site_admin.is_admin_for_what[0].should be_nil
      @site_admin.is_admin?.should be_true
      @site_admin.is_admin_of?(User).should be_false
      @site_admin.is_admin_of?(@user_modulator).should be_false
      @site_admin.is_admin_of?(@simple_user).should be_false
    end

    it "should have @user_admin referring to User class"  do
      @user_admin.is_admin_for_what.length.should eql(1)
      @user_admin.is_admin_for_what[0].should eql(User)
      @user_admin.is_admin?.should be_true
      @user_admin.is_admin_of?(User).should be_true
      @user_admin.is_admin_of?(@user_modulator).should be_false
      @user_admin.is_admin_of?(@simple_user).should be_false
    end

    it "should have @user_modulator referring to some user(s)"  do
      @user_modulator.is_modulator_for_what(User).length.should eql(1)
      @user_modulator.is_modulator_for_what(User)[0].should eql(@simple_user)
      @user_modulator.is_modulator?.should be_true
      @user_modulator.is_modulator_of?(User).should be_false
      @user_modulator.is_modulator_of?(@user_modulator).should be_false
      @user_modulator.is_modulator_of?(@simple_user).should be_true
    end

    it "should have @simple_user accept 'modulator' role"  do
      @simple_user.has_admin?.should be_false
      @simple_user.has_modulator?.should be_true
      @simple_user.accepts_role?('modulator', @user_modulator).should be_true
      @simple_user.has_modulator.length.should eql(1)
      @simple_user.has_modulator[0].should eql(@user_modulator)
      @simple_user.has_modulator[0].should_not eql(@user_admin)
    end

    it "should have User accept 'admin' role" do
      User.accepts_role?('admin',@user_admin).should be_true
      # User.has_admin.should be_true   *** Undefined method 'has_admin'
      # User.has_admin?.should be_true   *** Undefined method 'has_admin?'
    end

  end

end
