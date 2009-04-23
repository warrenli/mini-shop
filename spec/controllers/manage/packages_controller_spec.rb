require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Manage::PackagesController do
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
        post :create, :package => {}, :html => { :multipart => true }
        response.flash[:notice].should_not be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
    describe "PUT 'update'" do
      it "should be redirect to new_user_session_url" do
        put :update, :id => 99, :package => {}, :html => { :multipart => true }
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
    describe "GET 'search_item' using XMLHttpRequest" do
      it "should redirect to root_url" do
        xhr :get, :search_item
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
        put :create, :package => {}, :html => { :multipart => true }
        response.flash[:notice].should_not be_nil
        response.should redirect_to(root_url)
      end
    end
    describe "PUT 'update'" do
      it "should redirect to root_url" do
        put :update, :id => 99, :package => {}, :html => { :multipart => true }
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
    describe "GET 'search_item' using XMLHttpRequest" do
      it "should redirect to root_url" do
        xhr :get, :search_item
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
      @package_one = Product.find_by_id(3)
      item_one = Product.find_by_id(1)
      fdata = fixture_file_upload('spacer.png', 'image/png')
      @valid_package = {
          "code" => "PP001",
          "name" => "Package PP001",
          "currency_code" => "HKD",
          "price" => "88.09",
          "rank" => "1",
          "is_published" => "1",
          "date_available" => Time.now.beginning_of_day.to_s,
          "description" => "This is package PP001",
          "pictures_attributes"=>[
            {"position" => "1",
             "data"=> fdata
            }],
          "components_attributes"=>[
            {"item_id"=>item_one.id.to_s, "position"=>"1"
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
      it "should return an item record" do
        get :show, :id => @package_one
        response.should be_success
        response.should render_template('show')
        assigns[:package].should eql(@package_one)
      end
    end
    describe "GET 'new'" do
      it "should render 'new' template" do
        get :new
        response.should be_success
        response.should render_template('new')
        new_package = assigns[:package]
        new_package.should_not be_nil
        new_package.pictures.size.should == 1
        new_package.components.size.should == 0
        assigns[:search].should_not be_nil
        assigns[:items].should_not be_nil
        assigns[:items].size.should == 0
        assigns[:item_count].should == 0
      end
    end
    describe "GET 'edit'" do
      it "should render 'edit' template" do
        get :edit, :id => @package_one
        response.should be_success
        response.should render_template('edit')
        assigns[:package].should eql(@package_one)
        assigns[:search].should_not be_nil
        assigns[:items].should_not be_nil
        assigns[:items].size.should == 0
        assigns[:item_count].should == 0
      end
    end
    describe "POST 'create'" do

    end
    describe "POST 'create' with valid params" do
      it "should redirect to 'manage_package_path'" do
        assert_difference 'Package.count' do
          post :create, :package => @valid_package, :html => { :multipart => true }
        end
        new_package = assigns[:package]
        new_package.should_not be_nil
        response.flash[:notice].should_not be_nil
        response.should redirect_to(manage_package_path(new_package))
      end
    end
    describe "POST 'create' with invalid params" do
      it "should render 'new' template" do
        assert_no_difference 'Package.count' do
          post :create, :package => { "code"=>"" }, :html => { :multipart => true }
        end
        assigns[:package].should_not be_nil
        response.should be_success
        response.should render_template('new')
      end
    end
    describe "PUT 'update' with valid params" do
      it "should redirect_to 'manage_package_path'" do
        put :update, :id => @package_one.id, 
            :package => { "name"=>"Hello World"},:html => { :multipart => true }
        existing_package = assigns[:package]
        existing_package.should_not be_nil
        response.flash[:notice].should_not be_nil
        response.should redirect_to(manage_package_path(existing_package))
      end
    end
    describe "PUT 'update' with invalid_params" do
      it "should render 'edit' template" do
        put :update, :id => @package_one.id, :package => { "code"=>"" }, :html => { :multipart => true }
        assigns[:package].should_not be_nil
        response.should be_success
        response.should render_template('edit')
      end
    end
    describe "DELETE 'destroy'" do
      it "should be success, redirect to manage_products_url" do
        assert_difference 'Package.count', -1 do
          delete :destroy, :id => @package_one.id
        end
        response.should redirect_to(manage_products_url)
      end
    end
    describe "GET 'search_item' using XMLHttpRequest" do
      it "should fetch all items when search criteria is null" do
#        request.env['HTTP_ACCEPT'] = 'application/json, text/javascript, */*'
#        request.env['HTTP_X_REQUESTED_WITH'] = 'XMLHttpRequest'
#        get :search_item
        xhr :get, :search_item
        response.should be_success
        assigns[:search].should_not be_nil
        assigns[:items].should_not be_nil
        assigns[:items].size.should > 0
        assigns[:item_count].should > 0
      end
      it "should fetch an item when search criteria equals variation's item code" do
        item_one_var1 = Product.find_by_id(4)
        xhr :get, :search_item,
            :search=>{ "conditions" => { "code_begins_with" => item_one_var1.code } }
        response.should be_success
        assigns[:search].should_not be_nil
        assigns[:items].should_not be_nil
        assigns[:items].size.should == 1
        assigns[:item_count].should == 1
      end
    end
  end
end

