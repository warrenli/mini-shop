require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DownloadLink do
  before(:each) do
    @valid_attributes = {
      :user_upload_id  => 1,
      :user_id         => 1,
      :order_num       => 'abc',
      :order_id        => 1,
      :order_line_id   => 1,
      :product_id      => 1,
      :token           => '123'
    }
  end

  it "should create a new instance given valid attributes" do
    DownloadLink.create!(@valid_attributes)
  end

  it { should belong_to(:user) }
  it { should belong_to(:order) }
  it { should belong_to(:order_product_line) }
  it { should belong_to(:download) }
  it { should belong_to(:item) }

  it { should validate_presence_of(:order_num) }
end
