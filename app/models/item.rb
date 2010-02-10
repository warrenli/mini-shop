class Item < Product
  include ActionView::Helpers::NumberHelper

  belongs_to :parent_item, :class_name => 'Item', :foreign_key => 'parent_id',
    :counter_cache => :count_of_variations
  has_many   :variations,  :class_name => 'Item', :foreign_key => 'parent_id',
    :dependent => :destroy, :order => "position ASC, updated_at DESC"
  accepts_nested_attributes_for :variations
  attr_accessible :variations_attributes

  has_many :components, :dependent => :destroy, :class_name => 'PackageComponent',
    :order => "position ASC", :include => :package #, :foreign_key => 'item_id'
  has_many :packages, :through => :components

  has_many :downloads, :foreign_key => 'instance_id', :dependent => :destroy,
    :order => "position ASC, updated_at DESC"
  accepts_nested_attributes_for :downloads, :allow_destroy => true ,
    :reject_if => proc { |attributes| attributes['data'].blank? }
  attr_accessible :downloads_attributes

  has_many :download_links, :foreign_key => "product_id"

  default_scope :include => [:downloads ]
  named_scope :leaf, :conditions => [ "count_of_variations = 0" ]

  def variation?
    !self.parent_id.nil?
  end

  def display_name
    variation? ? self.parent_item.name + " - " + self.name : self.name
  end

  def display_price
    if self.variation?
       super
    else
      available_variations = self.variations.published
      case available_variations.length
      when 0
        super
      when 1
        available_variations[0].display_price
      else
        min_value = number_to_currency(available_variations.to_a.map{|x| x.price }.min,:unit=>'')
        max_value = number_to_currency(available_variations.to_a.map{|x| x.price }.max,:unit=>'')
        self.currency_code + " " + min_value + " - " + max_value
      end
    end
  end

  # an item is a leaf item if it has no variation
  # a leaf item can become a component of a package
  def leaf?
    self.variations.size == 0
  end

  def get_first_picture
    if variation?
      self.parent_item.get_first_picture
    else
      super
    end
  end

  def get_description
    return self.description unless self.description.blank?
    if variation?
      self.parent_item.description
    else
      "No Description"
    end
  end
end


=begin

  class Subitem < Item
    belongs_to :item, :foreign_key => 'parent_id'
  end

  class Item < Product
    has_many :subitems, :class_name => 'Subitem', :foreign_key => 'parent_id', 
        :dependent => :destroy, :order => 'name ASC'
  end

=end





=begin

  http://geekninja.blogspot.com/2008/11/testing-file-uploads-in-rails.html
  fixture_file_upload uses /fixtures as its base directory
  post :foot_bar, :file => fixture_file_upload('files/test_file.txt', 'text/plain', :binary)


  def test_should_create_asset
    old_count = Asset.count
    post :create, :asset => { :name => 'railslogo',
                  :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png') },
                  :html => {:multipart => true }
    assert_equal old_count+1, Asset.count
  end


  http://www.buildingwebapps.com/articles/6411-file-upload-form-testing-fixtures

  def test_should_create_new_attachment
    fdata = fixture_file_upload('/files/photo1.jpg', 'image/jpeg')
    login_as :bob
    assert_difference Photo, :count, 2 do
      post :create, :photo => { :uploaded_data => fdata }, :html => { :multipart => true }
    end
    assert_redirected_to user_url(users(:bob))
    assert_valid assigns(:photo)
  end

=end
