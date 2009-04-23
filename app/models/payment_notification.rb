class PaymentNotification < ActiveRecord::Base
  serialize :params
  after_create :mark_order_as_paid

  private

  def mark_order_as_paid
#    if status == "Completed" && params[:secret] == APP_CONFIG[:paypal_secret] &&
#        params[:receiver_email] == APP_CONFIG[:paypal_email] &&
#        params[:mc_gross] == cart.total_price.to_s && params[:mc_currency] == "USD"
#      cart.update_attribute(:purchased_at, Time.now)
#    end
  end
end

