require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OrderNumberGenerator do
  fixtures :order_number_generators

  it "should be initialized to 0" do
    generator1 = OrderNumberGenerator.next
    generator1.last_number.should == 1

    generator2 = OrderNumberGenerator.next
    generator2.last_number.should == 1
    generator2.should_not equal(generator1)
    generator2.should === generator1

    generator3 = OrderNumberGenerator.next
    generator3.last_number.should == 1
    generator3.should_not equal(generator1)
    generator3.should_not equal(generator2)
    generator3.should === generator1
    generator3.should === generator2
  end

  it "should be lock pessimistically" do
    generator1 = OrderNumberGenerator.next
    generator1.last_number.should == 1

    User.transaction do
      generator2 = OrderNumberGenerator.next
      generator2.save!
    end
    generator3 = OrderNumberGenerator.next
    generator3.last_number.should == (generator1.last_number + 1)

    generator3.should_not equal(generator1)
    generator3.should === generator1
  end

  it { should validate_numericality_of(:last_number) }
end
