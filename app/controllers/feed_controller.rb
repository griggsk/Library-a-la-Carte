#Library a la Carte Tool (TM).
#Copyright (C) 2007 Oregon State University
#See license-notice.txt for full license notice

class FeedController < ApplicationController
 before_filter :module_types
  before_filter :current_page
  before_filter :current_guide
  before_filter :current_tutorial
   layout 'tool'
 
 def edit_rss
  @ecurrent = 'current'
     begin
        @mod = find_mod(params[:id], "RssResource")
     rescue ActiveRecord::RecordNotFound
        flash[:notice] = "The module doesn't exist. "
        redirect_to  :back
   end
end
 
def update_rss
  params[:mod][:existing_feed_attributes] ||= {} 
  params[:mod][:new_feed_attributes] ||= {}
  @mod = find_mod(params[:id], "RssResource")
  @mod.update_attributes(params[:mod])
  @mod.num_feeds = params[:num] if params[:option1]=="find"
  if request.post? and @mod.save
       redirect_to :controller => 'module', :action => "preview" , :id =>@mod.id, :type=> @mod.class
    else 
      render :action => 'edit_rss' , :mod => @mod
    end 
end

def copy_feeds
  begin
     @old_mod = find_mod(params[:id], "RssResource")
    rescue Exception => e
     flash[:notice] = "The module doesn't exist. "
     redirect_to :back
   else
      @mod = @old_mod.clone
      @mod.feeds << @old_mod.feeds.collect{|f| f.clone}.flatten
      @mod.global = false
      @mod.label =  @old_mod.label+'-copy'
      if @mod.save
          create_and_add_resource(@user,@mod)
          flash[:notice] = "Saved as #{@mod.label}"
         redirect_to  :controller => 'module', :action => "edit_content" , :id =>@mod.id, :type=> @mod.class
      end
   end
end
  
end
