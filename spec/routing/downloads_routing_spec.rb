require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DownloadsController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "downloads", :action => "index").should == "/downloads"
    end
    it "should map #show" do
      route_for(:controller => "downloads", :action => "show", :token => "123").should == "/downloads/123"
    end

  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/downloads").should == {:controller => "downloads", :action => "index"}
    end
    it "should generate params for #show" do
      params_from(:get, "/downloads/123").should == {:controller => "downloads", :action => "show", :token => "123"}
    end
  end
end

