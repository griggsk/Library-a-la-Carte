class OrtController < ApplicationController
skip_before_filter :authorize
before_filter :clear_student, :clear_tutorial_sessions, :only =>[:published_tutorials]
before_filter :authenticate_pass, :only => [:grades]
before_filter :current_student, :only =>[:print_quiz, :edit_section]

layout :select_layout

  def index
    @icurrent ='current'
    begin
      @tutorial = Tutorial.find(params[:id], :include => [:tags]) 
     rescue ActiveRecord::RecordNotFound
      render :status => 404,
      :text => (IO.read(File.join(RAILS_ROOT, 'public', '404.html'))) ,
      :layout => false 
    else
      session[:tutorial] = @tutorial
      @student = current_student if session[:student]
      @title= @tutorial.full_name + " |  " + unless @local.lib_name.blank? then @local.lib_name else "Library Tutorials" end
      @meta_keywords = @tutorial.tag_list 
      @meta_description = @tutorial.description
      @tags = @tutorial.tag_list 
      @sections =@tutorial.sections
    end
  end
  
   
  def unit
    @ucurrent ='current'
    begin
      @tutorial = Tutorial.find(params[:id]) 
     rescue ActiveRecord::RecordNotFound
      render :status => 404,
      :text => (IO.read(File.join(RAILS_ROOT, 'public', '404.html'))) ,
      :layout => false 
    else
      session[:tutorial] = @tutorial
      @student = current_student if session[:student]
      @unit = @tutorial.units.find(params[:uid])
       @title= @tutorial.full_name + " "+@unit.title+" |  " + unless @local.lib_name.blank? then @local.lib_name else "Library Tutorials" end
      @meta_keywords =  @unit.tag_list 
      @meta_description = @unit.description
        @tags = @unit.tag_list
    end
  end
  
  
  def lesson
     begin
      @tutorial = Tutorial.find(params[:id]) 
     rescue ActiveRecord::RecordNotFound
      render :status => 404,
      :text => (IO.read(File.join(RAILS_ROOT, 'public', '404.html'))) ,
      :layout => false 
    else
      session[:tutorial] = @tutorial
       @unit =  @tutorial.units.find(params[:uid]) 
        @mod = find_mod(params[:mid], params[:type])
        if @mod.class== QuizResource and @mod.graded == 1
            @student = student_authorize
            if @student
              @taken = @mod.check_student(@student) 
            else
              flash[:notice]= "Please sign in to take the graded quiz"
              redirect_to(:controller=> "ort", :action => "index", :id => @tutorial) and return
            end
        end
      @title= @tutorial.full_name + "  "+@mod.module_title+" |  " + unless @local.lib_name.blank? then @local.lib_name else "Library Tutorials" end
      @meta_keywords = @tutorial.tag_list 
      @meta_description = @unit.description
        @class ='full'
        @style ='width:505px; height:500px;'  
    end  
  end
  
    def next_lesson
      begin
      @tutorial = Tutorial.find(params[:id]) 
     rescue ActiveRecord::RecordNotFound
      render :status => 404,
      :text => (IO.read(File.join(RAILS_ROOT, 'public', '404.html'))) ,
      :layout => false 
    else
      unless !params[:uid] and !params[:mid]
        @unit =  @tutorial.units.find(params[:uid]) 
        @next = @unit.next_module(params[:mid], params[:type])
        unless @next == false
          redirect_to :action => :lesson, :id =>@tutorial,:uid=>@unit, :mid => @next.id, :type => @next.class and return
        else
          @next_unit = @tutorial.next_unit(@unit.id)
          if @next_unit
            @next = @next_unit.first_module
            redirect_to :action => :lesson, :id =>@tutorial, :uid => @next_unit.id, :mid => @next.id, :type => @next.class and return
         else
           redirect_to :action => 'next_lesson', :id =>@tutorial
         end  
        end  
      else
        if @tutorial.unitizations.length > 0
          @unit = @tutorial.unitizations.first.unit
          @next = @unit.first_module
          redirect_to :action => :lesson, :id =>@tutorial, :uid => @unit.id, :mid => @next.id, :type => @next.class and return
       else
          redirect_to :action => :index, :id =>@tutorial
       end  
      end
   end 
  end
  
    def previous_lesson
      begin
      @tutorial = Tutorial.find(params[:id]) 
     rescue ActiveRecord::RecordNotFound
      render :status => 404,
      :text => (IO.read(File.join(RAILS_ROOT, 'public', '404.html'))) ,
      :layout => false 
    else
      unless !params[:uid] and !params[:mid]
        @unit =  @tutorial.units.find(params[:uid]) 
        @prev = @unit.prev_module(params[:mid], params[:type])
        unless @prev == false
          redirect_to :action => :lesson, :id =>@tutorial,:uid=>@unit, :mid => @prev.id, :type => @prev.class and return
        else
          @prev_unit = @tutorial.prev_unit(@unit.id)
          if @prev_unit
            @prev = @prev_unit.last_module
            redirect_to :action => :lesson, :id =>@tutorial, :uid => @prev_unit.id, :mid => @prev.id, :type => @prev.class and return
         else
           redirect_to :action => 'previous_lesson', :id =>@tutorial
         end  
        end  
      else
        @unit = @tutorial.unitizations.first.unit
        @prev = @unit.first_module
        redirect_to :action => :lesson, :id =>@tutorial, :uid => @unit.id, :mid => @prev.id, :type => @prev.class and return
      end
   end 
  end
  
  def quizzes
    @qcurrent ='current'
      begin
      @tutorial = Tutorial.find(params[:id]) 
     rescue ActiveRecord::RecordNotFound
      render :status => 404,
      :text => (IO.read(File.join(RAILS_ROOT, 'public', '404.html'))) ,
      :layout => false 
    else
      session[:tutorial] = @tutorial
      @student = current_student 
       @meta_keywords = @tutorial.tag_list 
      @meta_description = @tutorial.description + " Quizzes"
       @title =  @tutorial.full_name + " My Quizzes |  " + unless @local.lib_name.blank? then @local.lib_name else "Library Tutorials" end
       @sections =@tutorial.sections
       @quizes, @left = @student.quizes(@tutorial)
    end 
  end
  
  def print_quiz
     begin
      @tutorial = Tutorial.find(params[:id]) 
     rescue ActiveRecord::RecordNotFound
      render :status => 404,
      :text => (IO.read(File.join(RAILS_ROOT, 'public', '404.html'))) ,
      :layout => false 
    else
      session[:tutorial] = @tutorial
       @meta_keywords = @tutorial.tag_list 
      @meta_description = @tutorial.description + " Print Quizzes"
        @title =  @tutorial.full_name + " My Quizzes Print Version |  " + unless @local.lib_name.blank? then @local.lib_name else "Library Tutorials" end
       @quizes, @left = @student.quizes(@tutorial)
    end 
  end
  
  def grades
    begin
      @tutorial = Tutorial.find(params[:id]) 
     rescue ActiveRecord::RecordNotFound
      render :status => 404,
      :text => (IO.read(File.join(RAILS_ROOT, 'public', '404.html'))) ,
      :layout => false 
    else
       @meta_keywords = @tutorial.tag_list 
      @meta_description = @tutorial.description + " Instructor Grades"
       @title =  @tutorial.full_name + " Grades |  " + unless @local.lib_name.blank? then @local.lib_name else "Library Tutorials" end
      @students = @tutorial.students
      @sections = @tutorial.sections
    end  
     if request.post?
        if params[:section]
            @sect = params[:section]
            @students = @tutorial.get_students(@sect)
         end
    end  
  end
  
  def published_tutorials
    @meta_keywords = "Class Assignment Tutorials, Library Help Guides, Academic Research"
    @meta_description =  "Research Tutorials. Online tutorials for students looking to learn more about the process of academic research."
    @title = "Demos and Guides |  " + unless @local.lib_name.blank? then @local.lib_name else "Library Tutorials" end
    @tutorials = Tutorial.get_published_tutorials
    @subjects = @tutorials.collect{|t| t.subject}.flatten.uniq.compact
    @tutorials = @tutorials.select{|t| t.subject.blank?}
    @tags = Tutorial.tag_counts(:start_at => Time.now.last_year, :conditions =>["published = ?", true], :order => 'taggings.created_at desc', :limit => 100)
  end
  
  def archived_tutorials
     @meta_keywords ="Archived Research Tutorials, Tutorials, Library Help Guides"
    @meta_description =  "Archived Research Tutorials"
    @title = "Archived Demos and Guides |  " + unless @local.lib_name.blank? then @local.lib_name else "Library Tutorials" end
    @tutorials = Tutorial.get_archived_tutorials
    @tags = Tutorial.tag_counts(:start_at => Time.now.last_year, :conditions =>["archived = ?", true], :order => 'taggings.created_at desc', :limit => 100)
  end
  
  def student_signin
    @tutorial = Tutorial.find(params[:id]) 
    session[:student]= nil
    @student = Student.authenticate(params[:student][:name], params[:student][:email], params[:student][:onid], @tutorial.id, params[:student][:sect_num] ) 
    if !@student.blank? || !@student == false
       @student.update_attributes(params[:student])
       session[:student] = @student.id
       uri = session[:tut_uri]
        session[:tut_uri] = nil
       redirect_to(uri || {:action => 'index', :id =>@tutorial}) and return
    elsif @student == false
         flash[:notice] = "There was a problem signing in. Make sure you entered your name, a valid email and onid."
         redirect_to :action => 'index', :id =>@tutorial and return
    else
         flash[:notice] = "Our records indicate you have previously signed in to this tutorial with a different onid or section number. Please try again."
         redirect_to :action => 'index', :id =>@tutorial and return
    end  
  end
  
  def edit_section
      @tutorial = Tutorial.find(params[:id]) 
      session[:tutorial] = @tutorial
      @student.update_attribute(:sect_num, params[:student][:sect_num] )
      redirect_to :back, :id =>@tutorial and return
  end
  
  def log_out
    @tutorial = Tutorial.find(params[:id]) 
    session[:student]=nil
    redirect_to :action => 'index', :id => @tutorial
  end
  
    def forgot
      @tutorial = Tutorial.find(params[:id])
      @title = "Login Help |  " + unless @local.lib_name.blank? then @local.lib_name else "Library Tutorials" end
      url = url_for :controller => 'ort', :action => 'index', :id => @tutorial
     if request.post? 
       student= Student.find_by_email(params[:student][:email])
       if student and student.send_forgot(url)
          flash[:notice]  = "Your login information has been sent by email."
           redirect_to :action => 'index', :id =>@tutorial and return
       else
          flash[:notice]  = "The Email address was not found."
          redirect_to :action => 'forgot', :id =>@tutorial and return
       end
     end 
  end
  
  def tagged
   @tag = params[:id]
   @meta_keywords =  @tag 
   @meta_description =  "Library Tutorials Tagged with: " + @tag  
    @title = "Tutorials Tagged with: " + @tag +" |  " + unless @local.lib_name.blank? then @local.lib_name else "Library Tutorials" end
   @tags = Tutorial.tag_counts(:start_at => Time.now.last_year, :conditions =>["published = ?", true], :order => 'taggings.created_at desc', :limit => 100)
   @tutorials = Tutorial.find_tagged_with(@tag)
  end
  
 
  def print
    
  end
  
  def feed
    
  end
  
  protected
   def authenticate_pass
     authenticate_or_request_with_http_basic do |u,p|
       Tutorial.authenticate(u.to_i,p)
     end
   end
  
 def select_layout
    if ['print', 'print_quiz', 'grades'].include?(action_name)
      "print"
    else
     "tutorial"
    end
 end 
  
end
