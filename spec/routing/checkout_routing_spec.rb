require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CheckoutController do
  describe "route generation" do
    it "should map #start for '/checkout/start'" do
      route_for(:controller => "checkout", :action => "start").should == "/checkout/start"
    end

    it "should map #start for '/checkout/start'" do
      route_for(:controller => "checkout", :action => "start").should == {:path =>"/checkout/start", :method => :post}
    end

    it "should map #start for '/checkout/update_address'" do
      route_for(:controller => "checkout", :action => "update_address").should == "/checkout/update_address"
    end

    it "should map #start for '/checkout/update_address'" do
      route_for(:controller => "checkout", :action => "update_address").should == {:path =>"/checkout/update_address", :method => :put}
    end

    it "should map #start for '/checkout/payment'" do
      route_for(:controller => "checkout", :action => "payment").should == "/checkout/payment"
    end

    it "should map #start for '/checkout/review/:id'" do
      route_for(:controller => "checkout", :action => "start", :id => "abc").should == "/checkout/start/abc"
    end

    it "should map #start for '/checkout/ipn/:token'" do
      route_for(:controller => "checkout", :action => "ipn", :token => "abc").should == "/checkout/ipn/abc"
    end
  end

  describe "route recognition" do
    it "should generate params for #start" do
      params_from(:get, "/checkout/start").should == {:controller => "checkout", :action => "start"}
    end

    it "should generate params for #start" do
      params_from(:post, "/checkout/start").should == {:controller => "checkout", :action => "start"}
    end

    it "should generate params for #update_address" do
      params_from(:get, "/checkout/update_address").should == {:controller => "checkout", :action => "update_address"}
    end

    it "should generate params for #update_address" do
      params_from(:put, "/checkout/update_address").should == {:controller => "checkout", :action => "update_address"}
    end

    it "should generate params for #payment" do
      params_from(:get, "/checkout/payment").should == {:controller => "checkout", :action => "payment"}
    end

    it "should generate params for #review" do
      params_from(:get, "/checkout/review/abc").should == {:controller => "checkout", :action => "review", :id => "abc"}
    end

    it "should generate params for #ipn" do
      params_from(:get, "/checkout/ipn/abc").should == {:controller => "checkout", :action => "ipn", :token => "abc"}
    end
  end
end

