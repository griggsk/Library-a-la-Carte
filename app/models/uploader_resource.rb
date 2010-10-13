#Library a la Carte Tool (TM).
#Copyright (C) 2007 Oregon State University
#See license-notice.txt for full license notice

class UploaderResource < ActiveRecord::Base
  acts_as_taggable
  has_many :resources, :as => :mod, :dependent => :destroy
  has_many :uploadables
  before_create :private_label
  after_update :save_uploadables
  
  attr_protected :upload_file_name, :upload_content_type, :upload_size
  validates_presence_of :module_title
  validates_presence_of :label, :on => :update

  def private_label
   self.label = self.module_title
  end

def add_tags(tags)
  self.tag_list = tags
  self.save
end

 def used?
     self.resources.each do |r|
       return false if r.tab_resources.length < 1 and  r.pages.length < 1 and r.guides.length < 1 and r.resourceables.length < 1
   end
    return true
  end


 def get_pages
     return  resources.collect{|r| r.tabs.collect{|t| t.page}}.flatten.uniq.delete_if{|p| p.blank?}
 end
 
  def get_guides
    return  resources.collect{|r| r.tabs.collect{|t| t.guide}}.flatten.uniq.delete_if{|p| p.blank?}
 end
 
 def get_tutorials
    return  resources.collect{|r| r.units.collect{|t| t.tutorials}}.flatten.uniq.delete_if{|p| p.blank?}
 end
 
  def shared?
  self.resources.each do |r|
    return true if r.users.length > 1
  end
   return false
end

 def rss_content
  return self.info.blank? ? "" : self.info
 end
 
 def new_uploadable_attributes=(uploadable_attributes) 
  uploadable_attributes.each do |attributes| 
    uploadables.build(attributes) 
  end 
end 

 def existing_uploadable_attributes=(uploadable_attributes) 
  uploadables.reject(&:new_record?).each do |uploadable| 
    attributes = uploadable_attributes[uploadable.id.to_s] 
    if attributes 
     uploadable.attributes = attributes 
    else 
      uploadables.delete(uploadable) 
    end 
  end 
 end 

 def save_uploadables
  uploadables.each do |uploadable| 
    uploadable.save(false) 
  end 
 end 


end
