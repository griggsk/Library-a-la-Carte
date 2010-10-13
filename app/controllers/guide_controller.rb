#Library a la Carte Tool (TM).
#Copyright (C) 2007 Oregon State University
#See license-notice.txt for full license notice

class GuideController < ApplicationController
include Paginating
before_filter :current_guide, :only => [:remove_user_from_guide, :suggest_relateds, :remove_related]
before_filter :clear_sessions, :only =>[:index, :new]
before_filter :clear_page_sessions, :only =>[:edit]

in_place_edit_for :tab, :tab_name
layout 'tool'


 #list of guides, expects a sort value.has an ajax component to handle the sorting
 def index
   @gcurrent = 'current'
   @sort = params[:sort] || 'name'
   @guides = @user.sort_guides(@sort)
    @guides = paginate_guides(@guides,(params[:page] ||= 1), @sort)
    @search_value = "Search My Guides"
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
      session[:guide] = nil
      session[:current_tab] = nil
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
      if session[:current_tab]
        @tab = @tabs.select{|t| t.id == session[:current_tab].to_i}.first 
      end
      if !@tab
        @tab = @tabs.first 
        session[:current_tab] = @tab.id
      end  
      if @tab.template ==2
        @mods_left  = @tab.left_resources
        @mods_right = @tab.right_resources
      else
        @mods = @tab.tab_resources
      end
    end  
  end
  
  # Makes a new copy of a module and add it to the user
  def copy
     @ucurrent = 'current'
     @subjects = Subject.get_subject_values
     @guide_types = Master.get_guide_types
      session[:guide] = nil
      session[:current_tab] = nil
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
              @new_guide.copy_tabs(@guide.tabs)
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
  
  def set_owner
    begin
     @guide = @user.guides.find(params[:id])
    rescue 
     redirect_to :action => 'index', :list=> 'mine' and return
    end 
    @owner = User.find(params[:uid])
    @guide.update_attribute(:created_by, @owner.name) 
    @guide_owners = @guide.users
   if request.xhr?
     render :partial => 'owners', :layout => false 
   else
     redirect_to :action => 'share', :id => @guide.id
   end  
  end
  
 def edit_contact
   begin
      @guide = @user.guides.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to :action => 'index' and return
    else
       @resources = @user.contact_resources
       @selected = @guide.resource_id
       @mod = @guide.resource.mod if @guide.resource
      if request.post?
         @guide.resource_id = params[:contact].to_i  if params[:contact]
         if @guide.save
           flash[:notice] = "The Contact Module was successfully changed."
           redirect_to :action => 'edit_contact'
         end
      end
    end 
  end
  
   def edit_relateds
    begin
      @guide = @user.guides.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to :action => 'index' and return
    end
      @relateds = @guide.related_guides
      @guides = Guide.published_guides
    if request.post?
         @guide.add_related_guides(params[:relateds]) if params[:relateds]
         if @guide.save
           flash[:notice] = "The guides were successfully related"
           redirect_to :action => 'edit_relateds' 
         end   
    end
end
  
def remove_related
  @guide.delete_relateds(params[:gid]) if params[:gid]
   flash[:notice] = "The guide was successfully removed"
  redirect_to :action => 'edit_relateds', :id => @guide
end

 def suggest_relateds
      @relateds = @guide.suggested_relateds
      @guides = Guide.published_guides
      render :partial => "relateds", :layout => false
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
    session[:current_tab] = @guide.tabs.first.id
    @user_list = User.find(:all, :order => "name")
    @guide_owners = @guide.users
     url = url_for :controller => 'srg', :action => 'index', :id => @guide
     @message =
       "I've shared #{@guide.guide_name} with you. The link to the guide is: #{url} .  -#{@user.name} "

  end
end


def share_update
      @guide = @user.guides.find(params[:id])
       to_users = []
      if params[:users] != nil
          params[:users].each do |p|
            new_user = User.find(p)
            if new_user and !@guide.users.include?(new_user)
                @guide.share(new_user.id,params[:copy]) #add_guide_tabs(@guide)
                to_users << new_user
            end
          end
          flash[:notice] = "User(s) successfully added and email notification sent."
          send_notices(to_users, params[:body]) if params[:body]
      else
        flash[:notice] = "Please select at least one user to share with."
      end
      redirect_to :action => 'share', :id => @guide.id and return
  end
  
  def send_notices(users, message)
    users.each do |p|
       new_user = User.find(p)
        begin
         Notifications.deliver_share_guide(user.email,@user.email, message)
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
    user = @guide.users.find(params[:id])
    rescue Exception => e
     redirect_to :action => 'index', :list=> 'mine'
   else
    @guide.update_attribute(:created_by, @guide.users.at(1).name) if @guide.created_by.to_s == user.name.to_s
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
      redirect_to :action => 'index'
    else
      if guide.users.length == 1 # if only one owner delete the guide
         @user.guides.delete(guide)
         guide.destroy
      else # just delete the association
          guide.update_attribute(:created_by, guide.users.at(1).name) if guide.created_by.to_s == @user.name.to_s
           @user.guides.delete(guide)
      end  
      if request.xhr?
         render :text => "" #delete the table row by sending back a blank string.  The <tr> tags still exist though       
      else
        if params[:search]#if the delete request came from the search screen, redirect back to search otherwise go to the regular mod list
          redirect_to :controller => 'search',:action => 'search_guides' , :sort => params[:sort], :page => params[:page],  :all => params[:all],:mod => {:search => params[:search]}
        else
          redirect_to :back, :page => params[:page], :sort => params[:sort]
        end       
      end

    end
  end
  
  #publish the guide to the guide portal page
  def publish
    begin
      @guide = @user.guides.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to :action => 'index'
    else
      if request.xhr? #if ajax request, only render the publish partial, otherwise refresh the index
          render :update do |page|
            if @guide.toggle_published #check if guide has a contact module and toggle published value if it does
              if params[:search]#if the request came from search, send back the search term
                page.replace_html "publish#{@guide.id}" , :partial => "publish" ,:locals => {:guide => @guide, :page => @page, :sort => @sort ,:mod => {:search => params[:search]}}               
              else
                page.replace_html "publish#{@guide.id}" , :partial => "publish" ,:locals => {:guide => @guide, :page => @page, :sort => @sort }                
              end
            else #no contact module specified, redirect to contact module set up page
              flash[:error] = "A contact module is required before you can publish the guide."
              flash[:contact_error] = ""
              page.redirect_to  :action => 'edit_contact', :id => @guide
            end  
        end
      else #not an ajax request so use regular html request
        if @guide.toggle_published #check if guide has a contact module and toggle published value if it does
            if params[:search]#if the publish request came from the search screen, redirect back to search otherwise go to the regular guide list
              redirect_to :controller => 'search',:action => 'search_guides' , :sort => params[:sort], :page => params[:page],  :all => params[:all],:mod => {:search => params[:search]}
            else
              redirect_to :back, :sort=> params[:sort], :page => params[:page]       
            end
        else #no contact module specified, redirect to contact module set up page
            flash[:error] = "A contact module is required before you can publish the guide."
            flash[:contact_error] = ""
            redirect_to  :action => 'edit_contact', :id => @guide
        end
      end
    end
  end
end
