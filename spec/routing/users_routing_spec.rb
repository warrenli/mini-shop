require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UsersController do
  describe "route generation" do
    it "should map #new_account" do
      route_for(:controller => "users", :action => "new").should == "/account/new"
    end

    it "should map #show_account" do
      route_for(:controller => "users", :action => "show").should == "/account"
    end

    it "should map #edit_account" do
      route_for(:controller => "users", :action => "edit").should == "/account/edit"
    end

    it "should map #update_account" do
      route_for(:controller => "users", :action => "update").should == {:path =>"/account", :method => :put}
    end

    it "should map #destroy_account" do
      route_for(:controller => "users", :action => "destroy").should == {:path =>"/account", :method => :delete}
    end
  end

  describe "route recognition" do
    it "should generate params for #new_account" do
      params_from(:get, "/account/new").should == {:controller => "users", :action => "new"}
    end

    it "should generate params for #create_account" do
      params_from(:post, "/account").should == {:controller => "users", :action => "create"}
    end

    it "should generate params for #show_account" do
      params_from(:get, "/account").should == {:controller => "users", :action => "show"}
    end

    it "should generate params for #edit_account" do
      params_from(:get, "/account/edit").should == {:controller => "users", :action => "edit"}
    end

    it "should generate params for #update_account" do
      params_from(:put, "/account").should == {:controller => "users", :action => "update"}
    end

    it "should generate params for #destroy_account" do
      params_from(:delete, "/account").should == {:controller => "users", :action => "destroy"}
    end
  end
end
