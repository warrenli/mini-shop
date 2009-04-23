class StoreController < ApplicationController
  before_filter :find_user
  before_filter :find_recent_products
  before_filter :prepare_cart

  def index
    @product = @products[0]
    @page_title = t('store.index.welcome_msg')
    render :action => "show"
  end

  def show
    @product = Product.available(Time.zone.now).find_by_code(params[:code]) if params[:code]
    if @product.blank?
      @product = @products[0]
    end
    unless @product.blank?
      @product.update_attributes({ :rank => @product.rank + 1 })
      @meta_keywords += ", " + @product.display_name.split(" ").join(", ")
      @meta_description << ", " << @product.display_name << ", " << @product.get_description
    end
  end

  def add_to_cart
    if request.post?
      #     if params[:product]
      #       puts "***************************"
      #       puts "ID:" + params[:product][:id]
      #       puts "QTY:" + params[:product][:qty]
      #       puts "***************************"
      #     end
      #
      # Assuming store front already filtered products using date_available
      # So not going to check date_available again
      product = Product.published.find(params[:product][:id]) if params[:product][:id]
      @order.add_product(product, params[:product][:qty].to_i) if product and params[:product][:qty]
    end
    redirect_to :action => "view_cart"
  end

  def view_cart
  end

  def update_cart
    if request.post?
      #    puts "***************************"
      #    puts params.to_yaml
      #    puts "***************************"
      if @order.update_attributes(params[:order])
        flash[:notice] = t('store.update_cart.success_msg')
      else
        flash[:notice] = t('store.update_cart.failed_msg')
      end
    end
    redirect_to :action => "view_cart"
  end

  def empty_cart
    @order.empty! if request.post?
    render :action => "view_cart"
  end

  def sub_layout
    'store_front'
  end

  private

  def find_user
    @user = @current_user
  end

  def find_recent_products
    @products = Product.available(Time.zone.now).limit(15)
  end

  def prepare_cart
    unless @order
      unless @user
        @order = Order.shopping.find(:first,
                  :conditions => [ "id = ?", session[:order_id] ])
      else
        @order = Order.shopping.find(:first,
                  :conditions => [ "id = ? and user_id = ?", session[:order_id], @user.id ])
      end
    end

    unless @order
      @order = Order.new
      @order.currency_code = APP_CONFIG[:currency]
      @order.save!
      session[:order_id] = @order.id
    end

#    @order.update_attributes({:user => @user}) if (@user and @order.user.nil?)
    if (@user and @order.user.nil?)
       @order.user = @user
       @order.save!
    end

    unless @order.user == @user
      session[:order_id] = nil
      @order = nil
      prepare_cart
    end
  end

  def expresscheckout
  end
end
