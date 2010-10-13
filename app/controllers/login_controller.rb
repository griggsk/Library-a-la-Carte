#Library a la Carte Tool (TM).
#Copyright (C) 2007 Oregon State University
#See license-notice.txt for full license notice

class LoginController < ApplicationController

#must be logged in to view all pages except...
 skip_before_filter :authorize
 before_filter :clean, :only =>['login']
 filter_parameter_logging :password, :password_confirmation 
 
  def login
    redirect_to :controller => 'sso_login', :action => 'login' if sso_enabled
    session[:user_id] = nil
    if request.post?
      user = User.authenticate(params[:email], params[:password])
      if user
        if user.is_pending == false #do not allow logins for pending users 
          session[:user_id] = user.id
          uri = session[:original_uri]
          session[:login_type] = nil
          session[:original_uri] = nil
          redirect_to(uri || {:controller => "dashboard", :action => 'index' })
        else
          flash.now[:notice]= "Your account is waiting for Administrator approval."
        end
      else
        flash.now[:notice]= "Invalid user/password combination. Check that CAPS LOCK is not on and that your email is entered correctly."
      end
    end
  end

  def logout
    session[:user_id]= nil
    redirect_to(:action => "login")
  end
  
  def forgot_password
    if request.post?
      user= User.find_by_email(params[:user][:email])
      if user and user.set_new_password
        flash[:notice]  = "A new password has been sent by email."
        redirect_to(:action => "login")
      else
        flash.now[:notice]  = "Couldn't send password"
      end
    end
  end
  
  def signup
    if request.post? and !sso_enabled #only use this feature if sso is not enabled
      if verify_recaptcha
        url = url_for :controller => 'admin', :action => 'pending_users'  #Set the url for the admin notifcation email. 
        #If there are any errors @user will contain the error messages that
        #are displayed in the form.  Otherwise flash[:notice] will display a confirmation message and @user will be ignored
        @user = User.create_new_account({:name => params[:user][:name],
                  :email => params[:user][:email],:password => params[:user][:password],
                  :password_confirmation => params[:user][:password_confirmation],:from_login => true})
        if @user.errors.empty? #only send emails and redirect if there were no errors saving the new user
          flash[:notice] = User.send_pending_user_mail(@user,url)
          redirect_to(:action => "login")
        end
      else
        @user = User.new
        @user.errors.add(:recaptcha, "Recaptcha Values were incorrect")
      end
    else
        flash.now[:notice] = "Disable SSO to turn on this feature." unless !sso_enabled
    end
  end  
  
  private
  #randomly clear sessions table
  def clean
    if rand(1000) % 10 == 0
      ActiveRecord::SessionStore::Session.delete_all ['updated_at < ?', 24.hours.ago] 
    end
  end
 
end
