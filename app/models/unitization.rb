#Library a la Carte Tool (TM).
#Copyright (C) 2007 Oregon State University
#See license-notice.txt for full license notice

class Unitization < ActiveRecord::Base
 belongs_to :unit
 belongs_to :tutorial
 acts_as_list :scope => :tutorial
  
 after_create :update_ferret
 
  #ferret was not adding new units to the index so added this after save code in to fix it
  def update_ferret
    search = Local.find(:first).enable_search?
      if search
         tutorial.ferret_update
      end
  end  
end
