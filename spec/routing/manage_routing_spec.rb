require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ManageController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "manage", :action => "index").should == "/manage"
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/manage").should == {:controller => "manage", :action => "index"}
    end
  end
end

