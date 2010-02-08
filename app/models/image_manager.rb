class ImageManager < ActiveRecord::Base
  has_attached_file :photo, 
                  :styles => { :original => '505x425>', :thumb => '75x75>' },
                  :url => "/photos/:attachment/:style/:basename.:extension",
                  :path => ":rails_root/public/photos/:attachment/:style/:basename.:extension"
 
  attr_protected :upload_file_name, :upload_content_type, :upload_size,:photo_file_name, :photo_content_type, :photo_size
  validates_presence_of :photo_file_name,
                        :message => "File name can not be blank"
  validates_uniqueness_of :photo_file_name,
                        :message => "That photo has already been uploaded"
  validates_attachment_size :photo, 
                            :less_than => 5.megabytes,
                            :message => "File size must be less than 5 MB"
  #validates_attachment_content_type :photo, :content_type => ['image/jpeg', 'image/png', 'image/gif', 'image/pjpeg', 'image/bmp']
  validates_attachment_content_type :photo,
    :content_type => ['image/jpg', 'image/jpeg', 'image/pjpeg', 'image/gif', 'image/png', 'image/x-png', 'image/bmp'],
    :message => "Only .jpg, .jpeg, .pjpeg, .gif, .png, .x-png and .bmp files are allowed"

end
