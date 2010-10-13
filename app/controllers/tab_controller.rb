#Library a la Carte Tool (TM).
#Copyright (C) 2007 Oregon State University
#See license-notice.txt for full license notice

class TabController < ApplicationController
  include Paginating
  before_filter :module_types, :only =>[ :add_modules, :page_add_modules]
  before_filter :current_tab, :only => [:sort, :add_mod, :add_modules, :new_module, :remove_module, :toggle_columns, :page_add_modules]
  before_filter :current_guide, :except => [:page_create, :page_show, :page_delete, :page_add_modules]
  before_filter :current_page, :except => [:create, :show, :delete, :add_modules]
  in_place_edit_for :tab, :tab_name 
  layout 'tool'
  
  #create a new tab
  def create
     if Guide.exists?(@guide) and request.post?
       if @guide.reached_limit?
          flash[:error] = "Could not create the tab. This guide has reached the 6 tab limit" 
          redirect_to :controller => 'guide', :action => 'edit', :id => @guide
       else
          tab =  Tab.new
          tab.attributes = params[:tab]
          tab.position = @guide.tabs.length + 1
          @guide.tabs << tab
          session[:current_tab] = tab.id
          redirect_to :controller => 'guide', :action => 'edit', :id => @guide
      end
      else
       flash[:notice] = "Please select a Guide"
       redirect_to :controller => 'guide', :action => 'index'
     end
  end
  
    def page_create
     if Page.exists?(@page) and request.post?
       if @page.reached_limit?
          flash[:error] = "Could not create the tab. This page has reached the tab limit" 
          redirect_to :controller => 'page', :action => 'edit', :id => @page
       else
          tab =  Tab.new
          tab.attributes = params[:tab]
          tab.position = @page.tabs.length + 1
          @page.tabs << tab
          session[:current_tab] = tab.id
          redirect_to :controller => 'page', :action => 'edit', :id => @page
       end
     else
       flash[:notice] = "Please select a Page"
       redirect_to :controller => 'page', :action => 'index'
     end
  end
  
  #show the selected tab. uses ajax to update the tab.
  def show
   if Guide.exists?(@guide)
      @ecurrent = 'current'
      @tabs = @guide.tabs
      @tab  = @tabs.select{ |t| t.id == params[:id].to_i}.first
      session[:current_tab] = @tab.id
      if @tab and request.xhr?
         if @tab.template ==2
          @mods_left  = @tab.left_resources
          @mods_right = @tab.right_resources
        else
          @mods = @tab.tab_resources
        end
        render :partial => 'guide/edit_tab', :layout => false 
      else
        redirect_to :controller => 'guide', :action => 'edit', :id => @guide
      end
    else
        render :text => "Please refresh your browser.", :layout => false 
    end
  end
  
def page_show
    if Page.exists?(@page)
        @ecurrent = 'current'
        @tabs = @page.tabs
        @tab  = @tabs.select{ |t| t.id == params[:id].to_i}.first
        if @tab and request.xhr?
           session[:current_tab] = @tab.id
            if @tab.template ==2
              @mods_left  = @tab.left_resources
              @mods_right = @tab.right_resources
            else
              @mods = @tab.tab_resources
            end
            render :partial => 'page/edit_tab', :layout => false 
        else
            redirect_to :controller => 'page', :action => 'edit', :id => @page
        end  
    else
         render :text => "Please refresh your browser.", :layout => false 
    end     
  end
 
  def sort_tabs
   if params['drag'] then 
      sortables = params['drag'] 
      sortables.each do |id|
        tab = Tab.find(id)
        tab.update_attribute(:position, sortables.index(id) + 1 )
      end
    end
   render :nothing => true 
 end
 
  def delete
   if Guide.exists?(@guide)
    tabs = @guide.tabs
      unless tabs.length == 1
           tab  = tabs.select{ |t| t.id == params[:id].to_i}.first
          tabs.destroy(tab)
          session[:current_tab] = nil
      else
          flash[:error] = "Can not delete the tab. A guide must have at least one tab." 
      end  
      redirect_to :controller => 'guide', :action => 'edit', :id => @guide
    else
       flash[:notice] = "Please select a Guide"
       redirect_to :controller => 'guide', :action => 'index'
    end
  
  end
  
 def page_delete
   if Page.exists?(@page)
      tabs = @page.tabs
      unless tabs.length == 1
         tab  = tabs.select{ |t| t.id == params[:id].to_i}.first
        tabs.destroy(tab)
        session[:current_tab] = nil
      else
        flash[:error] = "Can not delete the tab. A guide must have at least one tab." 
      end  
       redirect_to :controller => 'page', :action => 'edit', :id => @page
    else
       flash[:notice] = "Please select a Page"
        redirect_to :controller => 'page', :action => 'index'
    end
  end
 
 #Sort modules function for drag and drop  
