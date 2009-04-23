class Address < ActiveRecord::Base
  belongs_to  :addressable, :polymorphic => true
  belongs_to  :country

  validates_presence_of :addressable_id, :addressable_type
  validates_presence_of :street_1, :city, :postal_code, :country

  attr_accessible :street_1, :street_2, :city, :postal_code, :country_id

  def multi_line
    lines = []
    lines << street_1     if street_1?
    lines << street_2     if street_2?
    lines << city         if city?
    lines << postal_code  if postal_code
    lines << country.name if country
    lines
  end

  def single_line
    multi_line.join(', ')
  end
end
