#Library a la Carte Tool (TM).
#Copyright (C) 2007 Oregon State University
#See license-notice.txt for full license notice

class ModuleController < ApplicationController
  include Paginating
  skip_before_filter :authorize, :only =>[:view]
  before_filter :module_types, :except => [:view]
  before_filter :current_page, :only=>[:edit_content, :update, :preview]
  before_filter :current_guide, :only=>[:edit_content, :update, :preview]
  before_filter :current_tutorial, :only=>[:edit_content, :update, :preview]
  before_filter :clear_sessions, :only =>[:index, :new_mod, :new_menu]
  layout 'tool'

      
  def index
   @mcurrent = 'current'
   @sort = params[:sort] || 'name'
   @all = params[:all]
   @list = params[:list] || 'mine'
   @list=='mine' ? ((@mycurrent ='current') and (@globcurrent = '')) : ((@mycurrent ='') and (@globcurrent = 'current'))
   @mods = @user.sort_mods(@sort, @list)
   @all == "all" ? @mods : @mods = paginate_mods(@mods,(params[:page] ||= 1),@sort)
   @search_value ='Search My Modules'
   if request.xhr? 
     if @list == 'mine' 
        render :partial => "mods_list", :layout => false
     else
        render :partial => "global_list", :layout => false
    end
   end
 end

 
 #creates a new module from the my modules list
  def create
       unless params[:mod][:type].empty? 
           @mod = create_module_object(params[:mod][:type])
           @mod.attributes = params[:mod]
           @mod.slug = create_slug(params[:mod][:module_title])
           if @mod.save 
             create_and_add_resource(@user,@mod)
             redirect_to  :action => 'edit_content' , :id =>@mod.id, :type => @mod.class and return
           else
             flash[:notice] = "Could not create the module. There were problems with the following fields: #{@mod.errors.full_messages.join(", ")}" 
             flash[:mod_title] = params[:mod][:module_title]  
             flash[:mod_type] = params[:mod][:type] 
             flash[:mod_title_error] = @mod.errors[:module_title]
             flash[:mod_type_error] = @mod.errors[:type]
             redirect_to  :action => 'index' and return
           end
        else
             flash[:notice] = "Could not create the module. There were problems with the following fields: Content Type"
             if params[:mod][:module_title].empty? 
               flash[:notice] += " and Module Name can not be blank." 
             end
             flash[:mod_title] = params[:mod][:module_title]  
             flash[:mod_type] = params[:mod][:type] 
             flash[:mod_title_error] = "" unless !params[:mod][:module_title].empty? 
             flash[:mod_type_error] = ""
             redirect_to  :action => 'index' and return
      end
 end     
 
 #creates a new module from the Module edit mode. Need this method because when in edit mod we already have a mod so must use form_tag
  def menu_new
    @tags = ""
     if request.post? 
       unless params[:type].empty?
           @mod = create_module_object(params[:type])
           @mod.module_title = params[:name]
           @mod.slug = create_slug(params[:name])
           if @mod.save 
             @mod.add_tags(params[:tags])
             create_and_add_resource(@user,@mod)
             redirect_to  :action => 'edit_content' , :id =>@mod.id, :type => @mod.class and return
           else
            
             flash[:mod_title] = params[:name]  
             flash[:mod_type] = params[:type] 
             flash[:mod_title_error] = @mod.errors[:module_title] 
             flash[:mod_type_error] = @mod.errors[:type]
             @tags = params[:tags] if params[:tags]
             redirect_to  :back and return
          end
       else
          
             flash[:mod_title] = params[:name]  
             flash[:mod_type] = params[:type] 
             @tags = params[:tags] if params[:tags]
             flash[:mod_title_error] = "" unless params[:name] 
             flash[:mod_type_error] = ""
             redirect_to  :back and return
       end
      end
  end

#create a new module from dashboard
def new_mod
  @selected =""
  @tags=""
   if request.post? 
           @mod = create_module_object(params[:mod][:type]) unless params[:mod][:type].empty?
           if @mod
             @mod.attributes = params[:mod]
              @mod.slug = create_slug(params[:mod][:module_title])
             if @mod.save
               @mod.add_tags(params[:tags])
               create_and_add_resource(@user,@mod)
               redirect_to  :action => 'edit_content' , :id =>@mod.id, :type => @mod.class and return
             end
              @selected = params[:mod][:type]
              @tags = params[:tags] if params[:tags]
          end
      
  end
