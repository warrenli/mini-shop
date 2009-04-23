require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ActivationsController do
  describe "route generation" do
    it "should map #new" do
      route_for(:controller => "activations", :action => "new", :activation_code => "xxx").should == "/register/xxx"
    end
    
    it "should map #create" do
      route_for(:controller => "activations", :action => "create", :id => "xxx").should == "/activate/xxx"
    end
  end

  describe "route recognition" do
    it "should generate params for #new" do
      params_from(:get, "/register/xxx").should == {:controller => "activations", :action => "new", :activation_code => "xxx"}
    end

    it "should generate params for #create" do
      params_from(:get, "/activate/xxx").should == {:controller => "activations", :action => "create", :id => "xxx"}
    end
  end
end

