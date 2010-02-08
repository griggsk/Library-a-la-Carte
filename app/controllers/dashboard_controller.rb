class DashboardController < ApplicationController
 before_filter :clear_sessions, :only =>[:index]
layout 'tool'

  def index
    @dcurrent = 'current'
    @cnum = @user.pub_pages.length
    @acnum = @user.arch_pages.length
    @tnum = @user.pub_tuts.length
    @atnum = @user.arch_tuts.length
    @gnum = @user.pub_guides.length
    @mnum = @user.num_modules
    @recents = @user.recent_activity
  end
  
  def my_profile
     begin
     resource = @user.resources.find(params[:rid])
    rescue Exception => e
      redirect_to :action => 'index' and return
    else
       @mod = resource.mod 
    end
    
    
  end
  
  def edit_profile
   @resources = @user.contact_resources
   @selected = @user.resource_id || ""
    if request.post?
     if  params[:contact] != "Select"
        @user.add_profile(params[:contact])
        flash[:notice]="Profile Saved"
        redirect_to :action => 'my_profile' , :rid =>params[:contact] and return
       else
         flash[:notice]="Please select a module from the list."
         redirect_to :action => 'edit_profile' and return
      end
    end
 end
 
  
  def my_account
    if request.post?
      if @user.update_attributes(:password=>params[:user][:password], :password_confirmation => params[:user][:password_confirmation])
        flash[:notice]="Password Changed"
        redirect_to(:action => 'my_account')
      
      end
    end
  end
  
  def account_info
  if request.post?
      if @user.update_attribute(:name, params[:user][:name])and @user.update_attribute(:email, params[:user][:email])
        flash[:notice]="Account Changed"
        redirect_to(:action => 'my_account')
      else
        flash[:notice]="Account Not Changed"
        redirect_to(:action => 'my_account')
      end
    end
  end
  

  
end
