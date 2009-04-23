class Manage::ProductsController < Manage::BaseController
  def index
    criteria = params[:search]
    @search = Product.new_search(criteria)
    @products, @product_count = @search.all, @search.count
  end
end
