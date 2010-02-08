class IcaController < ApplicationController
skip_before_filter :authorize
layout :select_layout
  
  
 def index
     begin
      @page = Page.find(params[:id], :include => [:users, :resource, :tags, {:tabs => :tab_resources}]) 
     rescue ActiveRecord::RecordNotFound
      render :status => 404,
      :text => (IO.read(File.join(RAILS_ROOT, 'public', '404.html'))) ,
      :layout => false 
    else
      @tabs = @page.tabs
      @tab = params[:tab] ? @tabs.select{|t| t.id == params[:tab].to_i}.first : @tabs.first
      if @tab and @tab.template == 2
          @class ='thumbnail'
          @style ='width:290px; height:250px;'
          @mods_left  = @tab.left_modules
          @mods_right = @tab.right_modules
      elsif @tab
         @class ='full'
         @style ='width:505px; height:450px;'
         @mods = @tab.sorted_modules
      end
      @title= @page.header_title + " Course Guide | " + unless @local.lib_name.blank? then @local.lib_name else "Library Guides" end
      @meta_keywords = @page.tag_list 
      @meta_description = @page.page_description
      @related_guides = @page.related_guides
      @mod = @page.resource.mod if @page.resource
      @owner = @page.users.select{|u| u.name == @page.created_by}.first
    end
 end
 
#Gets the list of all published ICAPs and filters the list by subject
 def published_pages
    @from = 'published'
    @meta_keywords = @local.ica_page_title + " Course Guides, " + "Research Topics " + "Library Help Guides"
    @meta_description = @local.ica_page_title + ". Library Help Guides for Course Assignments. " + unless @local.lib_name.blank? then @local.lib_name else ""end
    @title = @local.ica_page_title + " " +  unless @local.lib_name.blank? then @local.lib_name else "Library Guides" end
    @pages = Page.get_published_pages
    @subjects = Page.get_subjects(@pages)
    @tags = Page.tag_counts(:start_at => Time.now.last_year, :conditions =>["published = ?", true], :order => 'taggings.created_at desc', :limit => 100)
 end

 
 def archived
   @from = 'archived'
    @meta_keywords = @local.ica_page_title + " Course Guides, " + "Research Topics " + "Library Help Guides " + "Archived"
    @meta_description = @local.ica_page_title + ". Archived Library Help Guides for Course Assignments. " + unless @local.lib_name.blank? then @local.lib_name else ""end
    @title = @local.ica_page_title + " Archived | " + unless @local.lib_name.blank? then @local.lib_name else "Library Guides" end
   
    @subjects = Subject.get_subjects
    @pages = Page.get_archived_pages(nil) 
    @tags = Page.tag_counts(:start_at => Time.now.last_year, :conditions =>["archived = ?", true], :order => 'taggings.created_at desc', :limit => 100)
    if request.post?
        if params[:subject]
            @subj = params[:subject]
            @subject = Subject.find(@subj)
            @pages = Page.get_archived_pages(@subject) 
         end
    end  
 end
 
  def print_portal
    from = params[:from] 
     @meta_keywords = @local.ica_page_title + " Course Guides, " + "Research Topics " + "Library Help Guides"
    @meta_description = @local.ica_page_title + ". Library Help Guides for Course Assignments. " + unless @local.lib_name.blank? then @local.lib_name else ""end
    @title= @local.ica_page_title + " Print  | " + unless @local.lib_name.blank? then @local.lib_name else "Library Guides" end
    if from == 'published'
      @pages = Page.get_published_pages
      @tags = Page.tag_counts(:start_at => Time.now.last_year, :conditions =>["published = ?", true], :order => 'taggings.created_at desc', :limit => 100)
 
    else
      @pages = Page.get_archived_pages(nil) 
      @tags = Page.tag_counts(:start_at => Time.now.last_year, :conditions =>["archived = ?", true], :order => 'taggings.created_at desc', :limit => 100)
    end 
  end
 
 
 def tagged
    @tag = params[:id]
   @meta_keywords = @local.ica_page_title + ", " + @tag 
    @meta_description =   @local.ica_page_title + ". Library Course Guides Tagged with: " + @tag  
   @title = @local.ica_page_title + " Tagged with: " + @tag +" | " + unless @local.lib_name.blank? then @local.lib_name else "Library Guides" end
   @tags = Page.tag_counts(:start_at => Time.now.last_year, :conditions =>["published = ?", true], :order => 'taggings.created_at desc', :limit => 100)
  @pages = Page.find_tagged_with(@tag)
end

 def print
     begin
       @page = Page.find(params[:id],:include => [{:tabs => :resources}]) 
     rescue ActiveRecord::RecordNotFound
      render :status => 404,
      :text => (IO.read(File.join(RAILS_ROOT, 'public', '404.html'))) ,
      :layout => false 
    else
      @resources = @page.modules
      @meta_keywords = @page.tag_list 
      @meta_description = @page.page_description
       @title= @page.header_title + " Print  | " + unless @local.lib_name.blank? then @local.lib_name else "Library Guides" end
        @related_guides = @page.related_guides
      @mod = @page.resource.mod if @page.resource
      @owner = @page.users.select{|u| u.name == @page.created_by}.first
     end
 end
 
 
 
def feed
     begin
       @page = Page.find(params[:id])
     rescue ActiveRecord::RecordNotFound
      logger.error("Attempt to access invalid page #{params[object_id]}" )
      render :status => 404,
      :text => (IO.read(File.join(RAILS_ROOT, 'public', '404.html'))) ,
      :layout => false 
     else
      @mods = @page.recent_modules
      @page_url = url_for :controller => 'ica', :action => 'index', :id => @page
      @page_title = @page.header_title
      @page_description = @page.page_description
      author = @page.users.select{|u| u.name == @page.created_by}.first
      @author_email = author.email + " ("+author.name+")" if author
      response.headers['Content-Type'] = 'application/rss+xml'
      # Render the feed using an xml.builder template
      respond_to do |format|
        format.xml {render  :layout => false}
      end
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
