class PackageComponent < ActiveRecord::Base
  belongs_to :item
  belongs_to :package

  # acts_as_list :scope => :package_id
  validates_numericality_of :position, :integer_only => true, :gt => 0

  attr_accessible :position, :item_id
end

