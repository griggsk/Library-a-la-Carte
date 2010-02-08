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

class Page < ActiveRecord::Base
acts_as_taggable
has_and_belongs_to_many :users
has_many :tabs,  :order => 'position', :dependent => :destroy
has_and_belongs_to_many :subjects, :order => 'subject_code'
belongs_to :resource

serialize :relateds
after_create :create_relateds


  validates_presence_of :course_name,:course_num, :subjects
  validates_associated :subjects
 
  validates_uniqueness_of :course_name,
                           :scope => [:course_num, :term, :year,  :sect_num],
                           :message => "is already in use. Change the Page Title to make a unique page."
  
  validates_format_of :sect_num,
                      :with => /^\d{0,}$/,
                      :message => "must be a number or blank"
  validates_format_of :course_num,
                      :with => /^(\d{1,}\/?\d{1,})*$/,
                      :message => "must be a number or numbers ( e.g, 121 or 121/123)."
                   

                      
  #protect these attributes so they can not be set with a POST request  
  attr_protected :id
 
 def validate
  errors.add_to_base "You must specify at least one subject." if subjects.blank?
end

 def to_param
    "#{id}-#{route_title.gsub(/[^a-z0-9]+/i, '-')}"
  end
 
#make a nice header title 
 def header_title
   subject = ""
   self.subject_codes.each do |subj|
     subject = subject + if subject != "" then "/" else "" end + subj.to_s
   end
    subject + " " + course_num + ":" + " " + course_name 
 end

#get the collection of subject codes
def subject_codes
   return subjects.collect { |s| s.subject_code}
end

#get the collection of subject names
def subject_names
   return subjects.collect { |s| s.subject_name}
end

#make a nice browse title
def browse_title(subj)
    subj + " " + course_num + ":" + " " + course_name +  "    " + unless term == "A" then term else "" end +
  unless year == "A" then year else "" end + " " +  unless sect_num.blank? then " " + "#" + sect_num else  "" end 
end

#make a nice results title
def search_title
  subject = ""
   self.subject_codes.each do |subj|
     subject = subject + if subject != "" then "/" else "" end + subj.to_s
   end
    subject + " " + course_num + ":" + " " + course_name +  "    " + unless term == "A" then term else "" end +
  unless year == "A" then year else "" end + " " +  unless sect_num.blank? then " " + "#" + sect_num else  "" end 
 end

#make a nice route title
def route_title
  subject = ""
   self.subject_codes.each do |subj|
     subject = subject + if subject != "" then "/" else "" end + subj.to_s
   end
  subject+course_num
end
 
 def create_relateds
  self.relateds = self.get_related_guides
  self.save
 end
 
 def delete_relateds(id)
    relateds.delete(id.to_i)
    self.save
 end
 
def add_related_guides(ids)
  ids.each do |id|
    relateds << id.to_i unless relateds.include?(id.to_i)
  end
end
 
 def related_guides
  guides=[]
  if relateds == nil
    self.create_relateds
  end
   relateds.each do |id|
     guide = Guide.find(id)
     if guide and guide.published
       guides << guide
     end
   end
   return guides
 end
 
 def suggested_relateds
   ids = self.get_related_guides
   self.add_related_guides(ids)
   self.save
   return self.related_guides
 end
 
 def get_related_guides
   gds = subjects.collect{|a| a.guides}.flatten
   gds = gds.select{|a| a.published? }.collect{|a| a.id}.uniq
  return gds
end

def add_contact_module(mod)
  self.resource_id = nil
  if mod
   self.resource_id = mod
  end
end

def self.get_branch_published_pages(branch)
  return  self.find(:all,:conditions => {:published => true, :campus => branch}, :order => 'subject, course_num', :select =>'id, subject, course_num, course_name, term, year, sect_num, page_description')
end

def self.get_subjects(pgs)
  return pgs.collect {|a| a.subjects}.flatten.uniq
end

def self.auto_archive
  pages = Page.find(:all,:conditions => {:published => true})
  pages.each do |page|
    if page.updated_at < Time.now.months_ago(6)
       page.toggle!(:archived)
       page.update_attribute(:published, false)
    end
  end
end

#get the published pages by filter
def self.get_published_pages
    return self.find(:all,:conditions => {:published => true},:include => ['subjects'], :order => 'subjects.subject_code, course_num', :select =>'id, course_num, course_name, term, year, sect_num, page_description')
end

def self.get_archived_pages(subj=nil)
   pages = self.find(:all,:conditions => {:archived => true}, :include => ['subjects'], :order => 'subjects.subject_code, course_num', :select =>'id, course_num, course_name, term, year, sect_num, page_description')
  if !subj.blank?
   pages = pages.select{|p| p.subjects.include?(subj)}
  end
    return pages
end


#add a user to the HABTM relationship
def add_user(user)
   users << user
end


def add_subjects(subjs)
  subjects.clear
  if subjs
    subjs.each do |id|
      subject = Subject.find(id)
      subjects << subject
    end
  end
end

def copy_resources(uid, tbs)
     user = User.find(uid)
     tbs.each do |tab|
         mod_copies = tab.resources.collect{|r| r.copy_mod(tab.page.route_title)}.flatten
         tab_copy = tab.clone
         if tab_copy.save
           mod_copies.each do |mod|
              mod.update_attribute(:created_by, user.name)
              resource = Resource.create(:mod => mod)
              user.add_resource(resource)
              tab_copy.add_resource(resource)
          end
          add_tab(tab_copy)
        end
    end
end

def copy_tabs(tbs)
  tbs.each do |tab|
         tab_copy = tab.clone
         if tab_copy.save
           tab.resources.each do |res|
              tab_copy.add_resource(res)
          end
          add_tab(tab_copy)
      end
    end  
end

def create_home_tab
    tab = Tab.new(:tab_name => 'Quick Links')
    self.tabs << tab
end

def add_tab(tab)
  tab.update_attribute(:position, tabs.length + 1)
   tabs << tab
end


def reached_limit?
  tabs.length > 9 ? true : false
end

def modules
 tbs = []
 tbs << tabs.collect{|t| t.modules}
 return tbs.flatten
end

def recent_modules 
   return tabs.collect{|t| t.recent_modules}.flatten
end


def add_tags(tags)
  self.tag_list = tags
  self.save
end

 


end
