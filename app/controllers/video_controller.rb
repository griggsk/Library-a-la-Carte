#Library a la Carte Tool (TM).
#Copyright (C) 2007 Oregon State University
#See license-notice.txt for full license notice

class VideoController < ApplicationController
  before_filter :module_types
  before_filter :current_page
  before_filter :current_guide
  before_filter :current_tutorial
  layout :select_layout

 def edit_video
     @ecurrent = 'current'
     @style ='width:190px; height:150px;'
     begin
        @mod = find_mod(params[:id], "VideoResource")
     rescue ActiveRecord::RecordNotFound
        redirect_to :controller => 'module', :action => 'index', :list=> 'mine'
     else 
      session[:mod_id] = @mod.id
      session[:mod_type] = @mod.class
  end
end
 


def update_video
  params[:mod][:existing_video_attributes] ||= {} 
  params[:mod][:new_video_attributes] ||= {} 
  @mod = find_mod(params[:id], "VideoResource")
  @mod.update_attributes(params[:mod]) 
    if @mod.save 
       session[:search_result] = nil
       redirect_to :controller => 'module', :action => "preview" , :id =>@mod.id, :type=> @mod.class
    else 
      render :action => 'edit_video' , :mod => @mod
    end
  end
 
 def search_videos
   @mod = find_mod(params[:id], "VideoResource")
   @query = params[:search_value] 
   begin
       @list = Youtube::Video.find(:first, :params => {:vq => @query, "max-results" => '10'})
   rescue Exception
      @list = ""
   end
   render :partial => "video/search_results", :locals => {:list => @list, :mod =>@mod} and return
 end
 
 def search_preview
   @style ='width:290px; height:250px;'
   @mod = find_mod(params[:id], "VideoResource")
   @vid = "http://www.youtube.com/v/"+Video.get_id(params[:vid])+"&amp;fs=1&amp;rel=0" 
 end
 
 def enlarge_video
   @style ='width:290px; height:250px;'
   @mod = find_mod(params[:id], "VideoResource")
   @vid = "http://www.youtube.com/v/"+Video.get_id(params[:vid])+"&amp;fs=1&amp;rel=0" 
 end
 
 def save_video
   @style ='width:190px; height:150px;'
    @mod = find_mod(params[:id], "VideoResource")
    @vid = "http://www.youtube.com/watch?v="+Video.get_id(params[:vid]) 
    new = Video.new(:url => @vid)
    @mod.videos << new
   render :partial => "video/video", :collection => @mod.videos, :locals => {:mod =>@mod} and return
 end
 
 
def copy_video
    begin
     @old_mod = find_mod(params[:id], "VideoResource")
    rescue Exception 
     redirect_to :controller => 'module', :action => 'index', :list=> 'mine'
   else
      @mod = @old_mod.clone
      @mod.global = false
       @mod.label =  @old_mod.label+'-copy'
     if @mod.save
        @mod.videos << @old_mod.videos.collect{|v| v.clone if v}
        create_and_add_resource(@user,@mod)
          flash[:notice] = "Saved as #{@mod.label}"
        redirect_to  :controller => 'module', :action => "edit_content" , :id =>@mod.id, :type=> @mod.class
     end
   end  
 end

   #Sort modules function for drag and drop  
def sort
  if params['videos'] then 
     sortables = params['videos'] 
     sortables.each do |id|
      video = Video.find(id)
      video.update_attribute(:position, sortables.index(id) + 1 )
     end
   end
   render :nothing => true 
end

def select_layout
    if ['search_preview'].include?(action_name)
      "popup"
    else
     "tool"
    end
 end
  
  

end