def sort
   if params['left'] then  
    sortables = params['left']
    sortables.each do |id|
      tab_resource = @tab.tab_resources.find(id)
      tab_resource.update_attribute(:position, 2*sortables.index(id) + 1 )
    end
   elsif params['right'] then 
      sortables = params['right'] 
      sortables.each do |id|
        tab_resource = @tab.tab_resources.find(id)
       tab_resource.update_attribute(:position, 2*sortables.index(id) + 2 )
       end
   elsif params['full'] then 
     sortables = params['full'] 
     sortables.each do |id|
      tab_resource = @tab.tab_resources.find(id)
     tab_resource.update_attribute(:position, sortables.index(id) + 1 )
     end
   end
   render :nothing => true 
end

 
 def add_mod
    s = params[:mid1] + params[:mid2]
    unless session[:add_mods].include?(s)
      session[:add_mods] << s
  end
   render :nothing => true 
 end  
 
  def add_modules
     setSessionGuideId
     @amcurrent = 'current'
     @sort = params[:sort] || 'label'
     session[:add_mods] ||= []
     @mods = @user.sort_mods(@sort)
      @mods = paginate_mods(@mods, params[:page] ||= 1, @sort)    
      @search_value = "Search My Modules"
       if request.xhr? 
          render :partial => "shared/add_modules_list", :layout => false
       elsif request.post? and !session[:add_mods].nil?
         @tab.update_resource(session[:add_mods]) 
         @guide.update_users if @guide and @guide.shared?
         session[:add_mods] = nil
         redirect_to :action => "show", :id => @tab.id
      end
  end 
  
  def page_add_modules
     setSessionGuideId
     @amcurrent = 'current'
     @sort = params[:sort] || 'label'
     session[:add_mods] ||= []
     @mods = @user.sort_mods(@sort)
      @mods = paginate_mods(@mods, params[:page] ||= 1, @sort)   
      @search_term = "Search My Modules"
       if request.xhr? 
          render :partial => "shared/add_modules_list", :layout => false
       elsif request.post? and !session[:add_mods].nil?
         @tab.update_resource(session[:add_mods]) 
         @page.update_users if @page and @page.shared?
         session[:add_mods] = nil
         redirect_to :action => "page_show", :id => @tab.id
      end
  end 

    def new_module
       unless params[:mod][:type].empty? 
           @mod = create_module_object(params[:mod][:type])
           @mod.attributes = params[:mod]
           if @mod.save 
             create_and_add_resource(@user,@mod,@tab)
             redirect_to  :controller => 'module',:action => 'edit_content' , :id =>@mod.id, :type => @mod.class
          else
             flash[:error] = "Could not create the module. There were problems with the following fields: #{@mod.errors.full_messages.join(", ")}" 
             flash[:mod_title] = params[:mod][:module_title]  
             flash[:mod_type] = params[:mod][:type] 
             flash[:mod_title_error] = @mod.errors[:module_title]
             flash[:mod_type_error] = @mod.errors[:type]
             redirect_to  :back
          end
        else
             flash[:error] = "Could not create the module. There were problems with the following fields: Content Type"
             if params[:mod][:module_title].empty? 
               flash[:error] =+ "and Module Name can not be blank." 
             end
             flash[:mod_title] = params[:mod][:module_title]  
             flash[:mod_type] = params[:mod][:type] 
             flash[:mod_title_error] = "" unless params[:mod][:module_title]  
             flash[:mod_type_error] = ""
             redirect_to  :back
      end
    end
    
  
 #removes a module from a tab.
  def remove_module
    begin
     resource = @tab.find_resource(params[:id],params[:type] )
     rescue ActiveRecord::RecordNotFound
        redirect_to :back and return
      else 
      @tab.resources.delete(resource)
      redirect_to :back
     end
  end
 
 

   #sets the template 
  def toggle_columns
    num = (@tab.template == 2 ? 1 : 2)
    @tab.update_attribute(:template, num)
    redirect_to :back
 end

private
  def setSessionGuideId
    if @guide
      session[:guide_id] = @guide.id 
    else
      session[:guide_id] = nil
    end
    if @page
      session[:page_id] = @page.id
    else
      session[:page_id] = nil
    end
    session[:tutorial_id] = nil 
  end
end
