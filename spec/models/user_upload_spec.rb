require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UserUpload do
  before(:each) do
    @valid_attributes = {
      :position => 1,
      :data_file_name => "sample.txt",
      :data_content_type => "text/plain",
      :data_file_size => 1
    }
  end

  it "should create a new instance given valid attributes" do
    user_upload = UserUpload.create!(@valid_attributes)
    user_upload.data_file_name = nil
    user_upload.save
    lambda { user_upload.reload }.should raise_error(ActiveRecord::RecordNotFound)
  end

  it { should validate_numericality_of(:position) }
end
