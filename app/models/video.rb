#Library a la Carte Tool (TM).
#Copyright (C) 2007 Oregon State University
#See license-notice.txt for full license notice

class Video < ActiveRecord::Base
belongs_to :video_resource
acts_as_list :scope => :video_resource

def video_id
    match = url.gsub(/.*v=([^&]*).*/, '\1') if !url.blank?
    return (match.blank? ? "" : match)
end

def self.get_id(tid)
  match = tid.gsub(/.*v=([^&]*).*/, '\1') if !tid.blank?
  return (match.blank? ? "" : match)
end

def retrieve_video
  logger.debug("VID: #{video_id}")
   begin   
         video = Youtube::Video.find("#{video_id}") 
    rescue Exception
       return ""
    else
      begin
        video = video.group.content.to_a[0].url 
      rescue Exception
        return ""
      end
  end
  return video
end   
  
end