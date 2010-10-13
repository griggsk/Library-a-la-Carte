#Library a la Carte Tool (TM).
#Copyright (C) 2007 Oregon State University
#See license-notice.txt for full license notice

class Authorship < ActiveRecord::Base
 belongs_to :user
 belongs_to :tutorial
 
 attr_protected :rights 
 
 RIGHTS = [
     ["Editor",        "1"],
     ["Contributor",   "2"], 
     ["Reviewer",      "3"],
   ]
   
   def tutorials_with_rights(access)
       find(:all, :conditions => ['rights == ?', access]).collect{|a|a.tutorial}
   end

   
   end
