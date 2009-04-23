require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::UsersController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "admin/users", :action => "index").should == "/admin/users"
    end

    it "should map #new" do
      route_for(:controller => "admin/users", :action => "new").should == "/admin/users/new"
    end

    it "should map #show" do
      route_for(:controller => "admin/users", :action => "show", :id => "1").should == "/admin/users/1"
    end

    it "should map #edit" do
      route_for(:controller => "admin/users", :action => "edit", :id => "1").should == "/admin/users/1/edit"
    end

    it "should map #update" do
      route_for(:controller => "admin/users", :action => "update", :id => "1").should == {:path => "/admin/users/1", :method => :put}
    end

    it "should map #destroy" do
      route_for(:controller => "admin/users", :action => "destroy", :id => "1").should == {:path => "/admin/users/1", :method => :delete}
    end

    it "should map #change_role" do
      route_for(:controller => "admin/users", :action => "change_role", :id => "1").should == {:path => "/admin/users/1/change_role", :method => :put}
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/admin/users").should == {:controller => "admin/users", :action => "index"}
    end

    it "should generate params for #new" do
      params_from(:get, "/admin/users/new").should == {:controller => "admin/users", :action => "new"}
    end

    it "should generate params for #create" do
      params_from(:post, "/admin/users").should == {:controller => "admin/users", :action => "create"}
    end

    it "should generate params for #show" do
      params_from(:get, "/admin/users/1").should == {:controller => "admin/users", :action => "show", :id => "1"}
    end

    it "should generate params for #edit" do
      params_from(:get, "/admin/users/1/edit").should == {:controller => "admin/users", :action => "edit", :id => "1"}
    end

    it "should generate params for #update" do
      params_from(:put, "/admin/users/1").should == {:controller => "admin/users", :action => "update", :id => "1"}
    end

    it "should generate params for #destroy" do
      params_from(:delete, "/admin/users/1").should == {:controller => "admin/users", :action => "destroy", :id => "1"}
    end

    it "should generate params for #change_role" do
      params_from(:put, "/admin/users/1/change_role").should == {:controller => "admin/users", :action => "change_role", :id => "1"}
    end
  end
end
