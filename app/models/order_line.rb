class OrderLine < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper

  belongs_to :order

  validates_presence_of:print_sequence, :description, :price, :quantity
  validates_numericality_of :price
  validates_numericality_of :quantity, :only_integer => true, :greater_than_or_equal_to => 0
  validates_numericality_of :print_sequence, :only_integer => true, :greater_than_or_equal_to => 0

  # default_scope is getting order_lines for invoice/receipt printing
  default_scope  :order => "print_sequence ASC"
  named_scope :limit,     lambda { |num| { :limit => num } }

  def display_unit_price
    self.order.currency_code + " " + number_to_currency(self.price,:unit=>'')
  end

  def line_total
    self.price * self.quantity
  end

  def display_line_total
    self.order.currency_code + " " + number_to_currency(line_total,:unit=>'')
  end
end
