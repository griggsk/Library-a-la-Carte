class LoginController < ApplicationController

#must be logged in to view all pages except...
 skip_before_filter :authorize
 before_filter :clear_sessions
 filter_parameter_logging :password, :password_confirmation 
 
 

  def login
    session[:user_id] = nil
    if request.post?
      user = User.authenticate(params[:email], params[:password])
      if user
        session[:user_id] = user.id
        uri = session[:original_uri]
        session[:original_uri] = nil
        redirect_to(uri || {:controller => "dashboard", :action => 'index' })
      else
        flash[:notice]= "Invalid user/password combination. Check that CAPS LOCK is not on and that your email is entered correctly."
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
        flash[:notice]  = "Couldn't send password"
      end
    end
  end
  
  
         
  
end
