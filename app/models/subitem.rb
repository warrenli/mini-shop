=begin
class Subitem < Item
  belongs_to :item, :foreign_key => 'parent_id'
end
=end
