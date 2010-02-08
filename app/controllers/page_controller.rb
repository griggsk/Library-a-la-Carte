class PageController < ApplicationController
  include Paginating
  before_filter :current_page, :only => [:sort, :edit_contact, :edit_relateds, :remove_related, :suggest_relateds, :send_url]
  before_filter :current_tab, :except => [:index, :index_all, :new,  :destroy, :create]
  before_filter :custom_page_data, :only => [:index, :new, :update, :copy]
  before_filter :clear_sessions, :only =>[:index]
  before_filter :clear_guide_sessions, :only =>[:edit]
  layout 'tool'

  
  def index
  #might get slow if listing more than 1000 pages
  #see http://wiki.rubyonrails.org/rails/pages/HowtoPagination
   @pcurrent = 'current'
   @subj_list = Subject.get_subjects
   @sort = params[:sort] || 'name'
   @pages = @user.sort_pages(@sort)
   @pages = paginate_pages(@pages, params[:page] ||= 1,@sort)
   if request.xhr?
      render :partial => "pages_list", :layout => false 
    end
  end
  
 def index_all
   @all = 'all'
   @sort = params[:sort]
   @pages = @user.sort_pages(@sort)
   render :partial => "pages_list", :layout => false
 end
 
  def create
      session[:page]= nil
      if request.post?
        @page =  Page.new
        @page.attributes = params[:page]
        @page.add_subjects(params[:subjects])
        @page.create_home_tab
        if @page.save 
           session[:page] = @page.id
           session[:current_tab] = @page.tabs.first.id
           @user.add_page(@page)
           redirect_to  :action => 'update', :id =>@page.id
        else
          flash[:notice] = "Could not create the page. There were problems with the following fields:
                           #{@page.errors.full_messages.join(", ")}"
         flash[:course_name] = params[:page][:course_name]
         flash[:course_num] = params[:page][:course_num]
         flash[:course_term] = params[:page][:term]
         flash[:course_year] = params[:page][:year]
         flash[:course_campus] = params[:page][:campus]
         flash[:course_sect] = params[:page][:sect_num]
         flash[:course_subj] = params[:subjects].collect{|s|s.to_i} if params[:subjects]
         flash[:course_subj_error] = @page.errors[:subjects] 
         flash[:course_name_error] = @page.errors[:course_name]
         flash[:course_num_error] = @page.errors[:course_num]
         flash[:course_term_error] = @page.errors[:term]
         flash[:course_year_error] = @page.errors[:year]
         flash[:course_sect_error] = @page.errors[:sect_num]
         redirect_to :back
        end 
      end
  end
  
 def new
        @subj_list = Subject.get_subjects
        if request.post? 
          @page =  Page.new
          @page.attributes = params[:page]
          @page.add_subjects(params[:subjects])
          if @page.save 
              @page.create_home_tab
              session[:page] = @page.id
              session[:current_tab] = @page.tabs.first.id
              @user.add_page(@page)
              @page.add_tags(params[:tags])
              @page.add_subjects(params[:subjects])
             redirect_to  :action => 'edit', :id =>@page.id and return
          else
            flash[:course_subj_error] = @page.errors[:subjects] 
            flash[:course_subj] = params[:subjects].collect{|s|s.to_i} if params[:subjects]
         end
       end
  end
  
  def update
   @subj_list = Subject.get_subjects
     @ucurrent = 'current'
    begin
      @page =  @user.pages.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to  :action => 'index' and return
    else
     session[:page] = @page.id
     session[:current_tab] = @page.tabs.first.id
      @selected = @page.subjects.collect{|s| s.id}
      flash[:course_term] = @page.term
    end
      if request.post?
         @page.attributes = params[:page]
         @page.add_tags(params[:tags])
         @page.add_subjects(params[:subjects])
         if @page.save
           redirect_to :action => 'edit', :id =>@page.id and return
         end
      end
  end
 
  
  def copy
     @ucurrent = 'current'
     @subj_list = Subject.get_subjects
    begin
      @page = @user.pages.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to  :action => 'index' and return
    else
      @selected = @page.subjects.collect{|s| s.id}
    end
      if request.post?
         @new_page = @page.clone
         @new_page.attributes = params[:page]
         @new_page.published = false
         @new_page.add_subjects(params[:subjects])
         if @new_page.save
            session[:page] = @new_page.id
            @user.add_page(@new_page)
            if params[:options]=='copy'
              @new_page.copy_resources(@user.id, @page.tabs)  
            else
               @new_page.copy_tabs(@page.tabs)
            end 
             session[:current_tab] = @new_page.tabs.first.id
            redirect_to  :action => 'edit'  , :id =>@new_page.id
         else
           flash[:error] = "Please edit the page title. A course page with this title already exists."
         end
     end
  end
  
  
  #edit page . Gets the modules and template
  def edit
    @ecurrent = 'current'
    begin
      @page = @user.pages.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to  :action => 'index' and return
    else
      session[:page] = @page.id
      @tabs = @page.tabs
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
 
   def edit_contact
    begin
      @page = @user.pages.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to :action => 'index'
    else
       @resources = @user.contact_resources
       @selected = @page.resource_id
       @mod = @page.resource.mod if @page.resource
      if request.post?
         @page.add_contact_module(params[:contact]) if params[:contact]
         if @page.save
           flash[:notice] = "The Contact Module was successfully changed."
           redirect_to :action => 'edit_contact'
         end
      end
    end 
  end
 
 def edit_relateds
      @relateds = @page.related_guides
      @guides = Guide.published_guides
    if request.post?
         @page.add_related_guides(params[:relateds]) if params[:relateds]
         if @page.save
           flash[:notice] = "The Related Subject Guides was successfully changed."
           redirect_to :action => 'edit_relateds' 
         end   
    end
