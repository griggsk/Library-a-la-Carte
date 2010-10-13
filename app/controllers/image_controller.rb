#Library a la Carte Tool (TM).
#Copyright (C) 2007 Oregon State University
#See license-notice.txt for full license notice


class ImageController < ApplicationController
  before_filter :module_types
  before_filter :current_page
  before_filter :current_guide
  before_filter :current_tutorial
  layout 'tool'

 def edit_image
     @ecurrent = 'current'
     begin
        @mod = find_mod(params[:id], "ImageResource")
     rescue ActiveRecord::RecordNotFound
        redirect_to :controller => 'module', :action => 'index', :list=> 'mine'
     else 
      session[:mod_id] = @mod.id
      session[:mod_type] = @mod.class
     end
end
 


def update_image
  params[:mod][:existing_image_attributes] ||= {} 
  params[:mod][:new_image_attributes] ||= {} 
  @mod = find_mod(params[:id], "ImageResource")
  @mod.update_attributes(params[:mod]) 
    if @mod.save 
       redirect_to :controller => 'module', :action => "preview" , :id =>@mod.id, :type=> @mod.class
    else 
      render :action => 'edit_image' , :mod => @mod
    end
end


 def search_flickr
   @mod = find_mod(params[:id], "ImageResource")
   @query = params[:search_value]
   session[:search_result] = @query 
   flickr = Flickr.new("#{RAILS_ROOT}/config/flickr.yml")
   begin
     @list = flickr.photos.search(:text => @query.gsub(/ /,'') , 'per_page' => 8, 'page' => 1, :media => 'photos')
   rescue  Exception 
     @list = ""
   end 
   render :partial => "image/search_results", :locals => {:list => @list, :mod =>@mod} and return
 end

def save_image
   session[:search_result] = nil
    @mod = find_mod(params[:id], "ImageResource")
    @url = params[:url]
    new = Image.new(:url => params[:url], :alt =>params[:alt], :description => params[:description])
    @mod.images << new
   render :partial => "image/image", :collection => @mod.images, :locals => {:mod =>@mod} and return
 end
 

def copy_image
    begin
     @old_mod = find_mod(params[:id], "ImageResource")
    rescue Exception 
     redirect_to :controller => 'module', :action => 'index', :list=> 'mine'
   else
      @mod = @old_mod.clone
      @mod.global = false
        @mod.label =  @old_mod.label+'-copy'
     if @mod.save
        @mod.images << @old_mod.images.collect{|v| v.clone if v}
        create_and_add_resource(@user,@mod)
          flash[:notice] = "Saved as #{@mod.label}"
        redirect_to  :controller => 'module', :action => "edit_content" , :id =>@mod.id, :type=> @mod.class
     end
   end  
 end


end
