require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UserEmail do
  fixtures :users, :user_emails
  before(:each) do
    @admin = User.find_by_login('admin_superuser')
  end

  describe "request changing email with valid attribures for admin user" do
    it "should return request_code and deliver_email_verification" do
      assert_difference('UserEmail.count') do
        @request_code = @admin.request_changing_email('newemail@example.com')
      end
      @request_code.should_not be_nil
      @request_code.should == UserEmail.get_unconfirmed_email(@admin, @request_code).request_code
    end
  end

  describe "request changing email with invalid attribures for admin user" do
    it "should not return request_code" do
      lambda { @request_code = @admin.request_changing_email('invalid_email') }.should raise_error
      @request_code.should be_nil
    end
  end

  describe "has named_scope for_user(user_id)" do
    it "should equal to User.change_email_request" do
       @admin.change_email_requests.count.should == UserEmail.for_user(@admin.id).count
       @admin.change_email_requests.should == UserEmail.for_user(@admin.id)
    end
  end

  describe "applying named_scope is(what) and for_user(id)" do
    it "should equal to User.old_emails" do
      @admin.old_emails.count.should == UserEmail.for_user(@admin.id).is('confirmed').count
      @admin.old_emails.should == UserEmail.for_user(@admin.id).is('confirmed')
      @request_code = @admin.request_changing_email('admin@example.com')
      UserEmail.get_unconfirmed_email(@admin, @request_code).should eql(UserEmail.request_code(@request_code)[0])
    end
  end

  describe "applying named_scope request_code() for a new UserEmail record" do
    it "should not be included in the results of named_scope expired" do
      @request_code = @admin.request_changing_email('admin@example.com')
      user_email = UserEmail.request_code(@request_code)[0]
      UserEmail.expired.include?(user_email).should be_false
    end
  end
end

