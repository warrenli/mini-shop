require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ChangeEmailController do
  describe "route generation" do
    it "should map #edit" do
      route_for(:controller => "change_email", :action => "edit", :request_code => "xxx").should == "/verify_email/xxx"
    end
  end

  describe "route recognition" do
    it "should generate params for #edit" do
      params_from(:get, "/verify_email/xxx").should == {:controller => "change_email", :action => "edit", :request_code => "xxx"}
    end
  end
end

