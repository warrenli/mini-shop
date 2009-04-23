require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Manage::ItemsController do
  fixtures :all

  describe "Not login" do
    describe "GET 'index'" do
      it "should be redirect to new_user_session_url" do
        get :index
        response.flash[:notice].should_not be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
    describe "GET 'show'" do
      it "should be redirect to new_user_session_url" do
        get :show, :id => 99 
        response.flash[:notice].should_not be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
    describe "GET 'new'" do
      it "should be redirect to new_user_session_url" do
        get :new
        response.flash[:notice].should_not be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
    describe "GET 'edit'" do
      it "should be redirect to new_user_session_url" do
        get :edit, :id => 99
        response.flash[:notice].should_not be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
    describe "POST 'create'" do
      it "should be redirect to new_user_session_url" do
        post :create, :item => {}, :html => { :multipart => true }
        response.flash[:notice].should_not be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
    describe "PUT 'update'" do
      it "should be redirect to new_user_session_url" do
        put :update, :id => 99, :item => {}, :html => { :multipart => true }
        response.flash[:notice].should_not be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
    describe "DELETE 'destroy'" do
      it "should be redirect to new_user_session_url" do
        delete :destroy, :id =>99
        response.flash[:notice].should_not be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "Login as general user" do
    before(:each) do
      @user = User.make
      activate_authlogic
      UserSession.create(@user)
    end
    describe "GET 'index'" do
      it "should redirect to root_url" do
        get :index
        response.flash[:notice].should_not be_nil
        response.should redirect_to(root_url)
      end
    end
    describe "GET 'show'" do
      it "should redirect to root_url" do
        get :show, :id => 99
        response.flash[:notice].should_not be_nil
        response.should redirect_to(root_url)
      end
    end
    describe "GET 'new'" do
      it "should redirect to root_url" do
        get :new
        response.flash[:notice].should_not be_nil
        response.should redirect_to(root_url)
      end
    end
    describe "GET 'edit'" do
      it "should redirect to root_url" do
        get :edit, :id => 99
        response.flash[:notice].should_not be_nil
        response.should redirect_to(root_url)
      end
    end
    describe "POST 'create'" do
      it "should redirect to root_url" do
        put :create, :item => {}, :html => { :multipart => true }
        response.flash[:notice].should_not be_nil
        response.should redirect_to(root_url)
      end
    end
    describe "PUT 'update'" do
      it "should redirect to root_url" do
        put :update, :id => 99, :item => {}, :html => { :multipart => true }
        response.flash[:notice].should_not be_nil
        response.should redirect_to(root_url)
      end
    end
    describe "DELETE 'destroy'" do
      it "should redirect to root_url" do
        delete :destroy, :id => 99
        response.flash[:notice].should_not be_nil
        response.should redirect_to(root_url)
      end
    end
  end

  describe "Login as site_admin" do
    before(:each) do
      @user = User.make
      @user.has_role 'site_admin'
      @user.roles[0].to_s.should eql('Is_Site_admin')
      activate_authlogic
      UserSession.create(@user)
      @item_one = Product.find_by_id(1)
      fdata = fixture_file_upload('spacer.png', 'image/png')
      @valid_item = {
          "code" => "TT001",
          "name" => "Item TT001",
          "currency_code" => "HKD",
          "price" => "0.0",
          "rank" => "1",
          "is_published" => "1",
          "date_available" => Time.now.beginning_of_day.to_s,
          "description" => "This is item TT001",
          "variations_attributes"=>[
            {"code" => "TT001-01",
             "name" => "color green",
             "currency_code" => "HKD",
             "price" => "19.99",
             "position" => "1"
            }],
          "pictures_attributes"=>[
            {"position" => "1",
             "data"=> fdata
            }],
          "downloads_attributes"=>[
            {"position" => "1",
             "data"=> fdata
            }]
      }
    end
    describe "GET 'index'" do
      it "should return products and product_count" do
        get :index
        response.should redirect_to(manage_products_url)
      end
    end
    describe "GET 'show'" do
      it "should render 'show' template" do
        get :show, :id => @item_one
        response.should be_success
        response.should render_template('show')
        assigns[:item].should eql(@item_one)
      end
    end
    describe "GET 'new'" do
      it "should render 'new' template" do
        get :new
        response.should be_success
        response.should render_template('new')
        new_item = assigns[:item]
        new_item.should_not be_nil
        new_item.pictures.size.should == 1
        new_item.downloads.size.should == 1
        new_item.variations.size.should == 0
      end
    end
    describe "GET 'edit'" do
      it "should render 'edit' template" do
        get :edit, :id => @item_one
        response.should be_success
        response.should render_template('edit')
        assigns[:item].should eql(@item_one)
      end
    end
    describe "POST 'create' with valid params" do
      it "should redirect to 'manage_item_path'" do
        assert_difference 'Item.count', 2 do
          # new item includes a variation
          post :create, :item => @valid_item, :html => { :multipart => true }
        end
        new_item = assigns[:item]
        new_item.should_not be_nil
        response.flash[:notice].should_not be_nil
        response.should redirect_to(manage_item_path(new_item))
      end
    end
    describe "POST 'create' with invalid params" do
      it "should render 'new' template" do
        assert_no_difference 'Item.count' do
          post :create, :item => { "code"=>"" }, :html => { :multipart => true }
        end
        assigns[:item].should_not be_nil
        response.should be_success
        response.should render_template('new')
      end
    end
    describe "PUT 'update' with valid params" do
      it "should redirect_to 'manage_item_path'" do
        put :update, :id => @item_one.id, 
            :item => { "name"=>"Hello World"},:html => { :multipart => true }
        existing_item = assigns[:item]
        existing_item.should_not be_nil
        response.flash[:notice].should_not be_nil
        response.should redirect_to(manage_item_path(existing_item))
      end
    end
    describe "PUT 'update' with invalid_params" do
      it "should render 'edit' template" do
        put :update, :id => @item_one.id, :item => { "code"=>"" }, :html => { :multipart => true }
        assigns[:item].should_not be_nil
        response.should be_success
        response.should render_template('edit')
      end
    end
    describe "DELETE 'destroy'" do
      it "should be success, redirect to manage_products_url" do
        # Item has 2 variations so destroy it actually remove 3 items
        @item_one.variations.count.should == 2
        assert_difference 'Item.count', -3 do
          delete :destroy, :id => @item_one.id
        end
        response.should redirect_to(manage_products_url)
      end
    end
  end
end