end

  
 def edit_tags
     @etcurrent = 'current'
    begin
      @mod = find_mod(params[:id], params[:type])
     rescue ActiveRecord::RecordNotFound
      redirect_to  :action => 'index' and return
    else
       session[:mod_id] = @mod.id
       session[:mod_type] = @mod.class
       @tags = @mod.tag_list
      if request.post?
           @mod.add_tags(params[:tags])
             flash[:notice] = "Tags Updated"
          redirect_to  :action => 'edit_tags' , :id =>@mod.id, :type => @mod.class and return
      end
    end
  end
  
#edit mode. both create and new redirect here. Update is the save action. 
#Edit also redirects to other edit methods depending on mod type.
def edit_content
    @ecurrent = 'current'
    begin
      @mod = find_mod(params[:id], params[:type])
     rescue ActiveRecord::RecordNotFound
      redirect_to  :action => 'index' and return
    else
       session[:mod_id] = @mod.id
       session[:mod_type] = @mod.class.to_s
       set_theme(@mod)
       case session[:mod_type] 
          when "ReserveResource"
           redirect_to :controller => 'reserve',:action => 'edit_reserves', :id => @mod.id and return
          when "DatabaseResource"
            redirect_to  :controller => 'database',:action => 'edit_databases', :id => @mod.id and return
          when  "UploaderResource"
            redirect_to  :controller => 'uploader', :action => 'edit_uploader', :id => @mod.id and return
          when "RssResource"
            redirect_to  :controller => 'feed', :action => 'edit_rss', :id => @mod.id and return
          when "UrlResource"
           redirect_to  :controller => 'url', :action => 'edit_url', :id => @mod.id  and return
          when "BookResource"
           redirect_to  :controller => 'book', :action => 'edit_book', :id => @mod.id  and return  
          when "VideoResource"
           redirect_to  :controller => 'video', :action => 'edit_video', :id => @mod.id  and return  
          when "QuizResource"
           redirect_to  :controller => 'quiz', :action => 'edit_quiz', :id => @mod.id  and return  
           when "ImageResource"
           redirect_to  :controller => 'image', :action => 'edit_image', :id => @mod.id  and return  
      end
    end
end

#Save mod method for common modules that do not have their own methods
def update
  @ecurrent = 'current'
   @mod ||= find_mod(params[:id], params[:type])
   @mod.attributes = params[:mod] 
      if @mod.save
             Comment.delete(params[:comment_ids])  if params[:comment_ids]
             @mod.update_attribute(:more_info, nil) if params[:more] == "1"
             @mod.add_lf_targets(params[:targets]) if params[:targets]
            redirect_to :action => "preview" , :id =>@mod.id, :type=> @mod.class
       else
         render :edit_content
      end
end



  
# Makes a new copy of a module and add it to the user
  def copy
    begin
     @old_mod = find_mod(params[:id],params[:type])
    rescue Exception => e
     redirect_to :action => 'index', :list=> 'mine'
   else
     case @old_mod.class.to_s 
        when "DatabaseResource"
            redirect_to  :controller => 'database', :action => 'copy_databases', :id => @old_mod.id and return
        when "UploaderResource"
            redirect_to  :controller => 'uploader', :action => 'copy_uploader', :id => @old_mod.id and return
        when "RssResource"
            redirect_to  :controller => 'feed', :action => 'copy_feeds', :id => @old_mod.id and return
        when "UrlResource"
           redirect_to  :controller => 'url', :action => 'copy_url', :id => @old_mod.id  and return
          when "BookResource"
           redirect_to  :controller => 'book', :action => 'copy_book', :id => @old_mod.id  and return  
          when "VideoResource"
           redirect_to  :controller => 'video', :action => 'copy_video', :id => @old_mod.id  and return  
          when "QuizResource"
           redirect_to  :controller => 'quiz', :action => 'copy_quiz', :id => @old_mod.id  and return  
           when "ImageResource"
           redirect_to  :controller => 'image', :action => 'copy_image', :id => @old_mod.id  and return  
      else
         @mod = @old_mod.clone
         @mod.global = false
      end
      if @mod.save
          @mod.label =  @old_mod.label+'-copy'
          create_and_add_resource(@user,@mod)
          flash[:notice] = "Saved as #{@mod.label}"
          redirect_to :action => "edit_content", :id =>@mod.id, :type =>@mod.class and return
      end
   end
 end  

 
