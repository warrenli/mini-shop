class PasswordResetsController < ApplicationController
  before_filter :load_user_using_perishable_token, :only => [:edit, :update]
  before_filter :require_no_user

  def index
    render :action => :new
  end

  def new
    render
  end

  def create
    @user = User.find_by_email(params[:email])
    if @user
      @user.deliver_password_reset_instructions!
      flash[:notice] = t('password_resets.create.success_msg')
      redirect_to root_url
    else
      flash[:notice] = t('password_resets.create.failed_msg', :your_email => "#{params[:email]}")
      render :action => :new
    end
  end

  def show
    redirect_to :action => :edit
  end

  def edit
    render
  end

  def update
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.password && @user.password_confirmation &&  @user.save
      flash[:notice] = t('password_resets.update.success_msg')
      redirect_to account_url
    else
      @user.errors.add_to_base(t('password_resets.update.failed_msg')) if @user.errors.empty?
      render :action => :edit
    end
  end

  def sub_layout
    'col_4_16_4'
  end

  private
    def load_user_using_perishable_token
      # @user = User.find_using_perishable_token(params[:id])
      @user = User.find_using_perishable_token(params[:id],30.minutes)
      unless @user
        flash[:notice] = t('password_resets.load_user_error_msg')
        redirect_to root_url
      end
    end
end
