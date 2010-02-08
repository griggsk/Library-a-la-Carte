class Link < ActiveRecord::Base
belongs_to :url_resource

validates_format_of :url, :with => URI::regexp(%w(http https)) 




end