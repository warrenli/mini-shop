class OrderMailer < ActionMailer::Base
#  layout 'awesome'

  default_url_options[:host] = APP_CONFIG[:host]

  def receipt(order, resend = false)
    setup_email(order.user)
    @subject    = (resend ? "[RESEND] " : "")
    @subject    += '訂購單 Order #' + order.order_num
    @body       = { "order" => order }
  end

  protected

  def setup_email(user)
    @recipients   = user.email
    @from         = APP_CONFIG[:admin_email]
    @headers      = { "Reply-to" => APP_CONFIG[:admin_email] }
    @sent_on      = Time.now.utc
    @bcc          = APP_CONFIG[:admin_email]
    @content_type = "text/plain"                 #    @content_type  "text/html"
  end
end
