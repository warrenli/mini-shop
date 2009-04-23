class OrdersController < CurrentUserController
  def index
    criteria = params[:search]
    @search = Order.checked_out.by_user(@user).new_search(criteria)
    @orders, @orders_count = @search.all, @search.count
  end

  def show
    @order = Order.checked_out.by_user(@user).by_number(params[:order_num]).first
  end

  def sub_layout
    'user_dashboard'
  end
end
