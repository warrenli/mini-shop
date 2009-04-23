require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OrderLine do
  it { should validate_presence_of(:print_sequence) }
  it { should validate_presence_of(:description) }
  it { should validate_presence_of(:price) }
  it { should validate_presence_of(:quantity) }

  it { should validate_numericality_of(:price) }
  it { should validate_numericality_of(:quantity) }
  it { should validate_numericality_of(:print_sequence) }

  it { should belong_to(:order) }

  describe "Test instance methods" do
    fixtures :orders, :order_lines
    before (:each) do
      @order = Order.find(1)
      @order.order_product_lines.length.should == 1
    end

    it "should display_unit_price correctly" do
      @orderline = @order.order_product_lines[0]
      @orderline.line_total.should eql(9.99)
      @orderline.display_unit_price.should =~ /HKD/
      @orderline.display_unit_price.should =~ /9.99/
    end

    it "should give line_total" do
      @orderline = @order.order_product_lines[0]
      @orderline.line_total.should eql(9.99)
      @orderline.line_total.should == (@orderline.quantity * @orderline.price)
    end

    it "should display_line_total correctly" do
      @orderline = @order.order_product_lines[0]
      @orderline.line_total.should eql(9.99)
      @orderline.display_line_total.should =~ /HKD/
      @orderline.display_line_total.should =~ /9.99/
    end
  end
end
