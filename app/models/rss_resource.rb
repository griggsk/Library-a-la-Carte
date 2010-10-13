#Library a la Carte Tool (TM).
#Copyright (C) 2007 Oregon State University
#See license-notice.txt for full license notice

class RssResource < ActiveRecord::Base
acts_as_taggable
has_many :resources, :as => :mod,  :dependent => :destroy
has_many :feeds, :dependent => :destroy
before_create :private_label
after_update :save_feeds


validates_presence_of :module_title
validates_presence_of :label, :on => :update
  
NUMFEEDS =  [
     ["3",       3],
     ["6",       6],
     ["9",       9], 
     ["15",      15],
   ]
   

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

 def rss_content
  return self.information.blank? ? "" : self.information
 end

  def shared?
    self.resources.each do |r|
      return true if r.users.length > 1
    end
     return false
  end

def new_feed_attributes=(feed_attributes) 
  feed_attributes.each do |attributes| 
    feeds.build(attributes) 
  end 
end 


 def existing_feed_attributes=(feed_attributes) 
  feeds.reject(&:new_record?).each do |feed| 
    attributes = feed_attributes[feed.id.to_s] 
    if attributes 
     feed.attributes = attributes 
    else 
      feeds.delete(feed) 
    end 
  end 
 end 


def feedurls
  return feeds.collect{|f| f.url}
end

def feedlabels
  return feeds.collect{|f| f.label}
end

def reader
 "http://www.google.com/jsapi?key="+GOOGLE_API
end

def save_feeds
  if !feeds.blank?
    feeds.each do |feed| 
      feed.save(false) 
    end 
  end
 end 


end
