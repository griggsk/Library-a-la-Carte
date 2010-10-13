#Library a la Carte Tool (TM).
#Copyright (C) 2007 Oregon State University
#See license-notice.txt for full license notice

class Resourceable < ActiveRecord::Base
 belongs_to :resource
 belongs_to :unit
 acts_as_list :scope => :unit
end
