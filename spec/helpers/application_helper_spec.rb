require File.dirname(__FILE__) + '/../spec_helper'
include ApplicationHelper


describe ApplicationHelper do
=begin
  describe "title" do
    it "should set @content_for_title"  do
      title("Welcome").should be_true
      @content_for_title.should eql("Welcome")
      show_title?.should be_true
    end
  end

  describe "show_title?" do
    it "should return true" do
      title("Welcome").should be_true
      @content_for_title.should eql("Welcome")
      show_title?.should be_true
    end
  end
=end
  describe "title" do
    it "should set @page_title" do
      title('hello').should be_nil
      @page_title.should eql('hello')
    end

    it "should output container if set" do
      title('hello', :h2).should have_tag('h2', 'hello')
    end
  end

  describe "flash_messages" do
    it "should return notice" do
      flash[:notice] = "Hello World"
      flash_messages =~ /Hello World/         # <div id="flash-notice">Hello World</div>
      flash_messages =~ /div id="flash-notice"/
    end
  end

  describe "locale_link" do
    it "to be tested" do
      I18n.locale         = 'zh-HK'
      locale_link("zh-HK", "中文").should eql("中文 (zh-HK)")
      I18n.locale         = 'en-US'
      locale_link("en-US", "English").should eql("English (en-US)")
    end
  end

  describe "show_product_link" do
    it "should return no link for nil object" do
      show_product_link(Object.new).should =~ /XXX/
    end
    it "should return link for item object" do
      item = Item.find(1)
      show_product_link(item).should =~ /<a href=\"\/manage\/items\/1\">Show<\/a>/
    end
    it "should return link for package object" do
      package = Package.find(3)
      show_product_link(package).should =~ /<a href=\"\/manage\/packages\/3\">Show<\/a>/
    end
  end

  describe "edit_product_link" do
    it "should return no link for nil object" do
      edit_product_link(Object.new).should =~ /XXX/
    end
    it "should return link for item object" do
      item = Item.find(1)
      edit_product_link(item).should =~ /<a href=\"\/manage\/items\/1\/edit\">Edit<\/a>/
    end
    it "should return link for package object" do
      package = Package.find(3)
      edit_product_link(package).should =~ /<a href=\"\/manage\/packages\/3\/edit\">Edit<\/a>/
    end
  end

  describe "destroy_product_link" do
    before(:each) do
      I18n.locale = 'en-US'
    end
    it "should return no link for nil object" do
      destroy_product_link(Object.new).should =~ /XXX/
    end
    it "should return link for item object" do
      item = Item.find(1)
      destroy_product_link(item).should =~ />Destroy<\/a>/
    end
    it "should return link for package object" do
      package = Package.find(3)
      destroy_product_link(package).should =~ />Destroy<\/a>/
    end
  end
  describe "search_product_link" do
    it "should return search link" do
      search_product_link.should =~ /<a href=\"\/manage\/products\">/
    end
  end
end

