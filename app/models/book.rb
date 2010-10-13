#Library a la Carte Tool (TM).
#Copyright (C) 2007 Oregon State University
#See license-notice.txt for full license notice

class Book < ActiveRecord::Base
belongs_to :book_resource
acts_as_list :scope => :book_resource
serialize :catalog_results

validates_format_of :url, :with => URI::regexp(%w(http https)) 


end