class InstResource < ActiveRecord::Base
acts_as_taggable
has_many :resources, :as => :mod, :dependent => :destroy
before_create :private_label

validates_presence_of :module_title
validates_format_of :email, :allow_nil => true, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :if => Proc.new {|c| not c.email.blank?}

def private_label
  self.label = self.module_title
end

 def get_pages
     return  resources.collect{|r| r.tabs.collect{|t| t.page}}.flatten.uniq
 end
 
  def get_guides
    return  resources.collect{|r| r.tabs.collect{|t| t.guide}}.flatten.uniq
 end
 
  def get_tutorials
    return  resources.collect{|r| r.units.collect{|t| t.tutorials}}.flatten.uniq
 end

def add_tags(tags)
  self.tag_list = tags
  self.save
end

   def used?
     self.resources.each do |r|
       return false if r.tab_resources.length < 1 and  r.pages.length < 1 and r.guides.length < 1 and r.resourceables.length < 1
     end
  end

 def rss_content
  return self.instructor_name.blank? ? "" : self.instructor_name
 end

def shared?
  self.resources.each do |r|
    return false if r.users.length > 1
  end
end

end
