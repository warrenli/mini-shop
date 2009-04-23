require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Item do
  before(:each) do
    @valid_item = {
      :code => "N001",
      :name => "Item N001",
      :currency_code => "HKD",
      :price => 9.99,
      :rank => 1,
      :is_published => true,
      :date_available => Time.now,
      :position => 1,
      :description => "This is item N001"
    }
    @valid_sub_item = {
      :code => "N001-01",
      :name => "color green",
      :currency_code => "HKD",
      :price => 8.88,
      :rank => 1,
      :is_published => true,
      :position => 1
    }
    @valid_sub_item_2 = {
      :code => "N001-02",
      :name => "color brown",
      :currency_code => "HKD",
      :price => 7.77,
      :rank => 1,
      :is_published => true,
      :position => 2
    }
  end

  it "should create a new instance given valid attributes" do
    new_item = Item.create!(@valid_item)
    new_item.should be_instance_of(Item)
    new_item.is_a?(Product).should be_true
    new_item.is_a?(Item).should be_true
    new_item.product_type.should == Product::ITEM
    new_item.variations.size.should == 0
    new_item.variation?.should be_false
    new_item.leaf?.should be_true

    Item.leaf.include?(new_item).should be_true

    sub_item = new_item.variations.create(@valid_sub_item)
    sub_item.product_type.should == Product::VARIATION
    sub_item.variation?.should be_true
    sub_item.parent_item.should eql(new_item)
    sub_item.leaf?.should be_true
    sub_item.display_name.should =~/#{new_item.name}/
    sub_item.display_name.should =~/#{sub_item.name}/
    sub_item.get_description.should == new_item.description
    sub_item.display_price.should =~/HKD 8.88/
    sub_item.get_first_picture.should be_nil

    #new_item.reload
    new_item.variations.include?(sub_item).should be_true
    new_item.variations.size.should == 1
    new_item.variation?.should be_false
    new_item.leaf?.should be_false

    new_item.display_price.should =~/HKD 8.88/
    sub_item_2 = new_item.variations.create(@valid_sub_item_2)
    new_item.display_price.should =~/HKD 7.77 - 8.88/

    new_item.get_first_picture.should be_nil

    Item.leaf.include?(new_item).should be_false
  end

  it { should have_many(:variations) }
  it { should belong_to(:parent_item) }
  it { should have_many(:components) }
  it { should have_many(:packages) }
  it { should have_many(:downloads) }
  it { should have_many(:download_links) }

#  it { should have_many(:subitems) }
end

