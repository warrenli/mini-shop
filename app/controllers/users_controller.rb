class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update]
  before_filter :find_user, :only => [:show, :edit, :update]

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])

    if APP_CONFIG[:auto_activate]
      @user.active = true
      if @user.save
        flash[:notice] = t('users.create.success_msg')
        redirect_back_or_default root_url
      else
        render :action => :new
      end
    else
      if @user.save_without_session_maintenance
        @user.deliver_activation_instructions!
        flash[:notice] = t('users.create.need_activation_msg')
        redirect_back_or_default root_url
      else
        render :action => :new
      end
    end

  end

  def show
    render :action => :edit
  end

  def edit
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:notice] = t('users.update.success_msg')
      redirect_to account_url
    else
      render :action => :edit
    end
  end

  def sub_layout
    if !current_user
      'col_4_16_4'
    else
      'user_dashboard'
    end
  end

  private

  def find_user
    @user = @current_user
  end
end
