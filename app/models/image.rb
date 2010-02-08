class Image < ActiveRecord::Base
belongs_to :image_resource

validates_format_of :url, :with => URI::regexp(%w(http https)) 

end