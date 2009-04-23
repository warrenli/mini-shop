require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OrdersController do
  describe "route generation" do
    it "should map #show" do
      route_for(:controller => "orders", :action => "show", :order_num => "1").should == "/order/1"
    end
  end

  describe "route recognition" do
    it "should generate params for #show" do
      params_from(:get, "/order/1").should == {:controller => "orders", :action => "show", :order_num => "1"}
    end

  end
end