end

def remove_related
  @page.delete_relateds(params[:gid]) if params[:gid]
  redirect_to :action => 'edit_relateds'
end

 def suggest_relateds
      @relateds = @page.suggested_relateds
      @guides = Guide.published_guides
      render :partial => "relateds", :layout => false
 end
 
  #Sort function for drag and drop  
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
  
   def remove_from_recent_list
    if request.post? and params[:altered_list]
      params[:altered_list].each do |gid|
          session[:page_list].delete(gid.to_i)
      end
      if session[:page_list].empty?
         session[:page_list] = nil
         redirect_to :action => 'index', :sort =>"name" and return
      else
        begin
          page = @user.pages.find(session[:page_list].at(0))
        rescue ActiveRecord::RecordNotFound
          session[:page_list].delete(0)
         redirect_to :action => 'index', :sort =>"name" and return
       else
          session[:current_tab] = nil
          redirect_to :action => 'edit' ,:id => page, :sort =>'name'
        end
      end
    else
       redirect_to :back
    end
     
 end
  


  def publish
    begin
      page = @user.pages.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to :action => 'index' and return
     else
       page.toggle!(:published)
       page.update_attribute(:archived, false)
       redirect_to :back, :page => params[:page], :sort => params[:sort]
     end
   end
  
   def archive
     begin
      page = @user.pages.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to  :action => 'index' and return
     else
       page.toggle!(:archived)
       page.update_attribute(:published, false)
       redirect_to :back, :page => params[:page], :sort => params[:sort]
     end
   end

 def share
 @scurrent = 'current'
   begin
      @page = @user.pages.find(params[:id])
  rescue ActiveRecord::RecordNotFound
      logger.error("You are tring to access something that doesn't exist . #{params[:id]}" )
    flash[:notice] = "Successfully removed from shared guide."
      redirect_to :action => 'index' and return
  else
    session[:page] = @page.id
    @user_list = User.find(:all, :order => "name")
    @page_owners = @page.users
  end
end


def share_update
      @page = @user.pages.find(params[:id])
       to_users = []
       if params[:users] != nil
          params[:users].each do |p|
            new_user = User.find(p)
            if new_user and !@page.users.include?(new_user)
              new_user.add_page_tabs(@page)
              to_users << new_user
            end
          end
          flash[:notice] = "User(s) successfully added."
          send_notices(to_users, @page)
      else
        flash[:notice] = "Please select at least one user to share with."
      end
      redirect_to :action => 'share', :id => @page.id and return
  end
  
  def send_notices(users, page)
    @page = @user.pages.find(page)
    users.each do |p|
      new_user = User.find(p)
              begin
                 Notifications.deliver_share_guide(new_user.email,@user.email,@page.header_title, @user.name)
              rescue Exception => e
                flash[:notice] = "User(s) successfully added. Could not send email"
              else
                flash[:notice] = "User(s) successfully added and email notification sent."
              end
   end
  end
 
 #remove a user from the list of editors via share page
  def remove_user_from_page
    begin
       page = Page.find(params[:id])
    rescue Exception => e
     logger.error("Exception in remove_from_user: #{e}" )
     redirect_to :action => 'index', :list=> 'mine'
   else
    user = page.users.find_by_id(params[:uid])
    user.delete_page_tabs(page)
    flash[:notice] = "User(s) successfully removed."
    redirect_to :action => 'share', :id => page
    end  
  end
  
 
#send the page's URL to stakeholders via email
 def send_url
    @sucurrent = 'current'
 #send the page's URL to stakeholders via email
       @page_url = url_for :controller => 'ica', :action => 'index', :id => @page
       @message =
       "A new library course guide has been created for #{@page.header_title}. The link to the page is: #{@page_url}. Please inform your students of the page and include the link in your course material.
Please contact me if you have any questions or suggestions. 
-#{@user.name} "
      if request.post? 
         if params[:email] and params[:body]
             begin
              Notifications.deliver_send_url(params[:email],@user.email,params[:body])
              rescue Exception => e
                logger.error("Exception in send url: #{e}}" )
                flash[:notice] = "Could not send email"
                redirect_to  :action => "send_url" and return
              else
                flash[:notice]  = "The URL was successfully emailed."
                redirect_to :action => "send_url"
             end   
          end
      end
 end
 
 def destroy
   begin
      page = Page.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to :action => 'index' and return
    else
    if page.users.length < 2 # if only one owner delete the page
       @user.pages.delete(page)
       page.destroy
    else # just delete the association
         @user.pages.delete(page)
    end 
    redirect_to :back, :page => params[:page], :sort => params[:sort]
    end
end
 
  #sets the template 
  def toggle_columns
   if @page.template == 2
      @page.update_attribute(:template, 1)
   else
      @page.update_attribute(:template, 2)
   end
   redirect_to :action => "edit" , :id => @page
 end
 
end
