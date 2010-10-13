#Library a la Carte Tool (TM).
#Copyright (C) 2007 Oregon State University
#See license-notice.txt for full license notice

class AdminController < ApplicationController
  before_filter :authorize_admin


   def tools
      @tcurrent = 'current'
      @user_count = User.count
      @page_count = Page.count
      @guide_count = Guide.count
      @tutorial_count = Tutorial.count
      @ppage_count = Page.count :all, :conditions => ["published=?", true]
      @apage_count = Page.count :all, :conditions => ["archived=?", true]
      @pguide_count = Guide.count :all, :conditions => ["published=?", true]
      @ptutorial_count = Tutorial.count :all, :conditions => ["published=?", true]
   end
   
    def auto_archive
      pages = Page.find(:all,:conditions => {:published => true})
      guides = Guide.find(:all,:conditions => {:published => true})
      tutorials = Tutorial.find(:all,:conditions => {:published => true})
      pages.each do |page|
        if page.updated_at < Time.now.months_ago(6)
           page.toggle!(:archived)
           page.update_attribute(:published, false)
        end
      end
       guides.each do |guide|
        if guide.updated_at < Time.now.months_ago(12)
           guide.toggle!(:published)
        end
      end
       tutorials.each do |tutorial|
        if tutorial.updated_at < Time.now.months_ago(12)
           tutorial.toggle!(:archived)
           tutorial.update_attribute(:published, false)
        end
      end
      redirect_to :back
    end 
  

   #User Accounts
   def register
     @user = User.new
     url = url_for :controller => 'login', :action => 'login'
     if request.post? 
        @user = User.new(params[:user])
        @user.role = params[:user][:role]
        if @user.save
          begin
              Notifications.deliver_add_user(@user.email, @admin.email, @user.password, url)
           rescue Exception => e
              flash[:notice] = "Could not send email"
              redirect_to  :action => "register" and return
            end
          flash[:notice] = "User successfully added."
          redirect_to(:action => 'users')  and return
        end
     end
   end
   
   def users
    @ucurrent = 'current'
    @all = params[:all]
    users =  User.find(:all,:conditions => "role <> 'pending'", :order => 'name')
    @users =  ( @all == "all" ? users : users.paginate( :per_page => 30, :page => params[:page]))
  end
  
    #edit User accounts
   def edit
     @user = User.find(params[:id])
   end
   
   #update User accounts
   def update
      @user = User.find(params[:id])
      @user.update_attributes(:password=>params[:user][:password], :password_confirmation => params[:user][:password_confirmation], :name => params[:user][:name], :email => params[:user][:email])
      @user.role = params[:user][:role]
      if @user.save
        flash[:notice] = 'User was successfully updated.'
        redirect_to :action => 'users'
      else
        render :action => 'edit'
      end
    end
  
   #delete User accounts
  def destroy
    User.find(params[:id]).destroy
    flash.now[:notice] = "User(s) successfully deleted."
    if request.xhr?
        render :text => "" #delete the table row by sending back a blank string.  The <tr> tags still exist though       
    else
      redirect_to :action => 'users'      
    end
  end
  
   def email_list
     user = User.find(:all)
     @emails = user.collect(&:email).join(', ') 
   end
   
   def pending_users
    @ucurrent = 'current'
    @users = User.find(:all,:conditions => "role = 'pending'").paginate :per_page => 30, :page => params[:page]
  end
  
  def approve
    @user = User.find(params[:id])  
    if @user.update_attribute('role', 'author') #skipping validations by using update_attribute instead of update_attributes
      begin 
        if sso_enabled
          url = url_for :controller => 'sso_login', :action => 'login'   #Set the url to the login page for the approval email
          Notifications.deliver_accept_pending_user(@user.email, @local.admin_email_from, @user.password, url)
        else
          url = url_for :controller => 'login', :action => 'login'   #Set the url to the login page for the approval email
          Notifications.deliver_accept_nonsso_pending_user(@user.email, @local.admin_email_from, @user.password, url)
        end

      rescue Exception => e
        logger.error("Exception in register user: #{e}}" )
        flash[:notice] = "User was successfully approved but email was not able to be sent"
      end
      flash[:notice] = 'User was successfully approved.'
    else
      flash[:notice] = 'User was not approved.'
    end
    redirect_to :action => 'pending_users' and return
  end
  
  #delete User accounts
  def deny
    @user = User.find(params[:id])
    email = @user.email
    @user.destroy
    begin 
      Notifications.deliver_reject_pending_user(email, @local.admin_email_from)
    rescue Exception => e
      logger.error("Exception in register user: #{e}}" )
      flash.now[:notice] = "User was successfully deleted but email was not able to be sent"
    end
    
    flash[:notice] = "User successfully deleted."
    redirect_to :action => 'pending_users'
  end

