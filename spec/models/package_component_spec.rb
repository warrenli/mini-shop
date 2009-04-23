require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PackageComponent do
  before(:each) do
    @item_attributes = {
      :code => "MM001",
      :name => "name for item MM001",
      :currency_code => "HKD",
      :price => 9.99,
      :rank => 1,
      :is_published => true,
      :date_available => Time.now,
      :position => 1,
      :description => "description for item MM001"
    }
    @subitem_attributes = {
      :code => "MM001-01",
      :name => "name for subitem MM001-01",
      :currency_code => "HKD",
      :price => 9.99,
      :rank => 1,
      :is_published => true,
      :position => 1
    }
    @package_attributes = {
      :code => "PAA001",
      :name => "Name of package PAA001",
      :currency_code => "HKD",
      :price => 9.99,
      :rank => 1,
      :is_published => true,
      :date_available => Time.now,
      :position => 1,
      :description => "Description for package PAA001"
    }
    @item2_attributes = {
      :code => "MM002",
      :name => "name for item",
      :currency_code => "HKD",
      :price => 9.99,
      :rank => 1,
      :is_published => false,
      :position => 1,
      :description => "Description for item MM002"
    }
  end

  it "should create a new instance given valid attributes" do
    new_item = Item.create!(@item_attributes)
    new_subitem = new_item.variations.create(@subitem_attributes)
    new_item.leaf?.should be_false
    new_subitem.leaf?.should be_true
    new_package = Package.create!(@package_attributes)
    new_item_2 = Item.create!(@item2_attributes)
    new_item_2.leaf?.should be_true

    new_package.items << new_subitem
    new_package.items.size.should == 1
    new_package.items[0].should eql(new_subitem)
    new_package.components.size.should == 1
    new_package.items.include?(new_subitem).should be_true

    new_package.components.create(:position => 3, :item_id => new_item_2.id)
    new_package.components.size.should == 2
  end

  it { should belong_to(:item) }
  it { should belong_to(:package) }
end

describe "Fixtures setup" do
  fixtures :products, :package_components

  it "should be true" do
    item_one = Product.find_by_id(1, :include => :variations )
    item_one.should be_instance_of(Item)
    item_one.is_a?(Product).should be_true
    item_one.is_a?(Item).should be_true
    item_one.is_a?(Package).should be_false
    item_one.variations.length.should == 2
    item_one.leaf?.should be_false

    var_one = item_one.variations[0]
    var_one.should be_instance_of(Item)
    var_one.is_a?(Product).should be_true
    var_one.is_a?(Item).should be_true
    var_one.is_a?(Package).should be_false
    var_one.parent_item.should eql(item_one)
    var_one.leaf?.should be_true

    item_two = Product.find_by_id(2)
    item_two.components.count.should == 1
    item_two.packages.count.should == 1
    item_two.leaf?.should be_true

    package_one = Product.find_by_id(3)
    package_one.should be_instance_of(Package)
    package_one.is_a?(Product).should be_true
    package_one.is_a?(Item).should be_false
    package_one.is_a?(Package).should be_true

    package_one.components.size.should == 2
    package_one.components[0].item.should == item_two
    package_one.components[1].item.should == var_one

    package_one.items.count.should == 2
    package_one.items.include?(var_one).should be_true
    package_one.items.include?(item_two).should be_true
    package_one.items.include?(var_one).should be_true
    package_one.items.include?(item_two).should be_true

    item_two.components.size.should == 1
    component_one = item_two.components[0]
    component_one.item.should eql(item_two)
    component_one.package.should eql(package_one)

    var_one.components.count.should == 1
    component_two = var_one.components[0]
    component_two.item.should eql(var_one)
    component_two.package.should eql(package_one)
  end

end

