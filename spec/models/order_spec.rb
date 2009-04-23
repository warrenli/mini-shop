require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Order do
  fixtures :users, :orders, :order_number_generators, :order_lines, :products, :countries

  it { should validate_presence_of(:state) }
  it { should validate_presence_of(:currency_code) }

  it { should validate_numericality_of(:total) }
  it { should validate_numericality_of(:product_total) }
  it { should validate_numericality_of(:tax_total) }
  it { should validate_numericality_of(:shipping_total) }
  it { should validate_numericality_of(:discount_total) }

#  it { should validate_uniqueness_of(:order_num) }
#  it { should validate_inclusion_of(:currency_code, :in => ["HKD", "USD"]) }

  it { should belong_to(:user) }
  it { should have_many(:order_lines) }
  it { should have_many(:order_product_lines) }
  it { should have_many(:payments) }
  it { should have_one(:billing_address) }
  it { should have_one(:shipping_address) }
  it { should have_many(:download_links) }

  describe "Test billing address and shipping address" do
    it "should be able " do
      usa = countries(:usa)
      address_attributes = {
          :street_1         => "123 Fake Street",
          :street_2         => "Apartment 456",
          :city             => "Somewhere",
          :postal_code      => "12345",
          :country_id       => usa.id
        }
      order = Order.new
      order.billing_address.should be_nil
      order.shipping_address.should be_nil
      order.billing_address_attributes = address_attributes
      order.save
      order.billing_address.country.should == usa

      order.shipping_address.should be_nil
      order.shipping_address_attributes = address_attributes
      order.save

      order.shipping_address.street_1.should == order.billing_address.street_1
      order.shipping_address.street_2.should == order.billing_address.street_2
      order.shipping_address.city.should == order.billing_address.city
      order.shipping_address.postal_code.should == order.billing_address.postal_code
      order.shipping_address.country.should == order.billing_address.country
      order.shipping_address.should_not equal(order.billing_address)
    end
  end

  describe "Test instance methods" do
    it "should be able to reset token" do
        order = Order.find(1)
        order.generate_order_number!
        order.token.should be_nil
        order.reset_token!
        token_one = order.token
        token_one.should_not be_nil
        order.reset_token!
        order.token.should_not be_nil
        token_one.should_not == order.token
    end

    it "should be able to empty an order" do
      order = Order.find(1)
      item_one = Product.find(1)
      order.order_product_lines.count.should == 1
      order.empty?.should be_false
      order.empty!
      order.order_product_lines.count.should == 0
      order.empty?.should be_true
    end

    it "should indicate can_destroy?" do
      order = Order.find(1)
      order.order_num.should be_nil
      order.can_destroy?.should be_true
      order.generate_order_number!
      order.order_num.should_not be_nil
      order.can_destroy?.should be_false
    end

    it "should be able to add product correctly" do
      order = Order.find(1)
      item_one = Product.find(1)
      order.order_product_lines.count.should == 1

      # Add two qty to existing line
      orderline_one = order.order_product_lines.by_product(item_one)[0]
      orderline_one.quantity.should == 1
      orderline_one.product.should == item_one
      assert_no_difference('OrderProductLine.count') do
        order.add_product(item_one, 2)
      end
      orderline_one.reload
      orderline_one.quantity.should == 3

      # Add a new line to order
      package_one = Product.find(3)
      package_one.should_not be_nil
      order.order_product_lines.count.should == 1
      assert_difference('OrderProductLine.count') do
        order.add_product(package_one, 4)
      end
      order.reload
      order.order_product_lines.count.should == 2
      orderline_two = order.order_product_lines.by_product(package_one)[0]
      orderline_two.product.should == package_one
      orderline_two.quantity.should == 4
      orderline_two.price.should == package_one.price
    end

    it "should have provided correct price values" do
      order = Order.find(1)
      order.order_product_lines.length.should == 1
      orderline = order.order_product_lines[0]
      orderline.line_total.should eql(9.99)

      order.display_product_total.should =~ /HKD/
      order.display_product_total.should =~ /9.99/

      order.display_total.should =~ /HKD/
      order.display_total.should =~ /9.99/
    end

    it "should have auto remove product line when quantity is zero" do
      order = Order.find(1)
      order.order_product_lines.count.should == 1
      orderline = order.order_product_lines[0]
      orderline.quantity.should == 1

      order.order_product_lines_attributes = [{:id => orderline.id, :quantity => 0}]
      order.save

      order.order_product_lines.count.should == 0
    end
  end

  describe 'Test state transition' do
    # initialized -> assigned -> pending -> paid -> shipped
    # initialized -> assigned -> pending -> voided
    # initialized -> assigned -> paid -> shipped
    # initialized -> assigned -> voided
    #
    it "A new order should be 'initialized'" do
      myorder = Order.new
      myorder.initialized?.should be_true
      myorder.checked_out?.should be_false

      myorder.can_assign?.should be_false
      myorder.can_checkout?.should be_false
      myorder.can_pay?.should be_false
      myorder.can_ship?.should be_false
      myorder.can_void?.should be_false

      myorder.ip_address.should be_nil
      myorder.user.should be_nil
      myorder.order_num.should be_nil
    end

    it "An order should be assigned when it has captured ip_address, user, order_num and assign!" do
      user = User.make
      myorder = Order.make
      myorder.can_assign?.should be_false

      myorder.ip_address = "127.0.0.1"
      myorder.user = user
      myorder.generate_order_number!
      myorder.order_num.should_not be_nil
      myorder.can_assign?.should be_true
      myorder.checked_out?.should be_false

      myorder.assign!
      myorder.assigned?.should be_true
      myorder.checked_out?.should be_false

      myorder.can_assign?.should be_false
      myorder.can_checkout?.should be_false
      myorder.can_pay?.should be_false
      myorder.can_ship?.should be_false
      myorder.can_void?.should be_true
    end

    it "An assigned order should be voided when void!" do
      myorder = Order.make(:ip_address => "127.0.0.1", :user_id=>1, :order_num=>"123", :state=>"assigned")
      myorder.assigned?.should be_true
      myorder.can_void?.should be_true
      myorder.checked_out?.should be_false

      myorder.void!
      myorder.voided?.should be_true
      myorder.checked_out?.should be_false

      myorder.can_assign?.should be_false
      myorder.can_checkout?.should be_false
      myorder.can_pay?.should be_false
      myorder.can_ship?.should be_false
      myorder.can_void?.should be_false
    end

    it "An assigned order should be pending when checkout! after save_total_from_order_lines!" do
      myorder = Order.make(:ip_address => "127.0.0.1", :user_id=>1, :order_num=>"123", :state=>"assigned")
      myorder.assigned?.should be_true
      myorder.can_checkout?.should be_false
      myorder.checked_out?.should be_false

      myorder.empty?.should be_true
      item = products(:item_one_var1)
      myorder.add_product(item)
      myorder.empty?.should be_false
      myorder.save_total_from_order_lines!
      myorder.billing_address = BillingAddress.new({
          :street_1         => "123 Fake Street",
          :street_2         => "Apartment 456",
          :city             => "Somewhere",
          :postal_code      => "12345",
          :country_id       => 840
         })
      myorder.can_checkout?.should be_true

      myorder.checkout!
      myorder.pending?.should be_true
      myorder.checked_out?.should be_true

      myorder.can_assign?.should be_false
      myorder.can_checkout?.should be_false
      myorder.can_pay?.should be_true
      myorder.can_ship?.should be_false
      myorder.can_void?.should be_true
    end

    it "A pending order should be voided when void!" do
      myorder = Order.make(:ip_address => "127.0.0.1", :user_id=>1, :order_num=>"123",
                           :state=>"pending", :total=>0.0, :product_total=>0.0, :has_checked_out=>1)
      myorder.pending?.should be_true
      myorder.can_void?.should be_true
      myorder.checked_out?.should be_true

      myorder.void!
      myorder.voided?.should be_true
      myorder.checked_out?.should be_true

      myorder.can_assign?.should be_false
      myorder.can_checkout?.should be_false
      myorder.can_pay?.should be_false
      myorder.can_ship?.should be_false
      myorder.can_void?.should be_false
    end

    it "An assigned order should be paid when pay! after save_total_from_order_lines!" do
      myorder = Order.make(:ip_address => "127.0.0.1", :user_id=>1, :order_num=>"123", :state=>"assigned")
      myorder.assigned?.should be_true
      myorder.can_pay?.should be_false
      myorder.checked_out?.should be_false

      myorder.empty?.should be_true
      item = products(:item_one_var1)
      myorder.add_product(item)
      myorder.empty?.should be_false
      myorder.save_total_from_order_lines!
      myorder.billing_address = BillingAddress.new({
          :street_1         => "123 Fake Street",
          :street_2         => "Apartment 456",
          :city             => "Somewhere",
          :postal_code      => "12345",
          :country_id       => 840
         })
      myorder.can_pay?.should be_true

      myorder.pay!
      myorder.paid?.should be_true
      myorder.checked_out?.should be_true

      myorder.can_assign?.should be_false
      myorder.can_checkout?.should be_false
      myorder.can_pay?.should be_false
      myorder.can_ship?.should be_true         # assume ship_ok? is true
      myorder.can_void?.should be_false
    end

    it "A pending order should be paid when pay!" do
      myorder = Order.make(:ip_address => "127.0.0.1", :user_id=>1, :order_num=>"123",
                           :state=>"pending", :total=>0.0, :product_total=>0.0, :has_checked_out=>1)
      myorder.pending?.should be_true
      myorder.can_pay?.should be_true           # assume fully_paid? is true
      myorder.checked_out?.should be_true

      myorder.pay!
      myorder.paid?.should be_true
      myorder.checked_out?.should be_true

      myorder.can_assign?.should be_false
      myorder.can_checkout?.should be_false
      myorder.can_pay?.should be_false
      myorder.can_ship?.should be_true         # assume ship_ok? is true
      myorder.can_void?.should be_false
    end

    it "A paid order should be shipped when ship!" do
      myorder = Order.make(:ip_address => "127.0.0.1", :user_id=>1, :order_num=>"123",
                           :state=>"paid", :total=>0.0, :product_total=>0.0, :has_checked_out=>1)
      myorder.paid?.should be_true
      myorder.can_ship?.should be_true         # assume ship_ok? is true
      myorder.checked_out?.should be_true

      myorder.ship!
      myorder.shipped?.should be_true
      myorder.checked_out?.should be_true

      myorder.can_assign?.should be_false
      myorder.can_checkout?.should be_false
      myorder.can_pay?.should be_false
      myorder.can_ship?.should be_false
      myorder.can_void?.should be_false
    end
  end

  it "fetch_subtotal, fetch_all_subtotals, fetch_aggregate_total"

end
