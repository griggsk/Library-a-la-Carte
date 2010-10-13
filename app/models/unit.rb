#Library a la Carte Tool (TM).
#Copyright (C) 2007 Oregon State University
#See license-notice.txt for full license notice

class Unit < ActiveRecord::Base
  acts_as_taggable
  has_many :unitizations, :dependent => :destroy
  has_many :tutorials, :through => :unitizations
  has_many :resources, :through => :resourceables
  has_many :resourceables, :order => :position, :dependent => :destroy
  validates_presence_of  :title
  validates_presence_of  :slug, :on => :update
  validates_length_of :slug, :maximum=>15, :message=>"less than {{count}}", :on => :update
  before_create :create_slug
    
    
  def add_tags(tags)
    self.tag_list = tags
    self.save
  end

  #add a resource to the HABTM relationship
def add_resource(resource)
    resources << resource
end


#update a users resource list
def update_resources(resrs)
    resrs.each do |value|
               id = value.gsub(/[^0-9]/, '')
               type = value.gsub(/[^A-Za-z]/, '')
               resource = Resource.find_by_mod_id_and_mod_type(id,type)
               resource.create_slug if resource.mod.slug.blank?
               resources << resource
           end
end


def create_slug(trunc = 15, truncate_string = "...")
      text = self.title
      l = trunc - truncate_string.mb_chars.length
      chars = text.mb_chars
      self.slug = (chars.length > trunc ? chars[0...l] + truncate_string : text).to_s
end

def add_module(id, type)
  resource = Resource.find_by_mod_id_and_mod_type(id,type)
  resources << resource if resource
end

def find_resource(id, type)
   return resources.find_by_mod_id_and_mod_type(id, type)
end

#get the collection of associated resources
def modules
   resources.collect {|a| a.mod}
end 

def recent_modules 
   sortable = "updated_at"
   return resources.collect{ |a| a.mod}.sort! {|a,b|  a.send(sortable) <=> b.send(sortable)}
end

def sorted_resources
  return resourceables.collect{|t| t.resource}
end
  
 def first_module
   res = sorted_resources.first
   return (res.blank? ? false : res.mod)
 end
 
 def last_module
    res = sorted_resources.last
   return (res.blank? ? false : res.mod)
 end
  
  def next_module(id, type)
    res = find_resource(id, type)
    resable = resourceables.select{|r| r.resource.id == res.id}.first
    next_resable = resable.lower_item
    return (next_resable.blank? ? false : next_resable.resource.mod)
  end

  
  def prev_module(id, type)
    res = find_resource(id, type)
    resable = resourceables.select{|r| r.resource.id == res.id}.first
    prev_resable = resable.higher_item
    return (prev_resable.blank? ? false : prev_resable.resource.mod)
  end
  
  
end
