require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Picture do
  before(:each) do
    @valid_attributes = {
      :type => "Picture",
      :instance_id => 3,
      :position => 1,
      :data_file_name => "sample.png",
      :data_content_type => "image/png",
      :data_file_size => 1
    }
  end

  it "should create a new instance given valid attributes" do
    Picture.create!(@valid_attributes)
  end

  it { should belong_to(:product) }
end
