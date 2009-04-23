class ChangeEmailController < CurrentUserController

  def new
  end

  def create
    raise unless request.post?
    @new_email = params['new_email']
    raise I18n.t("activerecord.errors.messages.msg_email_invalid") if @user.email == @new_email
    raise I18n.t("activerecord.errors.messages.msg_email_invalid") unless User.available_email?(@new_email)
    request_code = @user.request_changing_email(@new_email)
    render :action => 'show'
  rescue Exception => e
    flash[:notice] = "#{@new_email} " + e
    render :action => 'new'
  end

  def edit
    get_email_using_request_code
  rescue Exception=> e
    flash[:notice] = e
    redirect_to account_url
  end

  def update
    raise unless request.put?
    get_email_using_request_code
    User.transaction do
      @user.email = @user_email.new_email
      @user_email.status = 'confirmed'
      @user_email.confirmed_at = Time.now.utc
      @user.save!
    end
    flash[:notice] = t("change_email.update.success_msg")
  rescue Exception => e
    flash[:notice] = e
  ensure
    redirect_to account_url
  end

  def sub_layout
    'user_dashboard'
  end

  private

  def get_email_using_request_code
    @request_code = params['request_code']
    #@user_email = UserEmail.request_code(@request_code).for_user(@user.id).requested[0]
    @user_email = UserEmail.get_unconfirmed_email(@user, @request_code)
    raise "Request now found" if @user_email.nil?
  end
end
