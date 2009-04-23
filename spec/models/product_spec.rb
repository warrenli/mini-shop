require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Product do
  before(:each) do
    @valid_attributes = {
      :code => "P000",
      :name => "Name of product P000",
      :currency_code => "HKD",
      :price => 9.99,
      :rank => 1,
      :is_published => true,
      :date_available => Time.now,
      :position => 1,
      :description => "This is a product P000"
    }
    @new_product = Product.create!(@valid_attributes)
  end

  it "should create a new instance given valid attributes" do
    @new_product.product_type.should == Product::PRODUCT
#    @new_product.type.should == 'Product'
  end

  it "should display currency code with price value" do
    @new_product.display_price.should =~ /9.99/
  end

  it "should display free of charge when price = 0.00" do
    @new_product.price = 0.00
    @new_product.display_price.should =~ /HKD/
    @new_product.display_price.should =~ /0.00/
  end

  it "should show name correctly" do
    @new_product.display_name.should == @new_product.name
  end

  it "should description same as get_description" do
    @new_product.get_description.should == @new_product.description
  end

  it { should validate_presence_of(:code) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:currency_code) }
  it { should validate_presence_of(:price) }
  it { should validate_numericality_of(:price) }
  it { should validate_numericality_of(:rank) }
  it { should validate_numericality_of(:position) }
#  it { should validate_presence_of(:date_available) }

#  it { should allow_mass_assignment_of(:code, :name) }
#  it { should validate_uniqueness_of(:code) }
#  it { should_allow_values_for :currency_code, "HKD", "USD" }
#  it { should allow_value("HKD").for(:currency_code) }
#  it { should validate_inclusion_of(:currency_code, :in => ["HKD", "USD"]) }

  it { should have_many(:order_product_lines) }

end

