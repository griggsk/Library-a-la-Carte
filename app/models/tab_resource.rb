#Library a la Carte Tool (TM).
#Copyright (C) 2007 Oregon State University
#See license-notice.txt for full license notice

class TabResource < ActiveRecord::Base
 belongs_to :tab
 belongs_to :resource
 acts_as_list :scope => :tab

end
