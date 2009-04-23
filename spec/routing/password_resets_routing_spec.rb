require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PasswordResetsController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "password_resets", :action => "index").should == "/password_resets"
    end
    it "should map #new" do
      route_for(:controller => "password_resets", :action => "new").should == "/password_resets/new"
    end
    it "should map #show" do
      route_for(:controller => "password_resets", :action => "show", :id => "1").should == "/password_resets/1"
    end
    it "should map #edit" do
      route_for(:controller => "password_resets", :action => "edit", :id => "1").should == "/password_resets/1/edit"
    end
    it "should map #update" do
      route_for(:controller => "password_resets", :action => "update", :id => "1").should == {:path =>"/password_resets/1", :method => :put}
    end
    it "should map #destroy" do
      route_for(:controller => "password_resets", :action => "destroy", :id => "1").should == {:path =>"/password_resets/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/password_resets").should == {:controller => "password_resets", :action => "index"}
    end
    it "should generate params for #new" do
      params_from(:get, "/password_resets/new").should == {:controller => "password_resets", :action => "new"}
    end
    it "should generate params for #create" do
      params_from(:post, "/password_resets").should == {:controller => "password_resets", :action => "create"}
    end
    it "should generate params for #show" do
      params_from(:get, "/password_resets/1").should == {:controller => "password_resets", :action => "show", :id => "1"}
    end
    it "should generate params for #edit" do
      params_from(:get, "/password_resets/1/edit").should == {:controller => "password_resets", :action => "edit", :id => "1"}
    end
    it "should generate params for #update" do
      params_from(:put, "/password_resets/1").should == {:controller => "password_resets", :action => "update", :id => "1"}
    end
    it "should generate params for #destroy" do
      params_from(:delete, "/password_resets/1").should == {:controller => "password_resets", :action => "destroy", :id => "1"}
    end
  end
end
