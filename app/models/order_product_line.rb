class OrderProductLine < OrderLine
  belongs_to :product
  has_many   :download_links, :foreign_key => "order_line_id"

  validates_numericality_of :price, :greater_than_or_equal_to => 0.0

  named_scope :by_product,  lambda {|product| {:conditions => ["product_id = ?", product.id]}}

  def before_save
    self.print_sequence = 1
  end
end
