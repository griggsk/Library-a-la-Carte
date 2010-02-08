class GuideController < ApplicationController
include Paginating
before_filter :current_guide, :only => [:sort_tabs, :remove_user_from_guide]
before_filter :current_tab, :except => [:index, :index_all, :new,  :destroy, :create]
before_filter :clear_sessions, :only =>[:index]
before_filter :clear_page_sessions, :only =>[:edit]
layout 'tool'


 #list of guides, expects a sort value.has an ajax component to handle the sorting
 def index
   @gcurrent = 'current'
   @sort = params[:sort] || 'name'
   @guides = @user.sort_guides(@sort)
    @guides = paginate_guides(@guides,(params[:page] ||= 1), @sort)
   if request.xhr?
      render :partial => "guides_list", :layout => false
    end
 end
 
 def index_all
   @all = 'all'
    @sort = params[:sort]
    @guides = @user.sort_guides(params[:sort])
   render :partial => "guides_list", :layout => false
 end
 
 #New full guide.
 def new
      @subjects = Subject.get_subject_values
      @guide_types = Master.get_guide_types
      @resources = @user.contact_resources
      @tag_list = ""
   if request.post?
        @guide =  Guide.new
        @guide.create_home_tab
        @guide.attributes = params[:guide]
        if @guide.save 
           session[:guide] = @guide.id
           session[:current_tab] = @guide.tabs.find(:first).id
           @user.add_guide(@guide)
           @guide.add_master_type(params[:types]) 
           @guide.add_related_subjects(params[:subjects])
           @guide.add_tags(params[:tags])
           redirect_to  :action => 'edit', :id => @guide.id
       end
     end  
 end
 
 #create a partial guide. Just takes the title fields to pass validation it is then passed to update for the rest of the fields
 def create
      if request.post?
        @guide =  Guide.new
        @guide.create_home_tab
        @guide.attributes = params[:guide]
        if @guide.save 
           session[:guide] = @guide.id
           session[:current_tab] = @guide.tabs.first.id
           @user.add_guide(@guide)
           redirect_to  :action => 'update', :id => @guide.id
         else
          flash[:notice] = "Could not create the guide. There were problems with the following fields:
                           #{@guide.errors.full_messages.join(", ")}" 
          flash[:guide_title] = params[:guide][:guide_title]  
          flash[:guide_title_error] = ""
          redirect_to :action => 'index', :sort =>"name"
       end
     end  
 end
 
 #update a guides title, add associations to link guides to the master subject and course pages. Also add metadata about the guide.
  def update
     @ucurrent = 'current'
     @subjects = Subject.get_subject_values
     @guide_types = Master.get_guide_types
    begin
      @guide =  @user.guides.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to  :action => 'index'
    else
       @tag_list = @guide.tag_list
      @selected_types =  @guide.masters.collect{|m| m.id}
      @selected_subjs =  @guide.subjects.collect{|m| m.id}
      session[:guide] = @guide.id
      session[:current_tab] = @guide.tabs.find(:first).id
      if request.post?
         @guide.attributes = params[:guide]
         @guide.add_master_type(params[:types]) 
         @guide.add_related_subjects(params[:subjects])
         @guide.add_tags(params[:tags])
         if @guide.save
           redirect_to :action => 'edit', :id => @guide.id
         end
      end
    end
  end


