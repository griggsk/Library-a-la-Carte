#Library a la Carte Tool (TM).
#Copyright (C) 2007 Oregon State University
#See license-notice.txt for full license notice

class DatabaseDod < ActiveRecord::Base
 belongs_to :dod
 belongs_to :database_resource
end
