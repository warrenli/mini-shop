require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Download do
  before(:each) do
    @valid_attributes = {
      :type => "Download",
      :instance_id => 4,
      :position => 1,
      :data_file_name => "sample.pdf",
      :data_content_type => "application/pdf",
      :data_file_size => 1
    }
  end

  it "should create a new instance given valid attributes" do
    Download.create!(@valid_attributes)
  end

  it { should belong_to(:item) }
  it { should have_many(:download_links) }
end
