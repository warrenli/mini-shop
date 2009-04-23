class User < ActiveRecord::Base
  # Authorization plugin
  acts_as_authorized_user
  acts_as_authorizable

  acts_as_authentic do |c|
    c.validates_format_of_login_field_options = { :with => /\A\w[\w\.\-\_\@]*\z/,:message => I18n.t('authlogic.error_messages.login_invalid') }
    c.validates_length_of_login_field_options(:within => 10..100)
    c.validates_length_of_password_field_options(:minimum => 10, :if => :require_password?)
    c.logged_in_timeout(30.minutes)
  end

#  acts_as_authentic  :validate_login_field => false

  attr_accessible :fullname, :login, :email, :password, :password_confirmation, :active

  validates_acceptance_of :terms_of_service, :message => :msg_must_accept
  attr_accessible :terms_of_service


  default_scope  :order => "fullname ASC"
#  named_scope :active, :include => :roles, :conditions=> {:active => true}
#  named_scope :admin, :joins => :roles, :conditions => ['roles.name = ?', 'admin']
  named_scope :role,  lambda { |myrole| { :joins => [:roles], :conditions => ['roles.name = ?', myrole]} }

  validate :login_is_not_a_reserved_name
  RESERVED_LOGIN = ['ADMINISTRATOR','WEBMASTER','SUPERUSER', 'SUPERVISER', 'GUEST', 'ADMIN']

  # For changing email
  has_many :change_email_requests, :class_name => 'UserEmail', :order => 'request_expiration_date DESC'
  has_many :old_emails, :class_name => 'UserEmail',
                        :conditions => { :status => 'confirmed' },
                        :order => 'confirmed_at DESC',
                        :readonly=> true

  has_many :orders
  has_many :download_links

  def self.find_by_login_or_email(login)
    find_by_login(login) || find_by_email(login)
  end

  def self.available_login?(new_login)
    return false if RESERVED_LOGIN.include?(new_login.upcase)
    not find_by_login(new_login)
  end

  def self.available_email?(new_email)
    return false unless new_email =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
    not find_by_email(new_email)
  end

  def deliver_password_reset_instructions!
    reset_perishable_token!
    Notifier.deliver_password_reset_instructions(self)
  end

  def deliver_activation_instructions!
    unless active?
      reset_perishable_token!
      Notifier.deliver_activation_instructions(self)
    end
  end

  def deliver_activation_confirmation!
    reset_perishable_token!
    Notifier.deliver_activation_confirmation(self)
  end

  def active?
    self.active
  end

  def has_no_credentials?
    self.crypted_password.blank?
    # self.crypted_password.blank? && self.openid_identifier.blank?
  end

  def signup!(params)
    self.fullname = params[:user][:fullname]
    self.login    = params[:user][:login]
    self.email    = params[:user][:email]
    save_without_session_maintenance
  end

  def activate!(params)
    self.active = true
    self.password = params[:user][:password]
    self.password_confirmation = params[:user][:password_confirmation]
    save
  end

#  alias password_required? active?
#  alias_method :password_required?, :active?

  def require_password?
    if self.new_record?
      APP_CONFIG[:auto_activate] or self.password
    else
      true and !self.password.nil?
    end
  end

  def request_changing_email(new_email)
    new_request = UserEmail.new(:new_email => new_email, :old_email => self.email )
    self.change_email_requests << new_request
    request_code = new_request.request_code
    if request_code
      Notifier.deliver_email_verification(self, new_email, request_code) if request_code
      request_code
    else
      raise I18n.t("activerecord.errors.messages.msg_email_invalid")
    end
  end

  def full_description
    full_desc = ""
    full_desc << self.fullname << "; Email: " << self.email << "; Login: " << self.login
    full_desc
  end

  private

  def login_is_not_a_reserved_name
    errors.add(:login, :msg_login_bad ) if RESERVED_LOGIN.include?(self.login.upcase)
  end
end
