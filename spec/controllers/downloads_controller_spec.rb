require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DownloadsController do

  describe "Not login" do
    describe "GET 'index'" do
      it "should be redirect to new_user_session_url" do
        get :index
        response.flash[:notice].should_not be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
    describe "GET 'index' using XMLHttpRequest" do
      it "should redirect to root_url" do
        xhr :get, :index
        response.flash[:notice].should_not be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
    describe "GET 'show'" do
      it "should be redirect to new_user_session_url" do
        get :show, :token => '123'
        response.flash[:notice].should_not be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "Login as user" do
    before(:each) do
      @user = User.make
      activate_authlogic
      UserSession.create(@user)
    end

    describe "GET 'index'" do
      it "should render template 'index'" do
        get :index
        assigns[:search].should_not be_nil
        assigns[:download_links].should_not be_nil
        assigns[:download_links_count].should == 0
        response.should be_success
        response.should render_template('index')
      end
    end

    describe "GET 'index' using XMLHttpRequest" do
      it "should fetch all download links when search criteria is null" do
#        request.env['HTTP_ACCEPT'] = 'application/json, text/javascript, */*'
#        request.env['HTTP_X_REQUESTED_WITH'] = 'XMLHttpRequest'
#        get :search_item
        xhr :get, :index
        assigns[:search].should_not be_nil
        assigns[:download_links].should_not be_nil
        assigns[:download_links_count].should == 0
        response.should be_success
        response.should render_template('index')
      end
    end

    describe "GET 'show'" do
      it "should render template 'show'" do
#        downloadlink = DownloadLink.make( :user_id => @user.id )
#        download = Download.make
        get :show, :token => "123"
        response.should be_success
      end
    end
  end
end
