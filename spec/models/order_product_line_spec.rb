require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OrderProductLine do
  it { should belong_to(:product) }
  it { should have_many(:download_links) }
  it { should validate_numericality_of(:price) }

  describe "Test instance methods" do
    fixtures :users, :orders, :products

    before(:each) do
      @valid_attributes = {
          :code => 'TNT001',
          :name => 'A product',
          :description => 'Some product',
          :price => 9.99,
          :quantity => 1,
          :product_id => 1
        }
      @order_one = Order.find(1)
      @new_order_line = @order_one.order_product_lines.create(@valid_attributes)
    end

    it "should have print_sequence = 1 after executed before_save" do
     @new_order_line.print_sequence.should == 1
    end

    it "should have provided correct price values" do
      @new_order_line.display_unit_price.should =~ /HKD/
      @new_order_line.display_unit_price.should =~ /9.99/
      @new_order_line.line_total.should eql(9.99)
      @new_order_line.display_line_total =~ /HKD/
      @new_order_line.display_line_total =~ /9.99/

      @new_order_line.price = 0.00
      @new_order_line.display_unit_price.should =~ /HKD/
      @new_order_line.display_unit_price.should =~ /0.00/
      @new_order_line.line_total.should eql(0.00)
      @new_order_line.display_line_total =~ /HKD/
      @new_order_line.display_line_total =~ /0.00/

      @new_order_line.price = 0.01
      @new_order_line.quantity = 5
      @new_order_line.display_unit_price.should =~ /HKD/
      @new_order_line.display_unit_price.should =~ /0.01/
      @new_order_line.line_total.should eql(0.05)
      @new_order_line.display_line_total =~ /HKD/
      @new_order_line.display_line_total =~ /0.05/
    end
  end

end

