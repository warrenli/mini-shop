class Manage::ItemsController < Manage::BaseController
  before_filter :find_item, :only => [:show, :edit, :update, :destroy]

  def index
    redirect_to(manage_products_url)
  end

  def show
  end

  def new
    @item = Item.new({:currency_code => APP_CONFIG[:currency]})   #( {:date_available => (Time.now + 1.day).at_beginning_of_day} )
    1.times { @item.pictures.build }
    0.times { @item.variations.build }
    1.times { @item.downloads.build }
  end

  def edit
    0.times { @item.pictures.build }
    0.times { @item.variations.build }
    0.times { @item.downloads.build }
  end

  def create
    @item = Item.new(params[:item])

    if @item.save
      flash[:notice] = t('manage.items.create.success_msg')
      redirect_to manage_item_path(@item)
    else
      render :action => "new"
    end
  end

  def update
    if @item.update_attributes(params[:item])
      flash[:notice] = t('manage.items.update.success_msg')
      redirect_to manage_item_path(@item)
    else
      render :action => "edit"
    end
  end

  def destroy
    @item.destroy
    redirect_to(manage_products_path)
  end

  private

  def find_item
    @item = Item.find(params[:id], :include => [:pictures, :variations, :downloads])
  end
end
