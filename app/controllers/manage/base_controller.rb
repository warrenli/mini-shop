class Manage::BaseController < ApplicationController
  layout 'backoffice'
  before_filter :require_user
  before_filter :check_permission

  def sub_layout
    'col_1_22_1' # by default, all controllers should use the public sub_layout
  end

  protected

  # Use instance method to check permission so that error message support I18n
  def check_permission
    permit "site_admin",
        { :login_required_message => I18n.t("authorization.login_required_msg"),
          :permission_denied_message => I18n.t("authorization.permission_denied_msg") }
  end
end
