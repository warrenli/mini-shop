require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Country do
  before(:each) do
    @country_attributes = {
      :id => 999,
      :name => 'Somewhere',
      :official_name => 'Somewhere Republic',
      :alpha_2_code => 'SW',
      :alpha_3_code => 'SMW'
    }
  end

  it "should create a new instance given valid attributes" do
     new_country = Country.create!(@country_attributes)
     new_country.name.should == @country_attributes[:name]
  end

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:alpha_3_code) }
  it { should validate_presence_of(:alpha_2_code) }
end
