require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe StoreController do
  describe "route generation" do
    it "should map #index for '/'" do
      route_for(:controller => "store", :action => "index").should == "/"
    end
    it "should map #show for '/store/show/code'" do
      route_for(:controller => "store", :action => "show", :code => "code").should == "/store/show/code"
    end
    it "should map #cart for '/cart'" do
      route_for(:controller => "store", :action => "view_cart").should == "/cart"
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/").should == {:controller => "store", :action => "index"}
    end
    it "should generate params for #index" do
      params_from(:get, "/store").should == {:controller => "store", :action => "index"}
    end
    it "should generate params for #index" do
      params_from(:get, "/store/index").should == {:controller => "store", :action => "index"}
    end
    it "should generate params for #show" do
      params_from(:get, "/store/show/code").should == {:controller => "store", :action => "show", :code => "code"}
    end
    it "should generate params for #view_cart" do
      params_from(:get, "/cart").should == {:controller => "store", :action => "view_cart"}
    end
  end
end

