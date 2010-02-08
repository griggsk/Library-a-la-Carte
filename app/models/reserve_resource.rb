##########################################################################
#
#ICAP Tool - Publishing System for and by librarians.
#Copyright (C) 2007 Oregon State University
#
#This file is part of the ICAP project.
#
#The ICAP project is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#Questions or comments on this program may be addressed to:
#ICAP - Library Technology
#121 The Valley Library
#Corvallis OR 97331-4501
#
#http://ica.library.oregonstate.edu/about/index.html
#
########################################################################

class ReserveResource < ActiveRecord::Base
acts_as_taggable
has_many :resources, :as => :mod,  :dependent => :destroy
before_create :private_label
serialize :library_reserves

validates_presence_of :module_title

def private_label
  self.label = self.module_title
end

def add_tags(tags)
  self.tag_list = tags
  self.save
end

def after_create
  self.library_reserves = []
  self.save
end

def shared?
  self.resources.each do |r|
    return false if r.users.length > 1
  end
end

 def used?
     self.resources.each do |r|
       return false if r.tab_resources.length < 1 and  r.pages.length < 1 and r.guides.length < 1 and r.resourceables.length < 1
     end
  end


 def get_pages
     return  resources.collect{|r| r.tabs.collect{|t| t.guide}}.flatten.uniq
 end
 
  def get_guides
    return  resources.collect{|r| r.tabs.collect{|t| t.guide}}.flatten.uniq
 end
 
  def get_tutorials
    return  resources.collect{|r| r.units.collect{|t| t.tutorials}}.flatten.uniq
 end
 
 def rss_content
  return self.reserves.blank? ? "" : self.reserves 
 end

end