def manage
   @cpcurrent = 'current'
    begin
     @mod = find_mod(params[:id],params[:type])
    rescue Exception => e
      redirect_to :back
    else
      @course_pages = @mod.get_pages if @local.guides_list.include?('pages')
      @guides = @mod.get_guides if @local.guides_list.include?('guides')
      @tutorials = @mod.get_tutorials if @local.guides_list.include?('tutorials')
   end 
end

def add_page
   unless session[:page_tabs].include?(params[:tid].to_s)
        session[:page_tabs] << params[:tid]
    end
   render :nothing => true, :layout => false
end

 def add_guide
   unless session[:tabs].include?(params[:tid].to_s)
        session[:tabs] << params[:tid]
    end
    render :nothing => true, :layout => false
end

 def add_tutorial
   unless session[:units].include?(params[:tid].to_s)
        session[:units] << params[:tid]
    end
    render :nothing => true, :layout => false
end


 def add_to_guide
    @sgcurrent = 'current'
    session[:tabs] ||= [] 
    begin
     @mod = find_mod(params[:id],params[:type])
   rescue ActiveRecord::RecordNotFound
      redirect_to  :action => 'index', :list=> 'mine' and return
    else
      @sort = params[:sort] ||= 'name'
      @guides = @user.sort_guides(@sort)
      @guides = paginate_guides(@guides,(params[:page] ||= 1), @sort)
   end  
   if request.xhr?
       render :partial => "add_guide_list", :layout => false
   elsif request.post?
       session[:tabs].each do |tid|
         tab = Tab.find(tid)
         tab.add_module(params[:id],params[:type])
       end
        session[:tabs]=nil
         flash[:message] = "#{@mod.module_title} successfully added to these guides."
       redirect_to :action => "manage", :id =>@mod.id, :type=> @mod.class
    end
 end
 
 def add_to_page
    @cpcurrent = 'current'
   session[:page_tabs] ||= []
   begin
     @mod = find_mod(params[:id],params[:type])
   rescue ActiveRecord::RecordNotFound
      redirect_to  :action => 'index', :list=> 'mine' and return
    else
       @sort = params[:sort] ||= 'name'
       @pages = @user.sort_pages(@sort)
       @pages = paginate_pages(@pages,(params[:page] ||= 1), @sort)
       if request.xhr?
           render :partial => "add_page_list", :layout => false
       elsif request.post?
         session[:page_tabs].each do |tid|
           tab = Tab.find(tid)
           tab.add_module(params[:id],params[:type])
         end
         session[:page_tabs]=nil
         flash[:message] = "#{@mod.module_title} successfully added these pages."
         redirect_to :action => "manage", :id =>@mod.id, :type=> @mod.class
      end
    end
 end
 
  def add_to_tutorial
    @tgcurrent = 'current'
   session[:units] ||= []
   begin
     @mod = find_mod(params[:id],params[:type])
   rescue ActiveRecord::RecordNotFound
      redirect_to  :action => 'index', :list=> 'mine' and return
    else
       @sort = params[:sort] ||= 'name'
       @tutorials =  @user.sort_tutorials(@sort)
       @tutorials = paginate_list(@tutorials,(params[:page] ||= 1), @sort)
       if request.xhr?
           render :partial => "add_tutorial_list", :layout => false
       elsif request.post?
         session[:units].each do |tid|
           unit = Unit.find(tid)
           unit.add_module(params[:id],params[:type])
         end
         session[:units]=nil
         flash[:message] = "#{@mod.module_title} successfully added these tutorials."
         redirect_to :action => "manage", :id =>@mod.id, :type=> @mod.class
      end
    end
 end
 
 
 
 def globalize 
   begin
     @mod = find_mod(params[:id],params[:type])
     @mod.toggle!(:global)
     if request.xhr? #if ajax request, only render the global partial, otherwise refresh the index
        render :partial => "global" ,:locals => {:mod => @mod, :page => @page, :sort => @sort , :all => @all} 
     else
        redirect_to_index
      end
    rescue Exception => e
      logger.error("Exception in globalize: #{e}" )
      redirect_to :action => 'index' and return     
    end
 end
 
 def publish
    begin
      @mod = find_mod(params[:id],params[:type])
      @mod.toggle!(:published)
     if request.xhr? #if ajax request, only render the publish partial, otherwise refresh the index
      render :partial => "publish" ,:locals => {:mod => @mod, :page => @page, :sort => @sort , :all => @all} 
     else
      redirect_to_index
     end
   rescue Exception => e
     logger.error("Exception in publish: #{e}" )
     redirect_to :action => 'index' and return
    end
 end

 def share
   @shcurrent = 'current'
    resource = @user.find_resource(params[:id],params[:type])
    if !resource
      redirect_to :action => 'index', :list=> 'mine' and return
    end
    @mod = resource.mod
    @user_list = User.find(:all, :order => "name")
    @mod_owners = resource.users.uniq