#Masters

   def masters
    session[:num] = nil
    @masters = Master.paginate :per_page => 30, :page => params[:page], :order => 'value'
  end
  
  def edit_master
    @master = Master.find(params[:id]) 
    if request.post?
      @master.update_attributes(params[:master])
      if @master.save
        flash[:notice] = 'Master was successfully updated.'
        redirect_to :action => 'masters'
      end  
    end
  end
  
  def destroy_master
    Master.find(params[:id]).destroy
    flash[:notice] = "Master successfully deleted."
    redirect_to :action => 'masters'  
  end
  
  def new_masters
     if params.member?("master")#set the number of rows to display
       if params[:master].member?("num")#get the number from the dropdown box
        @num = session[:num] = params[:master][:num]
       end
     else #Save masters and add more button was pressed so get the number from the session[:num]
      flash[:notice] = "Master successfully added."
      @num = session[:num]
     end
     @masters = Array.new(@num.to_i){Master.new}
  end
  
  def create_masters
    @masters = params[:masters].values.collect{ |master| Master.new(master) }
    if  @masters.all?(&:valid?)
      if @masters.each(&:save)
        if params[:commit]=="Save Masters and Add #{session[:num]} More"
          redirect_to :action => 'new_masters' and return
        else
          session[:num] = nil
          redirect_to :action => 'masters' and return
        end
      end
    end
    @num = params[:formCount]
    render :action => 'new_masters'
  end


  #list of subjects
   def subjects
    session[:num] = nil
    @subjects = Subject.paginate :per_page => 30, :page => params[:page], :order => 'subject_code'
   end
 
 #edit subject. Posts back to itself.
  def edit_subject
    @subject = Subject.find(params[:id]) 
    if request.post?
      @subject.update_attributes(params[:subject])
      if @subject.save
        flash[:notice] = 'Subject was successfully updated.'
        redirect_to :action => 'subjects'
      end  
    end
  end
  
  def destroy_subject
    Subject.find(params[:id]).destroy
    flash[:notice] = "Subject successfully deleted."
    redirect_to :action => 'subjects'  
  end
    
    #Store the number of subjects, make new subjects then go to create
   def new_subjects
    if params.member?("subject")#set the number of rows to display
      if params[:subject].member?("num")#get the number from the dropdown box
        @num = session[:num] = params[:subject][:num]
      end
    else #Save masters and add more button was pressed so get the number from the session[:num]
      flash[:notice] = "Subject successfully added."
      @num = session[:num]
    end
    @subjects = Array.new(@num.to_i){Subject.new}
   end
   
   def create_subjects
    @subjects = params[:subjects].values.collect{ |subject| Subject.new(subject) }
    if  @subjects.all?(&:valid?)
      if @subjects.each(&:save)
        if params[:commit]=="Save Subjects and Add #{session[:num]} More"
          redirect_to :action => 'new_subjects' and return
        else
          session[:num] = nil
          redirect_to :action => 'subjects' and return
        end
      end
    end
    @num = params[:formCount]
    render :action => 'new_subjects'
  end


  
   #list of dods
   def dods
    session[:num] = nil
    @dods = Dod.paginate :per_page => 30, :page => params[:page] , :order => 'title' 
   end
 
 #edit dod. Posts back to itself.
  def edit_dod
    @dod = Dod.find(params[:id]) 
    if request.post?
      @dod.update_attributes(params[:dod])
      if @dod.save
        flash[:notice] = 'Database was successfully updated.'
        redirect_to :action => 'dods'
      end  
    end
  end
  
  def destroy_dod
    Dod.find(params[:id]).destroy
    flash[:notice] = "Dod successfully deleted."
    redirect_to :action => 'dods'  
  end
    
    #Store the number of dods, make new dods then go to create
   def new_dods
     @num = session[:num] = params[:dod][:num] unless session[:num]
     @dods = Array.new(session[:num].to_i){Dod.new}
   end
   
   def create_dods
    @dods = params[:dods].values.collect{ |dod| Dod.new(dod) }
    if  @dods.all?(&:valid?)
      if @dods.each(&:save)
        if params[:commit]=="Save Dods and Add 1 More"
          redirect_to :action => 'new_dods' and return
        else
          session[:num] = nil
          redirect_to :action => 'dods' and return
        end
      end
    end
    render :action => 'new_dods'
   end
  
  
  
 def guides
   @user = User.find(params[:id])
   session[:author] = @user.id
   @guides= @user.guides
   @count = @guides.size
 end
 
  def destroy_guide
    guide = Guide.find(params[:id])
    @user = User.find(session[:author])
   if guide.users.length == 1 # if only one owner delete the page
       @user.guides.delete(guide)
       guide.destroy
    else # just delete the association
       @user.guides.delete(guide)
    end  
     flash[:notice] = "Guide successfully deleted."
    redirect_to :back
 end
 
  def archive_guide
   guide = Guide.find(params[:id])
  guide.update_attribute(:published, false)
   redirect_to  :back
 end
 

 
  def assign_guide
   begin
      @guide = Guide.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to :action => 'tools'
  else
    session[:guide] = @guide.id
    @user_list = User.find(:all, :order => "name")
    @guide_owners = @guide.users
  end
