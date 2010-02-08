class SrgController < ApplicationController
skip_before_filter :authorize

   layout :select_layout
 
  def index
     begin
      @guide = Guide.find(params[:id], :include => [:users, {:masters => :guides}, :subjects, :resource, :tags]) 
     rescue ActiveRecord::RecordNotFound
      render :status => 404,
      :text => (IO.read(File.join(RAILS_ROOT, 'public', '404.html'))) ,
      :layout => false and return
    else
      @tabs = @guide.tabs
      @tab = params[:tab] ? @tabs.select{|t| t.id == params[:tab].to_i}.first : @tabs.first
      if @tab and @tab.template == 2
        @class ='thumbnail'
         @style ='width:290px; height:250px;'
          @mods_left  = @tab.left_modules
          @mods_right = @tab.right_modules
      elsif @tab
         @class ='full'
         @style ='width:425px; height:350px;'
        @mods = @tab.sorted_modules
      else
        render :status => 404,
        :text => (IO.read(File.join(RAILS_ROOT, 'public', '404.html'))) ,
        :layout => false and return
      end
      @title= @guide.guide_name + " Research Guide |  " + unless @local.lib_name.blank? then @local.lib_name else "Library Guides" end
      @meta_keywords = @guide.tag_list 
      @meta_description = @guide.description
      
      @owner = @guide.users.select{|u| u.name == @guide.created_by}.first
      @mod = @guide.resource.mod if @guide.resource
      @related_guides = @guide.related_guides(@guide.id)
      @related_pages = @guide.related_pages
      
    end
  end
  

def published_guides
    @meta_keywords = @local.guide_page_title + " Research Guides, " + "Research Topics" + "Library Help Guides"
    @meta_description = @local.guide_page_title + ". Library Help Guides for Subject Research. " + unless @local.lib_name.blank? then @local.lib_name else ""end
    @title = @local.guide_page_title + " |  " + unless @local.lib_name.blank? then @local.lib_name else "Library Guides" end
    
    @guides = Guide.find(:all,:conditions => {:published => true}, :order => 'guide_name', :select =>'id, guide_name, description')
    @masters = Master.find(:all, :order => 'value', :include => :guides)
    @tags = Guide.tag_counts(:start_at => Time.now.last_year, :conditions =>["published = ?", true], :order => 'taggings.created_at desc', :limit => 100)
    
end

def print_portal
    @title= @local.guide_page_title + " Print  | " + unless @local.lib_name.blank? then @local.lib_name else "Library Guides" end
    @guides = Guide.find(:all,:conditions => {:published => true}, :order => 'guide_name', :select =>'id, guide_name, description')
     @tags = Guide.tag_counts(:start_at => Time.now.last_year, :conditions =>["published = ?", true], :order => 'taggings.created_at desc', :limit => 100)
end
  

def search
    @meta_keywords = "Search Subject Guides, Course Guides, and Research Tutorials"
    @meta_description= "Search Subject Guides, Course Guides, and Research Tutorials." + unless @local.lib_name.blank? then @local.lib_name else ""end
    @title = " Search Results|  " + unless @local.lib_name.blank? then @local.lib_name else "Library Guides" end
    @guides =""
end

def tagged
   @tag = params[:id]
   
    @meta_keywords = @local.guide_page_title + " Tagged: "+ @tag 
    @meta_description=  @local.guide_page_title + "Tagged: " + @tag  +". Library Help Guides for Subject Research. " + unless @local.lib_name.blank? then @local.lib_name else ""end
    @title =  @local.guide_page_title + " Tagged: " + @tag  + "  |  " + unless @local.lib_name.blank? then @local.lib_name else "Library Guides" end
    @tags = Guide.tag_counts(:start_at => Time.now.last_year, :conditions =>["published = ?", true], :order => 'taggings.created_at desc', :limit => 100)
    @guides = Guide.find_tagged_with(@tag)
end

def print
     begin
       @guide = Guide.find(params[:id],:include => [{:tabs => :resources}]) 
     rescue ActiveRecord::RecordNotFound
      render :status => 404,
      :text => (IO.read(File.join(RAILS_ROOT, 'public', '404.html'))) ,
      :layout => false 
    else
      @mods = @guide.modules
      @title= @guide.guide_name + " Print Research Guide |  " + unless @local.lib_name.blank? then @local.lib_name else "Library Guides" end
      @owner = @guide.users.select{|u| u.name == @guide.created_by}.first
      @mod = @guide.resource.mod if @guide.resource
      @related_guides = @guide.related_guides(@guide.id)
      @related_pages = @guide.related_pages
     end
 end
 
 def feed
     begin
       @guide = Guide.find(params[:id])
     rescue ActiveRecord::RecordNotFound
      logger.error("Attempt to access invalid page #{params[object_id]}" )
      render :status => 404,
      :text => (IO.read(File.join(RAILS_ROOT, 'public', '404.html'))) ,
      :layout => false 
     else
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
end

def guide_feed
  
end

  def select_layout
    if ['print', 'print_portal'].include?(action_name)
      "print"
    else
     "template"
    end
 end
 
 end
