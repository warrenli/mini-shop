# http://railstips.org/2008/12/12/using-gmail-to-send-email-with-rails
#
# http://blog.inspired.no/smtp-error-while-using-gmail-in-rails-271
#
# lib/smtp-tls.rb  http://github.com/ambethia/smtp-tls/tree/master
#
ActionMailer::Base.default_content_type = "text/html"
ActionMailer::Base.default_charset = "utf-8"
ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :address        => "smtp.gmail.com",
  :port           => 587,
  :domain         => "yourdomain.com",
  :authentication => :plain,
  :user_name      => "username@gmail.com",
  :password       => "secretpassword"
}
