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
     if request.post?
       if @guide.reached_limit?
          flash[:error] = "Could not create the tab. This guide has reached the 6 tab limit" 
          redirect_to :controller => 'guide', :action => 'edit', :id => @guide
       else
          tab =  Tab.new
          tab.attributes = params[:tab]
          if tab.save
            @guide.add_tab(tab)
            session[:current_tab] = tab.id
            redirect_to :controller => 'guide', :action => 'edit', :id => @guide
          else
           redirect_to :controller => 'guide', :action => 'edit', :id => @guide
          end
       end
     end
  end
  
    def page_create
     if request.post?
       if @page.reached_limit?
          flash[:error] = "Could not create the tab. This guide has reached the tab limit" 
          redirect_to :controller => 'page', :action => 'edit', :id => @page
       else
          tab =  Tab.new
          tab.attributes = params[:tab]
          if tab.save
            @page.add_tab(tab)
            session[:current_tab] = tab.id
            redirect_to :controller => 'page', :action => 'edit', :id => @page
          else
           redirect_to :controller => 'page', :action => 'edit', :id => @page
          end
       end
     end
  end
  
  #show the selected tab. uses ajax to update the tab.
  def show
    @ecurrent = 'current'
    @tabs = @guide.tabs
    begin
     @tab  = @tabs.select{ |t| t.id == params[:id].to_i}.first
    rescue ActiveRecord::RecordNotFound
      logger.error("You are tring to access something that either doesn't exist or you don't have access to. #{params[:id]}" )
      flash[:notice] = "You are tring to access something that either doesn't exist or you don't have access to."
       redirect_to :controller => 'guide', :action => 'edit', :id => @guide and return
    else 
      session[:current_tab] = @tab.id
      if @tab.template ==2
        @mods_left  = @tab.left_resources
        @mods_right = @tab.right_resources
      else
        @mods = @tab.tab_resources
      end
    end
    if request.xhr?
      render :partial => 'guide/edit_tab', :layout => false 
    else
      redirect_to :controller => 'guide', :action => 'edit', :id => @guide
    end
  end
  
    def page_show
    @ecurrent = 'current'
    @tabs = @page.tabs
    begin
     @tab  = @tabs.select{ |t| t.id == params[:id].to_i}.first
    rescue ActiveRecord::RecordNotFound
       redirect_to :controller => 'page', :action => 'edit', :id => @page and return
    else 
      session[:current_tab] = @tab.id
      if @tab.template ==2
        @mods_left  = @tab.left_resources
        @mods_right = @tab.right_resources
      else
        @mods = @tab.tab_resources
      end
    end
    if request.xhr?
      render :partial => 'page/edit_tab', :layout => false 
    else
      redirect_to :controller => 'page', :action => 'edit', :id => @page
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
    tabs = @guide.tabs
    unless tabs.length == 1
      begin
       tab  = tabs.select{ |t| t.id == params[:id].to_i}.first
      rescue ActiveRecord::RecordNotFound
        logger.error("You are tring to access something that either doesn't exist or you don't have access to. #{params[:id]}" )
        flash[:notice] = "You are tring to access something that either doesn't exist or you don't have access to."
        redirect_to :back
      else 
      tabs.delete(tab)
      end
    else
      flash[:error] = "Can not delete the tab. A guide must have at least one tab." 
    end  
    session[:current_tab] = nil
    redirect_to :controller => 'guide', :action => 'edit', :id => @guide
  end
  
 def page_delete
    tabs = @page.tabs
    unless tabs.length == 1
      begin
       tab  = tabs.select{ |t| t.id == params[:id].to_i}.first
      rescue ActiveRecord::RecordNotFound
        logger.error("You are tring to access something that either doesn't exist or you don't have access to. #{params[:id]}" )
        flash[:notice] = "You are tring to access something that either doesn't exist or you don't have access to."
        redirect_to :back
      else 
      tabs.delete(tab)
      end
    else
      flash[:error] = "Can not delete the tab. A guide must have at least one tab." 
    end  
    session[:current_tab] = nil
    redirect_to :controller => 'page', :action => 'edit', :id => @page
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
 end  
 
  def add_modules
     @amcurrent = 'current'
     @sort = params[:sort] || 'label'
     session[:add_mods] ||= []
     @mods = @user.sort_mods(@sort)
      @mods = paginate_mods(@mods, params[:page] ||= 1, @sort)     
       if request.xhr? 
          render :partial => "shared/add_modules_list", :layout => false
       elsif request.post? and !session[:add_mods].nil?
         @tab.update_resource(session[:add_mods]) 
         session[:add_mods] = nil
         redirect_to :action => "show", :id => @tab.id
      end
  end 
  
  def page_add_modules
     @amcurrent = 'current'
     @sort = params[:sort] || 'label'
     session[:add_mods] ||= []
     @mods = @user.sort_mods(@sort)
      @mods = paginate_mods(@mods, params[:page] ||= 1, @sort)     
       if request.xhr? 
          render :partial => "shared/add_modules_list", :layout => false
       elsif request.post? and !session[:add_mods].nil?
         @tab.update_resource(session[:add_mods]) 
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
   if @tab.template == 2
      @tab.update_attribute(:template, 1)
   else
      @tab.update_attribute(:template, 2)
  end
  redirect_to :back
 end
 
end
