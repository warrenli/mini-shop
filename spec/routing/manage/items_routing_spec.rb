require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Manage::ItemsController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "manage/items", :action => "index").should == "/manage/items"
    end

    it "should map #new" do
      route_for(:controller => "manage/items", :action => "new").should == "/manage/items/new"
    end

    it "should map #create" do
      route_for(:controller => "manage/items", :action => "create").should == {:path => "/manage/items", :method => :post}
    end

    it "should map #show" do
      route_for(:controller => "manage/items", :action => "show", :id => "1").should == "/manage/items/1"
    end

    it "should map #edit" do
      route_for(:controller => "manage/items", :action => "edit", :id => "1").should == "/manage/items/1/edit"
    end

    it "should map #update" do
      route_for(:controller => "manage/items", :action => "update", :id => "1").should == {:path => "/manage/items/1", :method => :put}
    end

    it "should map #destroy" do
      route_for(:controller => "manage/items", :action => "destroy", :id => "1").should == {:path => "/manage/items/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/manage/items").should == {:controller => "manage/items", :action => "index"}
    end

    it "should generate params for #new" do
      params_from(:get, "/manage/items/new").should == {:controller => "manage/items", :action => "new"}
    end

    it "should generate params for #create" do
      params_from(:post, "/manage/items").should == {:controller => "manage/items", :action => "create"}
    end

    it "should generate params for #show" do
      params_from(:get, "/manage/items/1").should == {:controller => "manage/items", :action => "show", :id => "1"}
    end

    it "should generate params for #edit" do
      params_from(:get, "/manage/items/1/edit").should == {:controller => "manage/items", :action => "edit", :id => "1"}
    end

    it "should generate params for #update" do
      params_from(:put, "/manage/items/1").should == {:controller => "manage/items", :action => "update", :id => "1"}
    end

    it "should generate params for #destroy" do
      params_from(:delete, "/manage/items/1").should == {:controller => "manage/items", :action => "destroy", :id => "1"}
    end
  end
end
