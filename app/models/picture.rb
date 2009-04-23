class Picture < UserUpload
  belongs_to :product, :foreign_key => 'instance_id'

  has_attached_file :data,
    :styles => { :tiny   => "60x60#", :thumb  => "180x135>", :small  => "270x203>",
                 :medium => "400x300>", :large  => "600x450>", :xlarge => "900x675>" },
    :url => "/:class/:attachment/:id/:style_:basename.:extension",
    :path => ":rails_root/public/:class/:attachment/:id/:style_:basename.:extension"

  #validates_attachment_presence :data
  validates_attachment_content_type :data,
    :content_type => ['image/jpeg', 'image/pjpeg', 'image/jpg', 'image/png']
  validates_attachment_size :data, :less_than => 2.megabytes

#  validates_presence_of :instance_id

#  attr_protected :data_file_name, :data_content_type, :data_file_size
#  attr_accessible :instance_id, :data_file_name, :data_content_type, :data_file_size

end


