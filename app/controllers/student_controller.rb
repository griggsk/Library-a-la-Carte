#Library a la Carte Tool (TM).
#Copyright (C) 2007 Oregon State University
#See license-notice.txt for full license notice

class StudentController < ApplicationController
skip_before_filter :authorize
before_filter :student_authorize, :only =>[:quizzes]
before_filter :current_student, :only =>[:print_quiz, :edit_section]
layout :select_layout
filter_parameter_logging :onid, :email
 
   def login
    redirect_to :controller => 'sso_login', :action => 'student_login', :id=> params[:id] and return if sso_enabled
    @tutorial = Tutorial.find(params[:id]) 
    session[:student]= nil
    session[:quiz]= nil
    session[:saved_student] = nil
    if request.post?
      @student = Student.authenticate(params[:student][:email], params[:student][:onid], @tutorial.id) 
      if !@student.blank? || !@student == false
          redirect_student(@tutorial,@student)
     elsif @student == false
          flash[:notice] = "You don't have an account for this tutorial. Please create an account."
          session[:email] = params[:student][:email]
          session[:onid] = params[:student][:onid]
          redirect_to :action => 'create_account', :id =>@tutorial and return
      else
           flash[:notice] = "Your username/email combination do not match our records. Please try again."
           redirect_to :action => 'login', :id =>@tutorial and return
      end  
    end
      @title= @tutorial.full_name + " |  Student Login" 
      @meta_keywords, @tags = @tutorial.tag_list 
      @meta_description = @tutorial.description  + "Student Login"
  end
  
  def create_account
     @tutorial = Tutorial.find(params[:id]) 
     session[:student]= nil
     @sections = @tutorial.sections
     @email = session[:email] || ""
     @onid = session[:onid] || ""
     session[:onid] = session[:email] = nil
     if request.post?
      student = Student.new(params[:student]) 
      student.tutorial_id = @tutorial.id
      if student.save
        redirect_student(@tutorial.id,student)
      else
         flash[:notice] = "Could not create the account."
         flash[:selection] = params[:student][:sect_num]   
         flash[:fname] = params[:student][:firstname]
         flash[:lname] = params[:student][:lastname]
         flash[:uname] = params[:student][:onid]
         flash[:email] = params[:student][:email] 
         flash[:selection_error] =  student.errors[:sect_num]   
         flash[:fname_error] = student.errors[:firstname]
         flash[:lname_error] = student.errors[:lastname]
         flash[:uname_error] = student.errors[:onid]
         flash[:email_error] = student.errors[:email] 
         return
      end  
    end
      @title= @tutorial.full_name + " | Create Student Account "
      @meta_keywords, @tags = @tutorial.tag_list 
      @meta_description = @tutorial.description + "Student Account Creation" 
  end

  
  def edit_section
      @tutorial = Tutorial.find(params[:id]) 
      @student.update_attribute(:sect_num, params[:student][:sect_num] )
      redirect_to :back, :id =>@tutorial and return
  end
  
  def log_out
    redirect_to :controller => 'sso_login', :action => 'student_log_out', :id=> params[:id] if sso_enabled
    Result.clear_all_saved_answers(session[:saved_student])
    session[:saved_student] = nil
    session[:student]= nil
    @tutorial = Tutorial.find(params[:id]) 
    redirect_to :controller => 'ort', :action => 'index', :id => @tutorial
  end
  
  def forgot_password
     @tutorial = Tutorial.find(params[:id])
     url = url_for(:controller => 'student', :action => 'login', :id =>@tutorial)
     if request.post?
      student = Student.find_by_tutorial_id_and_email(@tutorial.id, params[:student][:email]) if params[:student][:email]
      if student 
        student.send_forgot(url)
        flash[:notice]  = "Your username will be sent to you"
        redirect_to(:action => "login") and return
      else
        flash.now[:notice]  = "Couldn't find you in the system. Try another email or create an account."
      end
    end  
  end
  
  def redirect_student(tut,student)
        session[:student] = student.id
        uri = session[:tut_uri]
        session[:tut_uri] = nil
        redirect_to(uri || {:controller => 'ort', :action => 'start', :id => tut}) and return
  end
  
    def quizzes
      @qcurrent ='current'
      @tutorial = Tutorial.find(params[:id]) 
      session[:tutorial] = @tutorial.id
       @meta_keywords = @tutorial.tag_list 
       @meta_description = @tutorial.description + " Quizzes"
       @title =  @tutorial.full_name + " |  My Quizzes " 
       @sections = @tutorial.sections
       @quizes, @left = @student.quizes(@tutorial)
  end
  
  def print_quiz
      @tutorial = Tutorial.find(params[:id]) 
      session[:tutorial] = @tutorial.id
      @meta_keywords = @tutorial.tag_list 
      @meta_description = @tutorial.description + " Print Quizzes"
      @title =  @tutorial.full_name + " | My Quizzes Print "
       @quizes, @left = @student.quizes(@tutorial)
  end
  
  protected
   def select_layout
    if ['print_quiz'].include?(action_name)
      "print"
    else
     "tutorial"
    end
 end  
  end