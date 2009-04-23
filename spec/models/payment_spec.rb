require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Payment do

  it { should validate_presence_of(:token)}
  it { should validate_presence_of(:state)}
  it { should validate_presence_of(:method_type)}
  it { should validate_presence_of(:order)}

  it { should belong_to(:order) }

end

