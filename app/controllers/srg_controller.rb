#Library a la Carte Tool (TM).
#Copyright (C) 2007 Oregon State University
#See license-notice.txt for full license notice

class SrgController < ApplicationController
skip_before_filter :authorize
layout :select_layout
 
  def index
      @guide = Guide.find(params[:id], :include => [:users, {:masters => :guides}, :subjects, :resource, :tags]) 
      @tabs = @guide.tabs
      @tab = params[:tab] ? @tabs.select{|t| t.id == params[:tab].to_i}.first : @tabs.first
      if @tab and @tab.template == 2
         @style ='width:290px; height:250px;'
          @mods_left  = @tab.left_modules
          @mods_right = @tab.right_modules
      elsif @tab
         @style ='width:425px; height:350px;'
         @mods = @tab.sorted_modules
      else
        render_404
      end
      @title= @guide.guide_name + " |  "+ @local.guide_page_title
      @meta_keywords = @guide.tag_list 
      @meta_description = @guide.description
      @owner = @guide.users.select{|u| u.name == @guide.created_by}.first
      @updated = @guide.updated_at.to_formatted_s(:short)
      @mod = @guide.resource.mod if @guide.resource
      @related_guides = @guide.related_guides
      @related_pages = @guide.related_pages
      
  end
  

def published_guides
    @meta_keywords = @local.guide_page_title + ", Research Guides, Research Topics, Library Help Guides"
    @meta_description = @local.guide_page_title + ". Library Help Guides for Subject Research. " 
    @title = @local.guide_page_title 
    @guides = Guide.published_guides
    @masters = Master.find(:all, :conditions => ["value != ?", "Tutorial"], :order => 'value', :include => :guides)
    @tags = Guide.tag_counts(:conditions =>["published = ?", true], :order => 'taggings.created_at desc', :limit => 100)
    
end

def print_portal
    @title= @local.guide_page_title + " | Print"
    @guides = Guide.published_guides
     @tags = Guide.tag_counts( :conditions =>["published = ?", true], :order => 'taggings.created_at desc', :limit => 100)
end
  

def search
    @meta_keywords = "Search Subject Guides, Course Guides, and Research Tutorials"
    @meta_description= "Search Subject Guides, Course Guides, and Research Tutorials." 
    @title = "Search Results"
    @guides =""
end

def tagged
   @tag = params[:id]
   
    @meta_keywords = @local.guide_page_title + " Tagged: "+ @tag 
    @meta_description=  @local.guide_page_title + "Tagged: " + @tag  +". Library Help Guides for Subject Research. "
    @title =  @local.guide_page_title + " | Tagged: " + @tag  
    @tags = Guide.tag_counts( :conditions =>["published = ?", true], :order => 'taggings.created_at desc', :limit => 100)
    @guides = Guide.find_tagged_with(@tag, :conditions =>["published = ?", true])
end

def print
       @guide = Guide.find(params[:id],:include => [{:tabs => :resources}]) 
      @mods = @guide.modules
      @title= @guide.guide_name + " | Print "
      @owner = @guide.users.select{|u| u.name == @guide.created_by}.first
      @mod = @guide.resource.mod if @guide.resource
       @owner = @guide.users.select{|u| u.name == @guide.created_by}.first
      @updated = @guide.updated_at.to_formatted_s(:short)
      @related_guides = @guide.related_guides
      @related_pages = @guide.related_pages
 end
 
 def feed
       @guide = Guide.find(params[:id])
      @mods = @guide.recent_modules
      @guide_url = url_for :controller => 'srg', :action => 'index', :id => @guide
      @guide_title = @guide.guide_name
      @guide_description = @guide.description
      author = @guide.users.select{|u| u.name == @guide.created_by}.first
      @author_email = author.email + " ("+author.name+")" if author
      response.headers['Content-Type'] = 'application/rss+xml'
      # Render the feed using an xml.builder template
      respond_to do |format|
        format.xml {render  :layout => false}
      end
end


  def select_layout
    if ['print', 'print_portal'].include?(action_name)
      "print"
    else
     "template"
    end
 end
 
 end