end


def guide_update
      @guide = Guide.find(params[:id])
       to_users = []
      if params[:users] != nil
          params[:users].each do |p|
            new_user = User.find(p)
            if new_user and !@guide.users.include?(new_user)
                @guide.share(new_user.id,nil) #add_guide_tabs(@guide)
                to_users << new_user
            end
          end
          flash[:notice] = "User(s) successfully added and email notification sent."
          guide_send_notices(to_users, @guide)
      else
        flash[:notice] = "Please select at least one user to share with."
      end
      redirect_to :action => 'assign_guide', :id => @guide.id and return
  end
  
  def guide_send_notices(users,guide)
      @guide = Guide.find(params[:id])
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
      @guide = Guide.find(params[:id])
    rescue Exception => e
     redirect_to :action => 'tool', :list=> 'mine'
   else
    user = @guide.users.find_by_id(params[:uid])
    @guide.update_attribute(:created_by, @guide.users.at(1).name) if @guide.created_by.to_s == user.name.to_s
    user.delete_guide_tabs(@guide)
    flash[:notice] = "User(s) successfully removed."
    redirect_to :action => 'assign_guide', :id => @guide
    end  
  end
 
 
  def pages
   @user = User.find(params[:id])
    session[:author] = @user.id
   @pages = @user.pages
   @count = @pages.size
 end
 
 def destroy_page
   page = Page.find(params[:id])
    @user = User.find(session[:author])
   if page.users.length == 1 # if only one owner delete the page
       @user.pages.delete(page)
       page.destroy
    else # just delete the association
       @user.pages.delete(page)
    end  
     flash[:notice] = "Page successfully deleted."
    redirect_to :back
 end
 
 def archive_page
   page = Page.find(params[:id])
   page.toggle!(:archived)
   page.update_attribute(:published, false)
   redirect_to  :back
 end
 
  def assign_page
   begin
      @page = Page.find(params[:id])
  rescue ActiveRecord::RecordNotFound
      redirect_to :action => 'tools' and return
  else
    session[:page] = @page.id
    @user_list = User.find(:all, :order => "name")
    @page_owners = @page.users
  end
end


