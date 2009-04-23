class Product < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper

#  SUBITEM   = "Subitem"
  ITEM      = "Item"
  VARIATION = "Variation"
  PACKAGE   = "Package"
  PRODUCT   = "Product"

  validates_presence_of :code, :name, :currency_code, :price
  validates_presence_of :date_available, :on => :update, :if => :date_require?
  validates_uniqueness_of :code, :case_sensitive => false
  validates_format_of  :code, :with => /\A\w[\w\-\_]*\z/, :message => I18n.t('activerecord.errors.messages.msg_simple_word')
  validates_numericality_of :price, :greater_than_or_equal_to => 0.00
  validates_numericality_of :rank, :integer_only => true, :gt => 0
  validates_numericality_of :position, :integer_only => true, :gt => 0

  validates_inclusion_of :currency_code, :in => %w(HKD USD)

  attr_accessible :code, :name, :currency_code, :price, :rank, 
                  :is_published, :date_available, :description, :position

  has_many :pictures, :foreign_key => 'instance_id', :dependent => :destroy,
    :order => "position ASC, updated_at DESC"
  accepts_nested_attributes_for :pictures, :allow_destroy => true ,
    :reject_if => proc { |attributes| attributes['data'].blank? }
  attr_accessible :pictures_attributes

  default_scope  :order => "is_published DESC, rank DESC, updated_at DESC"
  named_scope :items,  :conditions => [ "type in ('Item')"]
  named_scope :packages, :conditions => [ "type in ('Package')"]

  # Get available package or item but exclude variation
  named_scope :available, lambda{ |time| { :conditions => [ "is_published = 1 and parent_id is null and date_available < ? ", time.to_s(:db) ]} }
  named_scope :limit, lambda { |num| { :limit => num } }
  named_scope :published, :conditions => [ "is_published = 1" ]

  has_many :order_product_lines

  attr_reader :product_type

  def product_type
#    return SUBITEM   if self.instance_of?(Subitem)
    if self.instance_of?(Item)
      return self.variation? ? VARIATION : ITEM
    end
    return PACKAGE   if self.instance_of?(Package)
    return PRODUCT   if self.instance_of?(Product)
  end

  def display_name
    self.name
  end

  def display_price
    self.currency_code + " " + number_to_currency(self.price,:unit=>'')
  end

  def date_require?
    return false if self.product_type == VARIATION
    self.is_published
  end

  def get_first_picture
    unless self.pictures.empty?
      self.pictures[0]
    end
  end

  def get_description
    self.description
  end
end

