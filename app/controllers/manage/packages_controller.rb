class Manage::PackagesController < Manage::BaseController
  before_filter :find_package, :only => [:show, :edit, :update, :destroy]

  def index
    redirect_to(manage_products_url)
  end

  def show
  end

  def new
    @package = Package.new({:currency_code => APP_CONFIG[:currency]})   #( {:date_available => (Time.now + 1.day).at_beginning_of_day} )
    1.times { @package.pictures.build }
    0.times { @package.components.build }
    dummy_search
  end

  def edit
    0.times { @package.pictures.build }
    0.times { @package.components.build }
    dummy_search
  end

  def create
    @package = Package.new(params[:package])

    if @package.save
      flash[:notice] = t('manage.packages.create.success_msg')
      redirect_to manage_package_path(@package)
    else
      dummy_search
      render :action => "new"
    end
  end

  def update
    if @package.update_attributes(params[:package])
      flash[:notice] = t('manage.packages.update.success_msg')
      redirect_to manage_package_path(@package)
    else
      dummy_search
      render :action => "edit"
    end
  end

  def destroy
    @package.destroy
    redirect_to(manage_products_url)
  end

  def search_item
    criteria = params[:search]
    item_search(criteria)
  end

  private

  def find_package
    @package = Package.find(params[:id], :include => [ :pictures, :items ])
  end

  def item_search(criteria)
    @search = Item.leaf.new_search(criteria)
    @search.per_page= 4
    @items, @item_count = @search.all, @search.count
  end

  def dummy_search
    criteria = { "conditions" => {:id => -1} }
    item_search(criteria)
  end
end
