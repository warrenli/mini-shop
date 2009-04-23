class Notifier < ActionMailer::Base
  default_url_options[:host] = APP_CONFIG[:host]
#  default_url_options[:port] = 3000

  def password_reset_instructions(user)
    subject       "重置密碼方法 - Password Reset Instructions"
    from          APP_CONFIG[:admin_email]
    recipients    user.email
    sent_on       Time.now.utc
    body          :edit_password_reset_url => edit_password_reset_url(user.perishable_token)
    content_type  "text/plain"
  end

  def activation_instructions(user)
    subject       "帳戶啟動方法 - Activation Instructions"
    from          APP_CONFIG[:admin_email]
    recipients    user.email
    sent_on       Time.now.utc
    body          :account_activation_url => register_url(user.perishable_token)
    content_type  "text/plain"
  end

  def activation_confirmation(user)
    subject       "帳戶啟動完畢- Activation Complete"
    from          APP_CONFIG[:admin_email]
    recipients    user.email
    sent_on       Time.now.utc
    body          :root_url => root_url
    content_type  "text/plain"
  end

  def email_verification(user, new_email, request_code)
    subject       "確認新電郵地址 - Confirm New Email Address"
    from          APP_CONFIG[:admin_email]
    recipients    new_email
    sent_on       Time.now.utc
    body          :confirm_url => change_email_url(request_code)
    content_type  "text/plain"
  end
end
