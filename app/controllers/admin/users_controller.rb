class Admin::UsersController < ApplicationController
  layout 'backoffice'
  before_filter :require_user
  before_filter :check_permission
  before_filter :find_user, :only => [:show, :edit, :update, :destroy, :change_role]
  before_filter :grant_permission, :only=> [:update, :destroy, :change_role]

#  permit "admin of User or site_admin", { :login_required_message => I18n.t("authorization.login_required_msg"),  :permission_denied_message => I18n.t("authorization.permission_denied_msg") }

  def index
    criteria = params[:search]
    if params[:role_name].blank?
      @search = User.new_search(criteria)
    else
      @search = User.role(params[:role_name]).new_search(criteria)
    end
    @users, @users_count = @search.all, @search.count
  end

  def show
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = t("admin.users.create.success_msg")
      redirect_to admin_user_path(@user)
    else
      render :action => "new"
    end
  end

  def update
    if @permission_granted
      if @user.update_attributes(params[:user])
        flash[:notice] = t("admin.users.update.success_msg")
        redirect_to admin_user_path(@user)
      else
        render :action => "edit"
      end
    else
      flash[:notice] = t("admin.users.common.no_permission_msg")
      render :action => "edit"
    end
  end

  def destroy
    if @permission_granted
      @user.destroy
      flash[:notice] = t("admin.users.destroy.success_msg") << @user.login
    else
      flash[:notice] = t("admin.users.common.no_permission_msg")
    end
  rescue Exception => e
    flash[:notice] = t("admin.users.destroy.failure_msg") << e.message
  ensure
    redirect_to admin_users_url
  end

  def change_role
    if @permission_granted
      opt = params[:opt]
      role_name = params[:role_name]
      class_name = params[:class_name] ? params[:class_name] : nil

      case opt
      when "Add"
        if class_name.blank?
          @user.has_role role_name
          message = role_name.capitalize
        else
          @user.has_role role_name, class_name.classify.constantize
          message = role_name.capitalize << "_of_" << class_name.capitalize
        end
        flash[:notice] =  t("admin.users.edit.add_role") << " " << message
      when "Remove"
        if class_name.blank?
          @user.has_no_role role_name 
          message = role_name.capitalize
        else
          @user.has_no_role role_name, class_name.classify.constantize
          message = role_name.capitalize << "_of_" << class_name.capitalize
        end
        flash[:notice] = t("admin.users.edit.remove_role") << " " << message
      else
        flash[:notice] = t("admin.users.change_role.failure_msg")
      end
    else
      flash[:notice] = t("admin.users.common.no_permission_msg")
    end
  rescue Exception => e
    flash[:notice] = e.message
  ensure
    redirect_to edit_admin_user_path(@user)
  end

  def sub_layout
    'col_3_18_3'
  end

  private

  # Use instance method to check permission so that error message support I18n
  def check_permission
    permit "admin of User or site_admin",
        { :login_required_message => I18n.t("authorization.login_required_msg"),
          :permission_denied_message => I18n.t("authorization.permission_denied_msg") }
  end

  def find_user
    @user = User.find(params[:id], :include => :roles)
  end

  def grant_permission
    @permission_granted = true
    # @current_user is either Is_Admin_of_User or Is_Site_admin
    # 1. if @user is 'site_admin' only 'site_amin'is allow to modify @user
    if @user.has_role?('site_admin')
      @permission_granted = @current_user.has_role?('site_admin') ? true : false
    end
    # 2. if @user is 'admin' only @current_user is allow to modify @user
    if @user.has_role?('admin', User) and @current_user.has_role?('admin', User)
       @permission_granted = false unless @user == @current_user
    end
  end
end
