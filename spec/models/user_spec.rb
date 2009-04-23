require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  fixtures :users

  it { should have_many(:orders) }
  it { should have_many(:download_links) }

  describe 'being created with valid attribures and :auto_activate is false' do
    before(:each) do
      APP_CONFIG[:auto_activate]= false
      @new_user = User.make( :active=>false, :password=>"", :password_confirmation=>"")
    end

    it "should not be active" do
      @new_user.active.should be_false
      @new_user.active?.should be_false
      @new_user.require_password?.should be_false
    end

    it "should has no credentials" do
      @new_user.has_no_credentials?.should be_true
    end
    after(:each) do
     @new_user.destroy
    end
  end

  describe 'being created with valid attribures, active equals false and :auto_activate is true' do
    before(:each) do
      APP_CONFIG[:auto_activate]= true
      @new_user = User.make( :active=>false)
    end

    it "should not be active" do
      @new_user.active.should be_false
      @new_user.active?.should be_false
      @new_user.require_password?.should be_true
    end

    it "should has no credentials" do
      @new_user.has_no_credentials?.should be_false
    end
  end

  describe 'being signed up with valid attribures and :auto_activate is false' do
    before(:each) do
      APP_CONFIG[:auto_activate]= false
      @valid_attributes = { :user => { :fullname => 'Hello World',
                                       :login => 'example_tester', :email => 'tester@example.com' } }
      @new_user = User.new
      @new_user.signup!(@valid_attributes)
      @valid_password = { :user => { :password => 'secretpassword', :password_confirmation => 'secretpassword'} }
    end

    it "should not be active" do
      @new_user.active.should be_false
      @new_user.active?.should be_false
      @new_user.require_password?.should be_false
    end

    it "should has no credentials" do
      @new_user.has_no_credentials?.should be_true
    end

    it "should deliver_activation_instructions!" do
      old_perishable_token = @new_user.perishable_token
      @new_user.deliver_activation_instructions!
      @new_user.perishable_token.should_not eql(old_perishable_token)
    end

    it "should be activate! with new password" do
      @new_user.activate!(@valid_password)
      @new_user.active.should be_true
      @new_user.active?.should be_true
      @new_user.require_password?.should be_true
    end

    it "should deliver_activation_confirmation!" do
      old_perishable_token = @new_user.perishable_token
      @new_user.deliver_activation_confirmation!
      @new_user.perishable_token.should_not eql(old_perishable_token)
    end

    it "should deliver_password_reset_instructions!" do
      old_perishable_token = @new_user.perishable_token
      @new_user.deliver_password_reset_instructions!
      @new_user.perishable_token.should_not eql(old_perishable_token)
    end
  end

  describe 'being signed up with valid attribures, active equals false and :auto_activate is true' do
    before(:each) do
      APP_CONFIG[:auto_activate]= true
      @new_user = User.make( :active=>false)
    end

    it "should not be active" do
      @new_user.active.should be_false
      @new_user.active?.should be_false
      @new_user.require_password?.should be_true
    end

    it "should has credentials" do
      @new_user.has_no_credentials?.should be_false
    end

    it "should deliver_activation_instructions!" do
      old_perishable_token = @new_user.perishable_token
      @new_user.deliver_activation_instructions!
      @new_user.perishable_token.should_not eql(old_perishable_token)
    end

    it "should be activated explicitly" do
      @new_user.active = true
      @new_user.active.should be_true
      @new_user.active?.should be_true
      @new_user.require_password?.should be_true
    end

    it "should deliver_password_reset_instructions!" do
      old_perishable_token = @new_user.perishable_token
      @new_user.deliver_password_reset_instructions!
      @new_user.perishable_token.should_not eql(old_perishable_token)
    end
  end

  describe "has class method available_login?" do
    before(:each) do
      @admin = User.find_by_login('admin_superuser')
    end

    it "should return false for reserved login" do
      User.available_login?('Administrator').should be_false
      User.available_login?('webmaster').should be_false
      User.available_login?('superUser').should be_false
      User.available_login?('Superviser').should be_false
      User.available_login?('guest').should be_false
    end

    it "should return false for @admin" do
      User.available_login?(@admin.login).should be_false
      User.available_login?('guest_admin').should be_true
    end
  end

  describe "has class method available_email?" do
    before(:each) do
      @admin = User.find_by_login('admin_superuser')
    end

    it "should return false for invalid email pattern" do
      User.available_email?('invalid_email').should be_false
    end

    it "should return false for @admin" do
      User.available_email?(@admin.email).should be_false
      User.available_email?('unknown@example.com').should be_true
    end
  end
end

