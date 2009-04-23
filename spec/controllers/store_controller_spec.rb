require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe StoreController do

  fixtures :products, :package_components, :users

  describe "GET 'index'" do

    it "should be render template 'show'" do
      # 1st time
      request.session[:order_id].should be_nil
      session["user_credentials_id"].should be_nil
      session["user_credentials"].should be_nil
      get 'index'
      response.should be_success
      response.should render_template('show')

      assigns[:product].should_not be_nil
      assigns[:page_title].should_not be_nil

      assigns[:products].should_not be_nil
      assigns[:user].should be_nil

      order = assigns[:order]
      session[:order_id].should == order.id
      order.user.should be_nil
    end

    it "should have order assign to user after login" do
      # clear session
      request.session[:order_id] = nil
      # login
      example_user = User.find(3)
      example_user.should_not be_nil
      activate_authlogic
      UserSession.create(example_user)

      get 'index'
      response.should be_success
      response.should render_template('show')

      assigns[:products].should_not be_nil
      assigns[:user].should == example_user

      order = assigns[:order]
      session[:order_id].should == order.id
      order.user.should == example_user
    end
  end


  describe "GET 'show'" do
    it "should be render 'show' template" do
      get 'show'
      response.should be_success
      response.should render_template('show')

      assigns[:product].should_not be_nil

      assigns[:products].should_not be_nil
      assigns[:order].should_not be_nil
      session[:order_id].should == assigns[:order].id
    end

    it "should get the correct product using valid product.code" do
      item_one = Product.find_by_id(1)
      get 'show', :code => item_one.code
      response.should be_success
      response.should render_template('show')

      assigns[:product].code.should == item_one.code

      assigns[:products].should_not be_nil
      assigns[:order].should_not be_nil
      session[:order_id].should == assigns[:order].id
    end

    describe "using XMLHttpRequest" do
      it "should get the correct product using valid product.code" do
        item_one = Product.find_by_id(1)
        xhr :get, :show, :code  => item_one.code
        response.should be_success
        response.should render_template('show')

        assigns[:product].code.should == item_one.code

        assigns[:products].should_not be_nil
        assigns[:order].should_not be_nil
        session[:order_id].should == assigns[:order].id
      end
    end
  end


  describe "POST 'add_to_cart'" do
    before(:each) do
      request.session[:order_id] = nil
    end

    it "should add update order line and redirect to cart_path" do
      get 'index'
      current_order = assigns[:order]
      current_order.order_lines.count.should == 0
      session[:order_id].should == current_order.id
      item_one = Product.find_by_id(1)

      # Add a new product to order
      lambda {
        post "add_to_cart", :product => {:id => item_one.id, :qty => 2}
      }.should change(OrderProductLine, :count).by(1)
      response.should be_redirect
      response.should redirect_to(cart_path)
      current_order.reload
      current_order.order_lines.count.should == 1
      current_order.order_lines[0].quantity.should == 2

      # Add the same product again
      lambda {
        post "add_to_cart", :product => {:id => item_one.id, :qty => 5}
      }.should_not change(OrderProductLine, :count)
      response.should be_redirect
      response.should redirect_to(cart_path)
      current_order.reload
      current_order.order_lines.count.should == 1
      current_order.order_lines[0].quantity.should == 7

      assigns[:products].should_not be_nil
      assigns[:order].should_not be_nil
      session[:order_id].should == assigns[:order].id
    end
  end


  describe "POST 'update_cart'" do
    before(:each) do
      request.session[:order_id] = nil
    end

    it "should update quantity when new quanity >0" do
      get 'index'
      current_order = assigns[:order]
      current_order.order_lines.count.should == 0
      session[:order_id].should == current_order.id
      item_one = Product.find_by_id(1)
      post "add_to_cart", :product => {:id => item_one.id, :qty => 1}
      current_order.order_lines.count.should == 1
      current_line = current_order.order_lines[0]
      current_line.quantity.should == 1
      current_line.product.should == item_one

      post "update_cart", 
        :order=>{ "order_product_lines_attributes" =>[ {"id" => current_line.id, "quantity" => "8"}] }
      response.should be_redirect
      response.should redirect_to(cart_path)
      response.flash[:notice].should_not be_nil
      current_order.order_lines.count.should == 1
      current_line.reload
      current_line.quantity.should == 8

      assigns[:products].should_not be_nil
      assigns[:order].should_not be_nil
      session[:order_id].should == assigns[:order].id
    end

    it "should remove the order line when new quanity = 0" do
      get 'index'
      current_order = assigns[:order]
      current_order.order_lines.count.should == 0
      session[:order_id].should == current_order.id
      item_one = Product.find_by_id(1)
      post "add_to_cart", :product => {:id => item_one.id, :qty => 1}
      current_order.order_lines.count.should == 1
      current_line = current_order.order_lines[0]
      current_line.quantity.should == 1
      current_line.product.should == item_one

      post "update_cart", 
        :order=>{ "order_product_lines_attributes" =>[ {"id" => current_line.id, "quantity" => "0"}] }
      response.should be_redirect
      response.should redirect_to(cart_path)
      response.flash[:notice].should_not be_nil
      current_order.order_lines.count.should == 0

      assigns[:products].should_not be_nil
      assigns[:order].should_not be_nil
      session[:order_id].should == assigns[:order].id
    end

    it "should be unchanged when new quanity < 0" do
      get 'index'
      current_order = assigns[:order]
      current_order.order_lines.count.should == 0
      session[:order_id].should == current_order.id
      item_one = Product.find_by_id(1)
      post "add_to_cart", :product => {:id => item_one.id, :qty => 3}
      current_order.order_lines.count.should == 1
      current_line = current_order.order_lines[0]
      current_line.quantity.should == 3
      current_line.product.should == item_one

      post "update_cart",
        :order=>{ "order_product_lines_attributes" =>[ {"id" => current_line.id, "quantity" => "-5"}] }
      response.should be_redirect
      response.should redirect_to(cart_path)
      response.flash[:notice].should_not be_nil
      current_order.order_lines.count.should == 1
      current_line.reload
      current_line = current_order.order_lines[0]
      current_line.quantity.should == 3

      assigns[:products].should_not be_nil
      assigns[:order].should_not be_nil
      session[:order_id].should == assigns[:order].id
    end

  end


  describe "POST 'empty_cart'" do
    before(:each) do
      request.session[:order_id] = nil
    end

    it "should destroy all order_lines from the cart" do
      get 'index'
      current_order = assigns[:order]
      current_order.order_lines.count.should == 0
      session[:order_id].should == current_order.id
      Product.available(Time.now).each do |prod|
        post "add_to_cart", :product => {:id => prod.id, :qty => 1}
      end
      current_order.order_lines.count.should == 2

      post :empty_cart
      current_order.order_lines.count.should == 0
      response.should be_success
      response.should render_template("view_cart")

      assigns[:products].should_not be_nil
      assigns[:order].should_not be_nil
      session[:order_id].should == assigns[:order].id
    end
  end
end

