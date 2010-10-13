#Library a la Carte Tool (TM).
#Copyright (C) 2007 Oregon State University
#See license-notice.txt for full license notice

class Image < ActiveRecord::Base
belongs_to :image_resource

validates_format_of :url, :with => URI::regexp(%w(http https)) 

end