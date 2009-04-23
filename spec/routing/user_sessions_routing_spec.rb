require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UserSessionsController do
  describe "route generation" do
    it "should map #new" do
      route_for(:controller => "user_sessions", :action => "new").should == "/user_session/new"
    end
    it "should map #show" do
      route_for(:controller => "user_sessions", :action => "show").should == "/user_session"
    end
    it "should map #edit" do
      route_for(:controller => "user_sessions", :action => "edit").should == "/user_session/edit"
    end
    it "should map #update" do
      route_for(:controller => "user_sessions", :action => "update").should == {:path =>"/user_session", :method => :put}
    end
    it "should map #destroy" do
      route_for(:controller => "user_sessions", :action => "destroy").should == {:path =>"/user_session", :method => :delete}
    end

  end

  describe "route recognition" do
    it "should generate params for #new" do
      params_from(:get, "/user_session/new").should == {:controller => "user_sessions", :action => "new"}
    end
    it "should generate params for #create" do
      params_from(:post, "/user_session").should == {:controller => "user_sessions", :action => "create"}
    end
    it "should generate params for #show" do
      params_from(:get, "/user_session").should == {:controller => "user_sessions", :action => "show"}
    end
    it "should generate params for #edit" do
      params_from(:get, "/user_session/edit").should == {:controller => "user_sessions", :action => "edit"}
    end
    it "should generate params for #update" do
      params_from(:put, "/user_session").should == {:controller => "user_sessions", :action => "update"}
    end
    it "should generate params for #destroy" do
      params_from(:delete, "/user_session").should == {:controller => "user_sessions", :action => "destroy"}
    end
  end
end
