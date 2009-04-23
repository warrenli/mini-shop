class OrderNumberGenerator < ActiveRecord::Base
  validates_numericality_of :last_number, :integer_only => true, :greater_than_or_equal_to => 0

  def self.next
    generator = OrderNumberGenerator.find(1, :lock => true)
    generator.last_number += 1
    generator
  end

=begin
    Usage:
        order.transaction do
          generator = OrderNumberGenerator.next
          order.number = genarator.last_number
          generator.save!
        end
=end

end
