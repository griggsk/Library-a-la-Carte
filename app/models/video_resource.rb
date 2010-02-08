class VideoResource < ActiveRecord::Base
acts_as_taggable
has_many :resources, :as => :mod,  :dependent => :destroy
has_many :videos,  :dependent => :destroy
before_create :private_label  
after_update :save_videos
require 'active_youtube'

validates_presence_of :module_title

def private_label
  self.label = self.module_title
end

 def new_video_attributes=(video_attributes) 
  video_attributes.each do |attributes| 
    videos.build(attributes) 
  end 
end 


 def existing_video_attributes=(video_attributes) 
  videos.reject(&:new_record?).each do |video| 
    attributes = video_attributes[video.id.to_s] 
    if attributes 
     video.attributes = attributes 
    else 
      videos.delete(video) 
    end 
  end 
 end 

 def save_videos
  videos.each do |video| 
    video.save(false)
  end 
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
 
   def rss_content
    return self.information.blank? ? "" : self.information
  end
  
  def add_tags(tags)
    self.tag_list = tags
    self.save
  end
  
def shared?
  self.resources.each do |r|
    return false if r.users.length > 1
  end
end

end
