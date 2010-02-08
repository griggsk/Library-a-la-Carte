class TutorialController < ApplicationController
include Paginating
before_filter :clear_sessions, :only => [:index]
layout 'tool'

  def index
   @tcurrent = 'current'
   @sort = params[:sort] || 'name'
   @tutorials = @user.sort_tutorials(@sort)
   @tutorials = paginate_list(@tutorials,(params[:page] ||= 1),@sort)
   if request.xhr?
      render :partial => "tutorials_list", :layout => false
    end
 end
 
  def index_all
    @all = 'all'
    @sort = params[:sort]
    @tutorials = @user.sort_tutorials(@sort)
   render :partial => "tutorials_list", :layout => false
 end
 
 def new
    @tag_list = ""
    @subj_list = Subject.get_subjects
     @tutorial =  Tutorial.new
    if request.post?
         @tutorial.attributes = params[:tutorial]
         @tutorial.created_by = @user.id
         @tutorial.add_tags(params[:tags])
         if @tutorial.save
           session[:tutorial] = @tutorial.id
           @user.add_tutorial(@tutorial)
           case params[:commit]
              when "Save" 
                redirect_to :action => "preview", :id =>@tutorial and return
              when "Save & Add Unit" 
                redirect_to :controller => 'unit', :action => 'add', :id =>@tutorial and return
            end
         end
      end
 end
 
 
 #create a partial tutorial. Just takes the title fields to pass validation it is then passed to update for the rest of the fields
 def create
      if request.post?
        @tutorial =  Tutorial.new
        @tutorial.attributes = params[:tutorial]
        @tutorial.created_by = @user.id
        if @tutorial.save 
           session[:tutorial] = @tutorial.id
           @user.add_tutorial(@tutorial)
           redirect_to  :action => 'update', :id => @tutorial.id
         else
          flash[:error] = "Could not create the tutorial. There were problems with the following fields:
                           #{@tutorial.errors.full_messages.join(", ")}" 
          flash[:tutorial_name] = params[:tutorial][:tutorial_name]  
          flash[:tutorial_name_error] = ""
          redirect_to :action => 'index'
       end
     end  
 end
 
 def update
     @subj_list = Subject.get_subjects
     @ucurrent = 'current'
    begin
      @tutorial =  @user.tutorials.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to  :action => 'index' and return
    else
      session[:tutorial]= @tutorial.id
      @tag_list = @tutorial.tag_list
    end
      if request.post?
         @tutorial.attributes = params[:tutorial]
         @tutorial.add_tags(params[:tags])
         if @tutorial.save
           case params[:commit]
              when "Save" 
                redirect_to :action => "preview", :id =>@tutorial and return
              when "Save & Add Unit" 
                redirect_to :controller => 'unit', :action => 'add', :id =>@tutorial and return
            end
         end
      end
 end
 
 def share
   @scurrent = 'current'
    begin
      @tutorial =  @user.tutorials.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to  :action => 'index' and return
    else
     session[:tutorial] = @tutorial.id
    @user_list = User.find(:all, :order => "name")
    @owners = @tutorial.users 
     url = url_for :controller => 'ort', :action => 'index', :id => @tutorial
     @message =
       "I've shared #{@tutorial.full_name} with you. The link to the tutorial is: #{url} .  -#{@user.name} "
    end
 end
 
 def share_update
   to_users = []
    @tutorial =  @user.tutorials.find(params[:id])
     if params[:users] != nil
          params[:users].each do |p|
            new_user = User.find(p)
            if new_user and !@tutorial.users.include?(new_user)
              @tutorial.share(1, new_user, params[:copy])
               to_users << new_user
            end
          end
          flash[:notice] = "Tutorial Shared."
          send_notices(to_users, params[:body]) if params[:body]
      else
        flash[:notice] = "Please select at least one user to share with."
    end
     redirect_to :action => 'share', :id => @tutorial.id and return  
 end
 
 def send_notices(users, message)
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
 
 def quizes
   @qcurrent = 'current'
    begin
      @tutorial =  @user.tutorials.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to  :action => 'index' and return
    else
      @students = @tutorial.students
      @grades_url = url_for :controller => 'ort', :action => 'grades', :id => @tutorial
      @sections = @tutorial.sections
  end
  if request.post?
        if params[:section]
            @sect = params[:section]
            @students = @tutorial.get_students(@sect)
         end
    end  
 end
 
 def export
    begin
      @tutorial =  @user.tutorials.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to  :action => 'index' and return
    else
     @sect = params[:section]
     @students = @tutorial.get_students(@sect)
   end
    respond_to do |format|
            format.csv do
              response.headers["Content-Type"]        = "text/csv; charset=UTF-8; header=present"
              response.headers["Content-Disposition"] = "attachment; filename=#{@tutorial.name}-grades-report.csv"
            end
   end
 end
 
 def clear_grades
   begin
      @tutorial =  @user.tutorials.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to  :action => 'index' and return
    else
     @sect = params[:section] || nil
     message = @tutorial.clear_grades(@sect)
     flash[:notice] = message
     redirect_to  :action => 'quizes', :id => @tutorial and return
   end
 end
 
 
 def copy
    @subj_list = Subject.get_subjects
      begin
      @tutorial =  @user.tutorials.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to  :action => 'index' and return
    else
      @tag_list = @tutorial.tag_list
      @selected_subj =  @tutorial.subject
    end
    if request.post?
         @new_tutorial = @tutorial.clone
         @new_tutorial.attributes = params[:tutorial]
         @new_tutorial.published = false
         @new_tutorial.add_tags(params[:tags])
        if @new_tutorial.save
           @tutorial.copy(@new_tutorial,@user)
           session[:tutorial]= @new_tutorial.id
           case params[:commit]
              when "Save" 
                redirect_to :action => "preview", :id =>@new_tutorial and return
              when "Save & Add Unit" 
                redirect_to :controller => 'unit', :action => 'add', :id =>@new_tutorial and return
            end
        else
           flash[:error] = "Please edit the tutorial title. A guide with this title already exists."  
           redirect_to  :action => 'copy', :id =>  @tutorial and return
       end
   end
 end  

def preview
  begin
      @tutorial =  @user.tutorials.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to  :action => 'index' and return
  end  
end


  #delete the tutorial from a user. deal with the assocations.
  def destroy
      begin
      @tutorial =  @user.tutorials.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to :action => 'index' and return
    else
       @user.tutorials.delete(@tutorial)
       @tutorial.destroy if !@tutorial.shared? == true  # if only one owner or only one editor delete the tutorial
      redirect_to :action => 'index', :sort=> params[:sort], :page => params[:page] and return
    end
  end
  
def publish
    begin
     tutorial =  @user.tutorials.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to :action => 'index' and return
     else
       tutorial.toggle!(:published)
       tutorial.update_attribute(:archived, false)
       redirect_to :back, :page => params[:page], :sort => params[:sort]
     end
   end
  
   def archive
     begin
      @tutorial =  @user.tutorials.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to  :action => 'index' and return
     else
       @tutorial.toggle!(:archived)
       @tutorial.update_attribute(:published, false)
       redirect_to :back, :page => params[:page], :sort => params[:sort]
     end
   end
  
   def remove_user
     begin
       @tutorial =  @user.tutorials.find(params[:id])
    rescue Exception => e
      redirect_to :action => 'index', :list=> 'mine'
    else
       user = User.find(params[:uid])
       @tutorial.remove_from_shared(user)
       flash[:notice] = "User(s) successfully removed."
       redirect_to :action => 'share', :id => @tutorial
    end  
  end
  
end