#edit the guides tabs and modules. default shows first tab unless params[tab] is set
  def edit
     @ecurrent = 'current'
    begin
      @guide = @user.guides.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to  :action => 'index'
    else
      session[:guide] = @guide.id
      @tabs = @guide.tabs
      @tab = session[:current_tab] ? @tabs.select{|t| t.id == session[:current_tab].to_i}.first : @tabs.first 
      if @tab.template ==2
        @mods_left  = @tab.left_resources
        @mods_right = @tab.right_resources
      else
        @mods = @tab.tab_resources
      end
      session[:current_tab] = @tab.id
    end  
  end
  
  # Makes a new copy of a module and add it to the user
  def copy
     @ucurrent = 'current'
     @subjects = Subject.get_subject_values
     @guide_types = Master.get_guide_types
    begin
     @guide = @user.guides.find(params[:id])
    rescue 
     redirect_to :action => 'index', :list=> 'mine'
   else
      @tag_list = @guide.tag_list
      @selected_types =  @guide.masters.collect{|m| m.id}
      @selected_subjs =  @guide.subjects.collect{|m| m.id}
     if request.post?
         @new_guide = @guide.clone
         @new_guide.attributes = params[:guide]
         @new_guide.published = false
         @new_guide.add_tags(params[:tags])
        if @new_guide.save
            @user.add_guide(@new_guide)
            @new_guide.add_master_type(params[:types]) 
            @new_guide.add_related_subjects(params[:subjects])
            if params[:options]=='copy'
              @new_guide.copy_resources(@user.id, @guide.tabs)
            else
              @guide.copy_tabs(@guide.tabs)
            end  
            session[:guide] = @new_guide.id
            session[:current_tab] = @new_guide.tabs.first.id
            redirect_to :action => "edit", :id =>@new_guide and return
          else
           flash[:error] = "Please edit the guide title. A guide with this title already exists."  
        end
     end   
   end
 end  
  
 def edit_contact
   begin
      @guide = @user.guides.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to :action => 'index'
    else
       @resources = @user.contact_resources
       @selected = @guide.resource_id
       @mod = @guide.resource.mod if @guide.resource
      if request.post?
         @guide.add_contact_module(params[:contact]) if params[:contact]
         if @guide.save
           flash[:notice] = "The Contact Module was successfully changed."
           redirect_to :action => 'edit_contact'
         end
      end
    end 
  end
  

 #share a guide with other users and remove users from a guide 
  def share
    @shcurrent = 'current'
   begin
      @guide = @user.guides.find(params[:id])
  rescue ActiveRecord::RecordNotFound
      
    flash[:notice] = "Successfully removed from shared guide."
    redirect_to :action => 'index'
  else
    session[:guide] = @guide.id
    @user_list = User.find(:all, :order => "name")
    @guide_owners = @guide.users
  end
end


def share_update
      @guide = @user.guides.find(params[:id])
       to_users = []
      if params[:users] != nil
          params[:users].each do |p|
            new_user = User.find(p)
            if new_user and !@guide.users.include?(new_user)
                new_user.add_guide_tabs(@guide)
                to_users << new_user
            end
          end
          flash[:notice] = "User(s) successfully added and email notification sent."
          send_notices(to_users, @guide)
      else
        flash[:notice] = "Please select at least one user to share with."
      end
      redirect_to :action => 'share', :id => @guide.id and return
  end
  
  def send_notices(users,guide)
      @guide = @user.guides.find(guide)
    users.each do |p|
       new_user = User.find(p)
        begin
         Notifications.deliver_share_guide(new_user.email,@user.email,@guide.guide_name, @user.name)
         rescue Exception => e
                flash[:notice] = "User(s) successfully added. Could not send email"
         else
          flash[:notice] = "User(s) successfully added and email notification sent."
         end
    end
  end
 
  #remove a user from the list of editors via share page
  def remove_user_from_guide
    begin
    user = @guide.users.find_by_id(params[:id])
    rescue Exception => e
     logger.error("Exception in remove_from_user: #{e}" )
     flash[:notice] = "You are trying to access a guide that doesn't yet exist. "
     redirect_to :action => 'index', :list=> 'mine'
    else
    user.delete_guide_tabs(@guide)
    flash[:notice] = "User(s) successfully removed."
    redirect_to :action => 'share', :id => @guide
    end  
  end
  
  #delete the guide from a user. if only one user then deletes the guide else removes the assocations. Move to dgiue model
  def destroy
      begin
      guide = @user.guides.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      logger.error("Attempt to access You are tring to access something that doesn't exist . #{params[:id]}" )
     
      redirect_to :action => 'index'
    else
    if guide.users.length == 1 # if only one owner delete the guide
       @user.guides.delete(guide)
       guide.destroy
    else # just delete the association
        guide.update_attribute(:created_by, guide.users.collect{|u| u.name}.at(1)) if guide.created_by.to_s == @user.name.to_s
         @user.guides.delete(guide)
    end  
    redirect_to :back, :page => params[:page], :sort => params[:sort]
    end
  end
  
  #publish the guide to the guide portal page
  def publish
    begin
      @guide = @user.guides.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to :action => 'index'
    else
      if @guide.resource || @guide.published?
         @guide.toggle!(:published)
          redirect_to :back, :sort=> params[:sort], :page => params[:page]
      else
          flash[:error] = "A contact module is required before you can publish the guide."
          flash[:contact_error] = ""
          redirect_to  :action => 'edit_contact', :id => @guide
      end
     end
  end

 

  
end
