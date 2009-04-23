require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Package do
  before(:each) do
    @valid_attributes = {
      :code => "PP001",
      :name => "Name of package PP001",
      :currency_code => "HKD",
      :price => 9.99,
      :rank => 1,
      :is_published => true,
      :date_available => Time.now,
      :position => 1,
      :description => "This is a package PP001"
    }
  end

  it "should create a new instance given valid attributes" do
    new_package = Package.create!(@valid_attributes)
    new_package.should be_instance_of(Package)
    new_package.is_a?(Product).should be_true
    new_package.is_a?(Package).should be_true
    new_package.product_type.should == Product::PACKAGE
    new_package.class.name.should == 'Package'
  end

  it { should have_many(:components) }
  it { should have_many(:items) }
end

