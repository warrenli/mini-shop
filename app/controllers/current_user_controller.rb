class CurrentUserController < ApplicationController
  before_filter :require_user
  before_filter :find_user

  def index
    redirect_to :controller => 'orders', :action => 'index'
  end

  def sub_layout
    'col_24'
  end

  protected

  def find_user
    @user = @current_user
  end
end