def page_update
      @page = Page.find(params[:id])
       to_users = []
       if params[:users] != nil
          params[:users].each do |p|
            new_user = User.find(p)
            if new_user and !@page.users.include?(new_user)
              @page.share(new_user.id,nil) #user.add_page_tabs(@page)
              to_users << new_user
            end
          end
          flash[:notice] = "User(s) successfully added."
          page_send_notices(to_users, @page)
      else
        flash[:notice] = "Please select at least one user to share with."
      end
      redirect_to :action => 'assign_page', :id => @page.id and return
  end
  
 def page_send_notices(users, page)
    @page = Page.find(params[:id])
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
 
   def remove_user_from_page
    begin
       page = Page.find(params[:id])
    rescue Exception => e
     logger.error("Exception in remove_from_user: #{e}" )
     redirect_to :action => 'index', :list=> 'mine'
   else
    user = page.users.find_by_id(params[:uid])
    page.update_attribute(:created_by, page.users.at(1).name) if page.created_by.to_s == user.name.to_s
    user.delete_page_tabs(page)
    flash[:notice] = "User(s) successfully removed."
    redirect_to :action => 'assign_page', :id => page
    end  
  end
 
 def tutorials
    @user = User.find(params[:id])
     session[:author] = @user.id
    @tutorials = @user.tutorials
    @count = @tutorials.size
 end
 
 def destroy_tutorial
   tutorial = Tutorial.find(params[:id])
    @user = User.find(session[:author])
   if tutorial.users.length == 1 # if only one owner delete the tutorial
       @user.tutorials.delete(tutorial)
       tutorial.destroy
    else # just delete the association
       @user.tutorials.delete(tutorial)
    end  
     flash[:notice] = "Tutorial successfully deleted."
    redirect_to :back
 end
 
 def archive_tutorial
   tutorial = Tutorial.find(params[:id])
   tutorial.toggle!(:archived)
   tutorial.update_attribute(:published, false)
   redirect_to  :back
 end
 
 def assign_tutorial
   @scurrent = 'current'
    begin
      @tutorial = Tutorial.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to  :action => 'tools' and return
    else
     session[:tutorial] = @tutorial.id
    @user_list = User.find(:all, :order => "name")
    @owners = @tutorial.users 
    end
 end
 
 def tutorial_update
   to_users = []
    @tutorial =  Tutorial.find(params[:id])
     if params[:users] != nil
          params[:users].each do |p|
            new_user = User.find(p)
            if new_user and !@tutorial.users.include?(new_user)
              @tutorial.share(1, new_user, params[:copy])
               to_users << new_user
            end
          end
          flash[:notice] = "Tutorial Shared."
           url = url_for :controller => 'ort', :action => 'index', :id => @tutorial
          @message =
                "I've assigned #{@tutorial.full_name} to you. The link to the tutorial is: #{url} .  - admin "
          tutorial_send_notices(to_users,  @message) unless to_users.blank?
      else
        flash[:notice] = "Please select at least one user to share with."
    end
     redirect_to :action => 'assign_tutorial', :id => @tutorial.id and return  
 end
 
 def tutorial_send_notices(users, message)
   users.each do |p|
    user =  User.find(p)
         begin
             Notifications.deliver_share_tutorial(user.email,@user.email, message)
          rescue Exception => e
             flash[:notice] = "Tutorial Shared. Could not send email"
         else
           flash[:notice] = "User(s) successfully added and email notification sent."
        end
   end
 end
 
  def remove_user_from_tutorial
     begin
       @tutorial =  Tutorial.find(params[:id])
    rescue Exception => e
      redirect_to :action => 'tools' and return
    else
       user = User.find(params[:uid])
       @tutorial.update_attribute(:created_by, @tutorial.users.at(1).id) if @tutorial.created_by.to_s == @user.id.to_s
       @tutorial.remove_from_shared(user)
       flash[:notice] = "User(s) successfully removed."
       redirect_to :action => 'assign_tutorial', :id => @tutorial
    end  
  end
  
 #customizations
 def customize_layout
   if request.post?
     @local.update_attributes(params[:local])
     redirect_to(:action => 'view_customizations')  if @local.save
   end
  end
  
  def view_customizations
  end
  
  def customize_search
   if request.post?
     @local.update_attributes(params[:local])
     redirect_to(:action => 'view_customizations')  if @local.save
   end
 end
 
 def customize_content_types
   @guide_types = [['Course Guides', 'pages'], ['Subject Guides', 'guides'], ['Research Tutorials', 'tutorials']]
   @types = MODULES
   @selected = @local.types_list
   @selected_guides = @local.guides_list
   if request.post?
    @local.update_attributes(params[:local])
     redirect_to(:action => 'view_customizations')  if @local.save
   end
   
 end
 
 def customize_admin_email
   if request.post?
     @local.update_attributes(params[:local])
     redirect_to(:action => 'view_customizations')  if @local.save   
   end
 end
 
#called from tools to enable or disable the search.
 def enable_search 
   begin
     @local.toggle!(:enable_search)
     if request.xhr? #if ajax request
        render :partial => "enable_search" ,:locals => {:local => @local} 
     else
        redirect_to_index
      end
    rescue Exception => e
      logger.error("Exception in enable search: #{e}" )
      redirect_to :action => 'index' and return     
    end
 end
end
