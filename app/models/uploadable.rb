class Uploadable < ActiveRecord::Base
  belongs_to :uploader_resource
  belongs_to :assign_resource
  has_attached_file :upload, 
                    :styles => { :medium => '505x405>', :thumb => '75x75>' },
                    :url => "/uploads/:attachment/:style/:basename.:extension",
                    :path => ":rails_root/public/uploads/:attachment/:style/:basename.:extension"
  
  
   def logo
     if upload_content_type == 'application/pdf'
        return  logo_image = "/images/icons/pdf.png", title ="Download Free PDF reader", link = "http://www.adobe.com/products/reader"
     elsif  upload_content_type == 'application/vnd.ms-powerpoint'
       return logo =  "/images/icons/ppt.png", title ="Download free alternative to Microsoft Word/Office", link ="http://www.openoffice.org/"
      elsif  upload_content_type == 'image/jpg' || upload_content_type == 'image/jpeg' || upload_content_type ==  'image/pjpeg' || upload_content_type ==  'image/gif' || upload_content_type ==  'image/png' || upload_content_type ==  'image/x-png' || upload_content_type ==  'image/bmp'
       return logo =  "/images/icons/image.png", title ="Download Free Image Manager", link ="http://www.gimp.org/"
     else
       return logo_image = "/images/icons/word.png", title ="Download free alternative to Microsoft Word/Office", link ="http://www.openoffice.org/"
     end
  end
 
end
