ActionController::Routing::Routes.draw do |map|

  map.manage '/manage', :controller => 'manage', :action => 'index'
  map.namespace(:manage) do |manage|
    manage.resources :products, :only => :index
    manage.resources :items
    manage.resources :packages, :collection => { :search_item => :get }
    manage.resources :orders, :only => [:index, :show, :destroy],
                              :member => { :pay => :put, :ship => :put, :void => :put, :resend_receipt => :put }
  end

  map.namespace(:admin) do |admin|
    admin.resources :users, :member => { :change_role => :put }
  end

  map.register '/register/:activation_code', :controller => 'activations', :action => 'new'
  map.activate '/activate/:id', :controller => 'activations', :action => 'create'
#  map.resources :users
  map.resource :account, :controller => 'users'
  map.resources :password_resets
  map.resource :user_session
  map.change_email 'verify_email/:request_code', :controller => 'change_email', :action => 'edit'

  map.store '/store/show/:code', :controller => 'store', :action => 'show'
  map.cart  '/cart', :controller => 'store', :action => 'view_cart'

  map.payment '/checkout/payment', :controller => 'checkout', :action => 'payment'

  map.order '/order/:order_num', :controller => 'orders', :action =>'show'

  map.download '/downloads/:token', :controller => 'downloads', :action => 'show'

  map.ipn '/checkout/ipn/:token', :controller => 'checkout', :action => 'ipn'

  # Home Page
  map.root :controller => 'store', :action => 'index'

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  # Catch all url
  map.connect '*path', :controller => 'store', :action => 'index'
end
