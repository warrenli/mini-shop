class DownloadLink < ActiveRecord::Base
  belongs_to :user
  belongs_to :order
  belongs_to :order_product_line, :foreign_key => "order_line_id"
  belongs_to :download, :foreign_key => "user_upload_id"
  belongs_to :item, :foreign_key => "product_id"

  validates_presence_of :order_num

  default_scope  :order => "order_num DESC, order_line_id ASC, user_upload_id ASC", :include => [:item, :download]
  named_scope :by_user,   lambda {|user| {:conditions => ["user_id = ?", user.id]}}
  named_scope :by_token,  lambda {|key|  {:conditions => ["token = ?", key]}}
end
