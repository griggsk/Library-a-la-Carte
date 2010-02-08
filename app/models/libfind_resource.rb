class LibfindResource < ActiveRecord::Base
acts_as_taggable
has_many :resources, :as => :mod, :dependent => :destroy
has_many :lf_targets, :dependent => :delete_all
before_create :private_label

validates_presence_of :module_title


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
 

def add_lf_targets(targets)
 lf_targets.clear
 targets.each do |target|
   lf_targets << LfTarget.create(:value => target)
 end
end

def get_targets
  lf_targets.collect{|a| a.value}.join(",")
end

def shared?
  self.resources.each do |r|
    return false if r.users.length > 1
  end
end


 def rss_content
  return self.information.blank? ? "" : self.information
 end
 
def search
 "http://search.library.oregonstate.edu/record/retrieve"
end
end
