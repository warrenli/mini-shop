require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Address do
  fixtures :countries
  before(:each) do
    @address_attributes = {
      :street_1         => "123 Fake Street",
      :street_2         => "Apartment 456",
      :city             => "Somewhere",
      :postal_code      => "12345",
    }
  end

  it { should validate_presence_of(:addressable_id) }
  it { should validate_presence_of(:addressable_type) }
  it { should validate_presence_of(:street_1) }
  it { should validate_presence_of(:city) }
  it { should validate_presence_of(:postal_code) }
  it { should validate_presence_of(:country) }

  it { should belong_to(:addressable)}
  it { should belong_to(:country)}

=begin
  it "should create a new instance given valid attributes" do
     usa = countries(:usa)
     usa.name.should == "United States"
     new_order = Order.create!
     new_order.billing_address = BiAddress.new({
      :street_1         => "123 Fake Street",
      :street_2         => "Apartment 456",
      :city             => "Somewhere",
      :postal_code      => "12345",
      :country_id          => usa.id
     })
     new_order.save!
     new_order.billing_address.country.should == usa
     new_order.billing_address.city.should == "Somewhere"
     new_order.billing_address.single_line.should =~ /United States/
  end
=end

end
