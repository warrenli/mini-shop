class UserSession < Authlogic::Session::Base
  before_destroy :reset_persistence_token

  find_by_login_method  :find_by_login_or_email

  def reset_persistence_token
    record.reset_persistence_token
  end
end
