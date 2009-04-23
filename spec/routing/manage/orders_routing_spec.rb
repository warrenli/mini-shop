require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Manage::OrdersController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "manage/orders", :action => "index").should == "/manage/orders"
    end

    it "should map #show" do
      route_for(:controller => "manage/orders", :action => "show", :id => "1").should == "/manage/orders/1"
    end

    it "should map #destroy" do
      route_for(:controller => "manage/orders", :action => "destroy", :id => "1").should == {:path => "/manage/orders/1", :method => :delete}
    end

    it "should map #pay" do
      route_for(:controller => "manage/orders", :action => "pay", :id => "1").should == {:path => "/manage/orders/1/pay", :method => :put}
    end

    it "should map #ship" do
      route_for(:controller => "manage/orders", :action => "ship", :id => "1").should == {:path => "/manage/orders/1/ship", :method => :put}
    end

    it "should map #void" do
      route_for(:controller => "manage/orders", :action => "void", :id => "1").should == {:path => "/manage/orders/1/void", :method => :put}
    end

    it "should map #resend_receipt" do
      route_for(:controller => "manage/orders", :action => "resend_receipt", :id => "1").should == {:path => "/manage/orders/1/resend_receipt", :method => :put}
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/manage/orders").should == {:controller => "manage/orders", :action => "index"}
    end

    it "should generate params for #show" do
      params_from(:get, "/manage/orders/1").should == {:controller => "manage/orders", :action => "show", :id => "1"}
    end

    it "should generate params for #destroy" do
      params_from(:delete, "/manage/orders/1").should == {:controller => "manage/orders", :action => "destroy", :id => "1"}
    end

    it "should generate params for #pay" do
      params_from(:put, "/manage/orders/1/pay").should == {:controller => "manage/orders", :action => "pay", :id => "1"}
    end

    it "should generate params for #ship" do
      params_from(:put, "/manage/orders/1/ship").should == {:controller => "manage/orders", :action => "ship", :id => "1"}
    end

    it "should generate params for #void" do
      params_from(:put, "/manage/orders/1/void").should == {:controller => "manage/orders", :action => "void", :id => "1"}
    end

    it "should generate params for #resend_receipt" do
      params_from(:put, "/manage/orders/1/resend_receipt").should == {:controller => "manage/orders", :action => "resend_receipt", :id => "1"}
    end
  end
end

