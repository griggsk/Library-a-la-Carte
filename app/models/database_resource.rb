class DatabaseResource < ActiveRecord::Base
acts_as_taggable
has_many :resources, :as => :mod, :dependent => :destroy
has_many :database_dods, :dependent => :destroy, :order => :location
has_many :dods, :through => :database_dods

before_create :private_label

validates_presence_of :module_title

def private_label
  self.label = self.module_title
end

def add_tags(tags)
  self.tag_list = tags
  self.save
end

def proxy
  return Local.first.proxy
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

def add_dod(dod)
  db_dod = DatabaseDod.new(:dod_id => dod.id, :description => dod.descr, :location => self.database_dods.count+1)
  database_dods << db_dod
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

 def rss_content
  return self.info.blank? ? "" : self.info
 end
end
