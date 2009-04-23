# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all
  protect_from_forgery # :secret => 'd66f2151a3c38cae0424ca278cd2d6ab'
  helper_method :current_user_session, :current_user
  filter_parameter_logging :password, :password_confirmation
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  before_filter :set_locale
  before_filter :set_meta_data
  before_filter :set_user_time_zone

  def sub_layout
    'col_1_22_1' # by default, all controllers should use the public sub_layout
  end

  protected

    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.record
    end

  private
    def require_user
      unless current_user
        store_location
        flash[:notice] = t("application.require_user.warning_msg")
        redirect_to new_user_session_url
        return false
      end
    end

    def require_no_user
      if current_user
        store_location
        flash[:notice] = t("application.require_no_user.warning_msg")
        redirect_to account_url
        return false
      end
    end

    def store_location
      session[:return_to] = request.request_uri
    end

    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end

    def set_locale
      # update session if passed
      # session[:locale] = params[:locale] if params[:locale]
      new_locale = extract_locale_from_params
      session[:locale] = new_locale if new_locale

      # set locale based on session or default
      I18n.locale = session[:locale] || I18n.default_locale
      logger.debug "Locale set to '#{I18n.locale}'"

      Searchlogic::Config.configure do |config|
        config.helpers.page_links_next = t("searchlogic.next")
        config.helpers.page_links_prev = t("searchlogic.prev")
      end
    end

    def extract_locale_from_params
      (AVAILABLE_LOCALES.include? params[:locale]) ? params[:locale]  : nil
    end

    def set_meta_data
      @meta_keywords = "Hong Kong, Kowloon, PayPal, Rails, Ruby, Shop, Download, do not rush, "
      @meta_description = "Mini online shop selling downloadable products, support PayPal, i18n, default language is Chinese('zh-HK')"
    end

#   before_filter :setup_mailer_defaults
#   def setup_mailer_defaults
#     ActionMailer::Base.default_url_options[:host] = request.host_with_port
#   end

    # Automatically respond with 404 for ActiveRecord::RecordNotFound
    def record_not_found
      render :file => File.join(RAILS_ROOT, 'public', '404.html'), :status => 404
    end

    def set_user_time_zone
      if current_user
        Time.zone = current_user.time_zone
      else
        Time.zone="Hong Kong"
      end
    end
end
