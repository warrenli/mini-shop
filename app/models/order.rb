class Order < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper

  before_save :update_product_lines

  validates_presence_of :state
  validates_presence_of :currency_code
  validates_presence_of :order_num, :if => :order_num_required?

  validates_inclusion_of :currency_code, :in => %w(HKD USD)

  attr_protected :state, :has_checked_out, :currency_code, :ip_address, :user_id, :order_num,
                 :total, :product_total, :tax_total, :shipping_total, :discount_total

  validates_numericality_of :total,          :greater_than_or_equal_to => 0.0,
                            :if => Proc.new{|x| !x.total.nil?}
  validates_numericality_of :product_total,  :greater_than_or_equal_to => 0.0,
                            :if => Proc.new{|x| !x.product_total.nil?}
  validates_numericality_of :tax_total,      :greater_than_or_equal_to => 0.0,
                            :if => Proc.new{|x| !x.tax_total.nil?}
  validates_numericality_of :shipping_total, :greater_than_or_equal_to => 0.0,
                            :if => Proc.new{|x| !x.shipping_total.nil?}
  validates_numericality_of :discount_total, :less_than_or_equal_to => 0.0,
                            :if => Proc.new{|x| !x.discount_total.nil?}

  belongs_to :user
  has_many   :order_lines, :dependent => :destroy, :order => "print_sequence ASC, updated_at DESC"

  has_many   :order_product_lines, :dependent => :destroy, :order => "created_at DESC"
  accepts_nested_attributes_for :order_product_lines, :allow_destroy => true

  has_many   :products, :through => :order_product_lines

  has_many   :payments
  accepts_nested_attributes_for :payments
  has_one   :completed_payment, :class_name =>"Payment", :conditions => "payments.state = 'completed'"

  # It may have other kinds of order lines for discounts, handling charge, tax
  # has_many :order_tax_lines
  # has_many :order_shipping_lines
  # has_many :order_discount_lines

  has_many   :download_links, :dependent => :destroy

  has_one :billing_address,  :class_name=> "BillingAddress", :as => :addressable, :dependent => :destroy
  accepts_nested_attributes_for :billing_address, :allow_destroy => true

  has_one :shipping_address, :class_name=> "ShippingAddress", :as => :addressable, :dependent => :destroy
  accepts_nested_attributes_for :shipping_address, :allow_destroy => true

  default_scope  :order => "created_at DESC",
                 :include => [:user, :billing_address, :shipping_address, :completed_payment, :order_lines ]
  named_scope :by_number, lambda {|num| {:conditions => ["order_num = ?", num]}}
  named_scope :by_token,  lambda {|key| {:conditions => ["token = ?", key]}}
  named_scope :by_state,  lambda {|state|  {:conditions => ["state = ?", state]}}
  named_scope :by_user,   lambda {|user|   {:conditions => ["user_id = ?", user.id]}}
  named_scope :shopping,     :conditions => ["state in ('initialized','assigned') and has_checked_out = 0"]
  named_scope :checked_out,  :conditions => ["has_checked_out = 1"]
  named_scope :not_checked_out,  :conditions => ["has_checked_out = 0"]
  named_scope :limit,     lambda { |num| { :limit => num } }
  named_scope :obsolete_by, lambda { |dy|   {:conditions=> ["state in ('initialized','assigned') and has_checked_out = 0 and order_num is null and updated_at < ?", dy.days.ago.beginning_of_day.to_s(:db)]} }


  state_machine :initial => 'initialized' do
    after_transition  :to => :initialized, :do => lambda {|order| order.update_attribute(:has_checked_out, false)}

    after_transition  :to => :pending,     :do => :after_pending

    after_transition  :to => :paid,        :do => :after_paid

    after_transition  :pending => :voided, :do => :after_voided

    after_transition  :to => :shipped,     :do => :after_shipped

    # Must have user_id and order_num assigned to order
    # Order cannot be destroyed or deleted
    event :assign do
      transition :initialized => :assigned, :if => :assign_ok?
    end

    # For asynchronouse payment process, 
    # when payment request has been issued, waiting for the response
    # order is freezed for payment processing
    event :checkout do
      transition :assigned => :pending, :if => :can_pay_now?
    end

    # For synchronouse payment, :assigned => :paid
    # For asynchronouse payment, :assigned => :pending => :paid
    event :pay do
      transition :from => :assigned, :to => :paid, :if => :can_pay_now?
      transition :from => :pending,  :to => :paid, :if => :fully_paid?
    end

    # ship the ordered products
    event :ship do
      transition :paid => :shipped, :if => :ship_ok?
    end

    # For asynchronouse payment, if payment is rejected, :pending => :voided
    # If an order never checked out(i.e. has_checked_out == false), :assigned => :voided
    event :void do
     transition [:assigned, :pending] => :voided, :if => :void_ok?
    end

    # No state for voiding an order after fully paid
  end

  def empty?
   self.order_lines.count == 0
  end

  def empty!
    self.order_lines.destroy_all
  end

  def checked_out?
    self.has_checked_out
  end

  def can_destroy?
    self.order_num.blank?   # Once order_num is generated, order cannot be destroyed
  end

  def add_product(product, quantity=1)
     return if quantity < 1
     current_line = self.order_product_lines.find(
            :first, 
            :conditions => ["product_id = ?", product.id])
     if current_line
        current_line.update_attributes(
            :product_id     => product.id,
            :code           => product.code,
            :name           => product.display_name,
            :description    => product.get_description,
            :price          => product.price,
            :quantity       => current_line.quantity + quantity)
     else
         line_attributes =
           {:product_id     => product.id,
            :code           => product.code,
            :name           => product.display_name,
            :description    => product.get_description,
            :price          => product.price,
            :quantity       => quantity}
        self.order_product_lines.create(line_attributes)
     end
  end

  def basic_options
    options = { "desc"             => 'Order No.: ' + self.order_num,
    #            "invnum"           => self.token,         # hash form of order_num
                "currencycode"     => self.currency_code,
                "amt"              => self.total,
                "itemamt"          => self.product_total,
                "handlingamt"      => 0,
                "insuranceamt"     => 0,
                "shippingamt"      => 0,
                "shipdiscamt"      => 0,
                "taxamt"           => 0,
                "custom"           => self.token   }
    self.order_product_lines.each_with_index do |line, index|
      options.merge!({
      #          "l_number#{index}" => line.code,          # don't expose it to PayPal
      #          "l_desc#{index}"   => line.description,   # Too long for PayPal processing
                "l_name#{index}"   => line.name,
                "l_taxamt#{index}" => 0,
                "l_amt#{index}"    => line.price,
                "l_qty#{index}"    => line.quantity
       })
    end
    options
  end

  def ship_options
    options = { "shiptoname"           => self.user.fullname,
                "shiptostreet"         => self.shipping_address.street_1,
                "shiptostreet2"        => self.shipping_address.street_2,
                "shiptocity"           => self.shipping_address.city,
              # "shiptostate"          => "",
                "shiptozip"            => self.shipping_address.postal_code,
                "shiptocountrycode"    => self.shipping_address.country.alpha_2_code
    }
    options
  end

  # parameters for SetExpressCheckout request
  def set_ec_options
    options = { }
    options.merge!(basic_options)

    # options.merge!({ :pagestyle => '' })

    # Choose 1 out of 3 options
    options.merge!({ "noshipping"  => '1' })           #NoShipping
    #options.merge!({ "reqconfirmshipping" => '1' })    #ReqConfirmShipping
    #options.merge!({ "addressoverride"    => '1' })     #AddressOverride

    # No need to provide address when selling downloadable products only
    # unless self.shipping_address.nil?
    #    options.merge!(ship_options)
    # end

    options
  end

  def current_payment
     self.payments.by_token(self.token).first
  end

  # For MySQL only
  def fetch_subtotal(key="OrderProductLine")
    conn = ActiveRecord::Base.connection();
    sql = "SELECT sum(price*quantity) AS line_total FROM order_lines WHERE order_id = #{self.id} AND type = '#{key}' LIMIT 1"
    value = conn.execute(sql).fetch_row;
    value;
  end
  # For MySQL only
  def fetch_all_subtotals
    conn = ActiveRecord::Base.connection();
    sql = "SELECT type, sum(price*quantity) AS line_total, sum(price) As price_total FROM order_lines WHERE order_id = #{self.id} GROUP BY type"
    keys, line_total, price_total  = conn.execute(sql).fetch_row;
    [ keys, line_total, price_total ]
  end
  # For MySQL only
  def fetch_aggregate_total
    conn = ActiveRecord::Base.connection();
    sql = "SELECT sum(price*quantity) AS line_total FROM order_lines WHERE order_id = #{self.id} LIMIT 1"
    value = conn.execute(sql).fetch_row;
    value;
  end

  def display_product_total
    if self.has_checked_out and self.product_total
      subtotal = self.product_total
    else
      subtotal = calculate_product_total
    end
    self.currency_code + " " + number_to_currency(subtotal,:unit=>'')
  end

  def display_total
    if self.has_checked_out and self.total
      total = self.total
    else
      total = calculate_total
    end
    self.currency_code + " " + number_to_currency(total,:unit=>'')
  end

  def generate_order_number!
    return if self.order_num
    local_generator = Object.new
    self.transaction do
       local_generator = OrderNumberGenerator.next
       self.order_num = Time.now.utc.strftime("%y%m%d-") + local_generator.last_number.to_s.rjust(6,'0')
       self.placed_at = Time.now.utc
       local_generator.save!
       self.save!
    end
  end

  def save_total_from_order_lines!
    #  determine tax
    #  determine shipping charge
    #  determine discount amounts
    self.product_total = calculate_product_total
    self.total = self.product_total
    self.total += self.tax_total      unless self.tax_total.nil?
    self.total += self.shipping_total unless self.shipping_total.nil?
    self.total += self.discount_total unless self.discount_total.nil?
    self.save!
  end

  def reset_token!
    self.token = Digest::SHA1.hexdigest(Time.now.to_s.split(//).sort_by {rand}.join + self.order_num)
    self.save!
  end

  def generate_download_links!
    self.order_product_lines.each do |line|
      case line.product.product_type
      when Product::ITEM, Product::VARIATION
        item = line.product
        item.downloads.each do |download|
          self.download_links.create(
            :user => self.user,
            :order_num => self.order_num,
            :order_product_line => line,
            :download => download,
            :item => item,
            :token => Digest::SHA1.hexdigest(Time.now.to_s.split(//).sort_by {rand}.join + download.id.to_s + self.order_num)
          )
        end
      when Product::PACKAGE
        items = line.product.items.published
        items.each do |item|
          item.downloads.each do |download|
            self.download_links.create(
              :user => self.user,
              :order_num => self.order_num,
              :order_product_line => line,
              :download => download,
              :item => item,
              :token => Digest::SHA1.hexdigest(Time.now.to_s.split(//).sort_by {rand}.join + download.id.to_s + self.order_num)
            )
          end
        end
      else
        raise "Unknow product type"
      end
    end
  end

  private

  def order_num_required?
    if self.initialized?
      false
    else
      true
    end
  end

  def update_product_lines
    self.order_product_lines.each do |product_line|
      OrderProductLine.destroy(product_line.id) if product_line.quantity == 0
    end
  end

  def calculate_product_total
    subtotal = 0.0
    self.order_product_lines.each do |product_line|
      subtotal += product_line.line_total
    end
    subtotal
  end 

  def calculate_total
    # total = product_total + discount_total + tax_total + handling_charge_total
    calculate_product_total
  end

  def anonymous?
    # validates_presence_of :ip_address, :user_id, :order_num
    (self.ip_address.nil? or self.user.nil? or self.order_num.nil?)
  end

  def some_totals_is_nil?
    ( self.total.nil? or self.product_total.nil? )
  end

  def assign_ok?
    !anonymous?
  end

  def can_pay_now?
    !(some_totals_is_nil? or empty? or self.total < 0.0 or self.billing_address.nil?)
  end

  def fully_paid?
    true
  end

  def ship_ok?
    true
  end

  def void_ok?
    # Ensure order has not been paid
    true
  end

  def after_pending
    self.update_attribute(:has_checked_out, true)
    #  send email, order received but payment is not confirmed
    OrderMailer.deliver_receipt(self)
  end

  def after_paid
    self.update_attribute(:has_checked_out, true)
    #  send email
    OrderMailer.deliver_receipt(self)
    #
    generate_download_links!
    # self.shipped! for downloadable products
  end

  def after_voided
    #  send email
    OrderMailer.deliver_receipt(self)
  end

  def after_shipped
    #  send email
    #    OrderMailer.deliver_order_shipped(self)
  end
end

