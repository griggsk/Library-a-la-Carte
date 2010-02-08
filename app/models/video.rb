class Video < ActiveRecord::Base
belongs_to :video_resource

def video_id
    match =""
    match = url.gsub(/.*v=([^&]*).*/, '\1') if !url.blank?
    unless match == url
      return match
    else
     return match
    end
end

def self.get_id(tube)
  match = tube.gsub(/.*v=([^&]*).*/, '\1') if !tube.blank?
    unless match == tube
      return match
    else
     return ""
    end
end

def retrieve_video
  vid = ""
  vid_id = video_id
  if !vid_id.blank?
       begin   
             vid = Youtube::Video.find("#{vid_id}") 
        rescue Exception
           return vid
        else
          begin
            vid = vid.group.content.to_a[0].url 
          rescue Exception
            return vid = ""
          end
       end 
   end   
   return vid
end

end