require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
=begin
describe Subitem do
  before(:each) do
    @valid_item = {
      :code => "value for code1",
      :name => "value for name",
      :currency_code => "HKD",
      :price => 9.99,
      :is_published => false,
      :date_available => Time.now,
      :rank => 1,
      :description => "value for description"
    }
    @valid_subitem = {
      :code => "value for code2",
      :name => "value for name",
      :currency_code => "HKD",
      :price => 9.99,
      :is_published => false,
      :date_available => Time.now,
      :rank => 1,
      :description => "value for description"
    }
  end

  it "should create a new instance given valid attributes" do
    new_item = Item.create!(@valid_item)
    assert_difference('Item.count') do
      new_item.subitems << Subitem.new(@valid_subitem)
    end
    subitem = new_item.variations[0]
    subitem.should be_instance_of(Subitem)
    subitem.is_a?(Product).should be_true
    subitem.is_a?(Package).should be_false
    subitem.is_a?(Item).should be_true
    subitem.is_a?(Subitem).should be_true
    subitem.product_type.should == Product::SUBITEM
    subitem.type.should == 'Subitem'
  end

  it { should belong_to(:item) }
end
=end
