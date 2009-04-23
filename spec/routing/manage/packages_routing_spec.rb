require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Manage::PackagesController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "manage/packages", :action => "index").should == "/manage/packages"
    end

    it "should map #new" do
      route_for(:controller => "manage/packages", :action => "new").should == "/manage/packages/new"
    end

    it "should map #create" do
      route_for(:controller => "manage/packages", :action => "create").should == {:path => "/manage/packages", :method => :post}
    end

    it "should map #show" do
      route_for(:controller => "manage/packages", :action => "show", :id => "1").should == "/manage/packages/1"
    end

    it "should map #edit" do
      route_for(:controller => "manage/packages", :action => "edit", :id => "1").should == "/manage/packages/1/edit"
    end

    it "should map #update" do
      route_for(:controller => "manage/packages", :action => "update", :id => "1").should == {:path => "/manage/packages/1", :method => :put}
    end

    it "should map #destroy" do
      route_for(:controller => "manage/packages", :action => "destroy", :id => "1").should == {:path => "/manage/packages/1", :method => :delete}
    end

    it "should map #search_item" do
      route_for(:controller => "manage/packages", :action => "search_item").should == {:path => "/manage/packages/search_item", :method => :get}
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/manage/packages").should == {:controller => "manage/packages", :action => "index"}
    end

    it "should generate params for #new" do
      params_from(:get, "/manage/packages/new").should == {:controller => "manage/packages", :action => "new"}
    end

    it "should generate params for #create" do
      params_from(:post, "/manage/packages").should == {:controller => "manage/packages", :action => "create"}
    end

    it "should generate params for #show" do
      params_from(:get, "/manage/packages/1").should == {:controller => "manage/packages", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/manage/packages/1/edit").should == {:controller => "manage/packages", :action => "edit", :id => "1"}
    end

    it "should generate params for #update" do
      params_from(:put, "/manage/packages/1").should == {:controller => "manage/packages", :action => "update", :id => "1"}
    end

    it "should generate params for #destroy" do
      params_from(:delete, "/manage/packages/1").should == {:controller => "manage/packages", :action => "destroy", :id => "1"}
    end

    it "should generate params for #search_item" do
      params_from(:get, "/manage/packages/search_item").should == {:controller => "manage/packages", :action => "search_item"}
    end
  end
end
