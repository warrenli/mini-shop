require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Notifier do
  fixtures :users

  before(:each) do
    ActionMailer::Base.deliveries = []
    @user = users(:example)
  end

  it "should sent password_reset_instructions" do
    Notifier.deliver_password_reset_instructions(@user)
#    sent.first.subject.should =~ /Password Reset Instructions/
#    sent.first.body.should =~ /password_resets/
  end

  it "should sent activation_instructions" do
    Notifier.deliver_activation_instructions(@user)
  end

  it "should sent activation_confirmation" do
    Notifier.deliver_activation_confirmation(@user)
  end

  it "should sent email_verification" do
    Notifier.deliver_email_verification(@user, 'newemail@example', 'code-123')
  end

  def sent
    ActionMailer::Base.deliveries
  end
end