end
  
  
  def share_update
      resource = @user.find_resource(params[:id],params[:type])
       to_users = []
      if params[:users] != nil
          params[:users].each do |p|
            new_user = User.find(p)
             if new_user and resource.users.include?(new_user) == false
               new_user.add_resource(resource)
                to_users << new_user
            end
          end
          flash[:notice] = "User(s) successfully added and email notification sent."
          send_notices(to_users, resource.mod.label)
      else
        flash[:notice] = "Please select at least one user to share with."
      end
      redirect_to :action => 'share',:id =>resource.mod.id, :type=> resource.mod.class and return
  end
  
  def send_notices(users,mod_title)
    users.each do |p|
       new_user = User.find(p)
        begin
           Notifications.deliver_share_module(new_user.email, @user.email,mod_title,@user.name)
         rescue Exception => e
                flash[:notice] = "User(s) successfully added. Could not send email"
         else
          flash[:notice] = "User(s) successfully added and email notification sent."
         end
    end
  end
  
 def preview
   @class ='thumbnail'
    @style ='width:255px; height:220px;'
    begin
      @mod = find_mod(params[:id],params[:type] )
    rescue Exception => e
      redirect_to :back
   else
      @preview = true if @mod.class == QuizResource
    end
  end
  
  def view
    @class ='thumbnail'
    @style ='width:255px; height:220px;'
    begin
      @mod = find_mod(params[:id],params[:type] )
    rescue Exception => e
      redirect_to :back
    end
     @preview = true if @mod.class == QuizResource
    respond_to do |format|
      format.html {render :layout => 'popup'}   #/layouts/popup.html.erb
    end
  end

 #removes a  module from a user through resources from my modules list
  def remove_from_user
    begin
     resource = @user.find_resource(params[:id],params[:type] )
     @user.update_attribute(:resource_id, nil) if @user.resource_id == resource.id
     if resource.users.length == 1 #only 1 owner so delete all associations
       @user.resources.delete(resource)
       resource.delete_mods
       resource.destroy
     else #just delete the association
       resource.mod.update_attribute(:created_by, resource.users.collect{|u| u.name}.at(1)) if resource.mod.created_by.to_s == @user.name.to_s
        @user.resources.delete(resource)
      end 
      if request.xhr? 
        render :text => "" #delete the table row by sending back a blank string.  The <tr> tags still exist though
      else
        redirect_to_index
      end
     rescue Exception => e
       redirect_to :action => 'index', :list=> 'mine'
    end
  end

 #removes a  module from a user through resources from share page
 def remove_user_from_mod
    begin
     resource = @user.find_resource(params[:id],params[:type] )
    rescue Exception => e
     redirect_to :action => 'index', :list=> 'mine'
    else
    user = User.find(params[:user])
    user.resources.delete(resource)
    flash[:notice] = "User(s) successfully removed from editor list."
    redirect_to :action => 'share', :id => resource.mod.id, :type =>resource.mod.class
    end
end
 
 def  redirect_to_index
   if params[:search]#if the delete request came from the search screen, redirect back to search otherwise go to the regular mod list
          redirect_to :controller => 'search',:action => 'index' , :sort => params[:sort], :page => params[:page],  :all => params[:all],:mod => {:search => params[:search]}
   elsif params[:tag]
          redirect_to :controller => 'tagg',:action => 'index' , :sort => params[:sort], :page => params[:page], :all => params[:all], :tag =>params[:tag] and return
   else
        redirect_to :action => 'index', :sort => params[:sort], :page => params[:page],  :all => params[:all]  and return
   end
 end
 
end
