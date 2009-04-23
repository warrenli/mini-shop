class Download < UserUpload
  belongs_to :item, :foreign_key => 'instance_id'
  has_many   :download_links, :foreign_key => "user_upload_id"

  has_attached_file :data,
    :path => ":rails_root/asset/:class/:attachment/:id/:basename.:extension"
#    :url  => "/downloads/:id",

  #validates_attachment_presence :data
#  validates_attachment_content_type :data, :content_type => ['application/pdf', 'text/plain']
# validates_attachment_content_type :mp3, :content_type => [ 'application/mp3', 'application/x-mp3', 'audio/mpeg', 'audio/mp3' ]
# validates_attachment_content_type :video, :content_type => ['video/x-msvideo','video/avi','video/quicktime','video/3gpp','video/x-ms-wmv','video/mp4','video/mpeg']

  validates_attachment_size :data, :less_than => 10.megabytes

#  validates_presence_of :instance_id

#  attr_protected :data_file_name, :data_content_type, :data_file_size
#  attr_accessible :instance_id, :data_file_name, :data_content_type, :data_file_size

end


=begin

download any file

send_file(@path,
          :filename       =>  params[:filename] ,
          :type           => 'application/octet-stream',
          :disposition    => "attachment",
          :streaming      => true,
          :buffer_size    => 4096)


=end
