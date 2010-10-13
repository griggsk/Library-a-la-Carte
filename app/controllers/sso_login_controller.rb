#Library a la Carte Tool (TM).
#Copyright (C) 2007 Oregon State University
#See license-notice.txt for full license notice

class SsoLoginController < ApplicationController
 skip_before_filter :authorize
 before_filter :clear_sessions
 before_filter :is_sso_enabled, :except => [:student_login]
 filter_parameter_logging :password, :password_confirmation ,:onid, :email
 layout 'tutorial'
 
  def login
    if user_data = User.authenticate_sso(check_cookie,sso_service_name,sso_service_password,sso_redirect_url) #retrieve user data from the sso cookie and sso authentication server
      session[:user_id] = nil
      if user_data['userinfo']['email'] == ""
        user_data['userinfo']['email'] = user_data['userinfo']['username'] + "@onid.oregonstate.edu"
      end
      #Check to see if the validated sso user has an alaCarte account
      if !@user = User.find_by_email(user_data['userinfo']['email']) #if no account is found, create one and set role to pending
        url = url_for :controller => 'admin', :action => 'pending_users'  #Set the url for the admin notifcation email
        @user = User.create_new_account({:name => user_data['userinfo']['firstname'] + ' ' + user_data['userinfo']['lastname'],
                                :email => user_data['userinfo']['email']})
        if @user.errors.empty? #only send emails and redirect if there were no errors saving the new user
          flash.now[:notice] = User.send_pending_user_mail(@user,url)
        end                   
      else   
        if @user.is_pending == false #do not allow logins for pending users 
          session[:user_id] = @user.id
          uri = session[:original_uri]
          session[:original_uri] = nil
          session[:login_type] = 'sso'
          redirect_to(uri || {:controller => "dashboard", :action => 'index' }) and return
        else
          flash.now[:notice]= "Your account is waiting for Administrator approval."
        end
      end
    else
      redirect_to(sso_redirect_url)
    end
  end

  def student_login
    if student_data = User.authenticate_sso(check_cookie,student_sso_service_name,student_sso_service_password,student_sso_redirect_url) #retrieve user data from the sso cookie and sso authentication server
      @tutorial = Tutorial.find(params[:id]) 
      session[:student]= nil
      session[:quiz]= nil
      session[:saved_student] = nil
      if student_data['userinfo']['email'] == "" #fix for when student has set their email address to private
       student_data['userinfo']['email'] = student_data['userinfo']['username'] + "@onid.oregonstate.edu"
     end
      #Check to see if the validated student has an account for the tutorial
       @student = Student.authenticate(student_data['userinfo']['email'], student_data['userinfo']['username'], @tutorial.id) 
      if !@student.blank? || !@student == false
        session[:student] = @student.id
        uri = session[:tut_uri]
        session[:tut_uri] = nil
        redirect_to(uri || {:controller => 'ort', :action => 'start', :id => @tutorial}) and return
      elsif @student == false
          flash[:notice] = "You don't have an account for this tutorial. Please create an account."
          session[:email] = student_data['userinfo']['email']
          session[:onid] = student_data['userinfo']['username']
          session[:firstname] = student_data['userinfo']['firstname']
          session[:lastname] = student_data['userinfo']['lastname']
          redirect_to :controller => 'sso_login', :action => 'sso_create_account', :id =>@tutorial and return
      else
           flash[:notice] = "Your onid/email combination do not match our records. Please try again."
           redirect_to :controller => 'sso_login' ,:action => 'student_login', :id =>@tutorial and return
      end 
    else
      redirect_to(student_sso_redirect_url + '&id=' + params[:id])
    end
  end
  
    def sso_create_account
     @tutorial = Tutorial.find(params[:id]) 
     session[:student]= nil
     @sections = @tutorial.sections
     if session[:email] == "" #fix for when student has set their email address to private
       session[:email] = session[:onid] + "@onid.oregonstate.edu"
     end
     @email = session[:email] 
     @onid = session[:onid]
     @firstname = session[:firstname] 
     @lastname = session[:lastname]
     if request.post?
      params[:student][:onid] = @onid
      params[:student][:email] = @email
      student = Student.new(params[:student]) 
      student.tutorial_id = @tutorial.id
      if student.save
        redirect_student(@tutorial.id,student)
      else
         flash[:notice] = "Could not create the account."
         flash[:selection] = params[:student][:sect_num]   
         flash[:fname] = params[:student][:firstname]
         flash[:lname] = params[:student][:lastname]
         flash[:selection_error] =  student.errors[:sect_num]   
         flash[:fname_error] = student.errors[:firstname]
         flash[:lname_error] = student.errors[:lastname]
         return
      end  
    end
      @title= @tutorial.full_name + " | Student Account"
      @meta_keywords, @tags = @tutorial.tag_list 
      @meta_description = @tutorial.full_name + " Student Account Creation" 
  end
  
   def redirect_student(tut,student)
        session[:student] = student.id
        uri = session[:tut_uri]
        session[:tut_uri] = nil
        redirect_to(uri || {:controller => 'ort', :action => 'start', :id => tut}) and return
  end
  
  def student_log_out
    Result.clear_all_saved_answers(session[:saved_student])
    session[:saved_student] = nil
    session[:student]= nil
    if cookie = check_cookie #make sure they are logged in through sso and the cookie actually exists
      User.sso_session_destroy(cookie,student_sso_service_name,student_sso_service_password)  #call the sso server and destroy the sso session
    else
      flash[:notice] = "Could not log out"
    end    
    @tutorial = Tutorial.find(params[:id]) 
    redirect_to :controller => 'ort', :action => 'index', :id => @tutorial
  end
  
  def logout
    if session[:login_type] && cookie = check_cookie #make sure they are logged in through sso and the cookie actually exists
      session[:user_id]= nil
      User.sso_session_destroy(cookie,sso_service_name,sso_service_password)  #call the sso server and destroy the sso session
      redirect_to(sso_redirect_url) and return #sso_redirect_url can be set in config/initializers/sso_settings.rb
    else
      session[:user_id]= nil
      if session[:login_type] #if user is logged in through sso redirect to sso login, otherwise go to original method
        redirect_to(sso_redirect_url) and return
      else 
        redirect_to(:controller => "login", :action => "login") and return
      end
    end
  end
 
private
#used as a before filter to not allow the controller to be used when sso is disabled to prevent unnecassary crashes
  def is_sso_enabled
     redirect_to(:controller => 'login', :action => 'login') and return unless sso_enabled
 end
end