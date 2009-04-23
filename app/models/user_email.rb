class UserEmail < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :user, :new_email, :old_email #, :reset_code, :request_expiration_date, :status
  validates_format_of :new_email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => :msg_email_invalid

#  default_scope :order => 'confirmed_at DESC, created_at DESC'
#  named_scope :old_emails, :order => 'request_expiration_date DESC', :conditions => { :status => 'confirmed' }
  named_scope :for_user, lambda { |id| { :order => "request_expiration_date DESC", :conditions => [ "user_id = ?",  id] } }
  named_scope :is, lambda{ |what| { :order => 'request_expiration_date DESC',:conditions => [ "status = ?", what ] } }
  named_scope :expired, :conditions => [ "request_expiration_date <= ? ", Time.now.to_s(:db) ]
  named_scope :request_code, lambda{ |code| { :limit => 1, :conditions => [ "request_code = ? and request_expiration_date > ? ", code, Time.now.to_s(:db) ]} }

  def self.get_unconfirmed_email(user, request_code)
    self.request_code(request_code).for_user(user.id).is('requested')[0]
  end

  protected

  def before_create
    self.request_code = Digest::SHA1.hexdigest(Time.now.to_s.split(//).sort_by {rand}.join )
    self.request_expiration_date = 1.day.from_now
    self.status = 'requested'
  end
end
