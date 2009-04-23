class Package < Product
  has_many :components, :dependent => :destroy, :order => "position ASC",
           :class_name => 'PackageComponent', :include => :item #, :foreign_key => "package_id"
  accepts_nested_attributes_for :components, :allow_destroy => true,
    :reject_if => proc { |attributes| ( attributes['item_id'].blank? or attributes['item_id'].to_i == 0 ) }
  attr_accessible :components_attributes

  has_many :items, :through => :components #, :conditions => "is_published = 1" , :uniq => true
end

