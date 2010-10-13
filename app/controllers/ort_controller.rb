#Library a la Carte Tool (TM).
#Copyright (C) 2007 Oregon State University
#See license-notice.txt for full license notice


class OrtController < ApplicationController
skip_before_filter :authorize
before_filter :clear_student, :clear_tutorial_sessions, :only =>[:published_tutorials, :subject_list]
before_filter :authenticate_pass, :only => [:grades]
layout :select_layout

  def index
    @icurrent ='current'
      @tutorial = Tutorial.find(params[:id], :include => [:tags]) 
      session[:tutorial] = @tutorial.id
      @student = current_student if session[:student]
      @title= @tutorial.full_name + " |  " + @local.tutorial_page_title
      @meta_keywords, @tags = @tutorial.tag_list 
      @meta_description = @tutorial.description.to_s + @local.tutorial_page_title
      @owner = @tutorial.creator
      @updated = @tutorial.updated_at.to_formatted_s(:long)
  end
  
   
  def unit
    @ucurrent ='current'
      @tutorial = Tutorial.find(params[:id]) 
      session[:tutorial] = @tutorial.id
      @student = current_student if session[:student]
      @unit = @tutorial.units.find(params[:uid])
      @title = @tutorial.full_name + " | " + @unit.title 
      @meta_keywords, @tags =  @unit.tag_list 
      @meta_description = @unit.description.to_s + @local.tutorial_page_title
      @owner = @tutorial.creator
      @updated = @tutorial.updated_at.to_formatted_s(:long)
  end
  
  
  def lesson
      @tutorial = Tutorial.find(params[:id]) 
      session[:tutorial] = @tutorial.id
      @student = current_student if session[:student]
       @unit =  @tutorial.units.find(params[:uid]) 
        @mod = find_mod(params[:mid], params[:type])
        if @mod.class== QuizResource
          session[:saved_student] = Student.unique_id unless session[:saved_student]
          if @tutorial.graded? and @mod.graded?
            @student = student_authorize
            if @student
              @taken = @mod.check_student(@student) 
            end
          end
        end
        @title = @tutorial.full_name + " | " + @mod.module_title
        @meta_keywords = @tutorial.tag_list 
        @meta_description =  @local.tutorial_page_title + @unit.description.to_s
        @owner = @tutorial.creator
        @updated = @tutorial.updated_at.to_formatted_s(:long)
        @style ='width:505px; height:500px;'  
  end
  
    def next_lesson
        @tutorial = Tutorial.find(params[:id]) 
        if params[:uid] and params[:mid]
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
                 redirect_to :action => :tutorial_end, :id =>@tutorial
               end  
           end  
        end   
  end
  
  def start
      @tutorial = Tutorial.find(params[:id]) 
      if params[:uid]
               @unit =  @tutorial.units.find(params[:uid]) 
               @next = @unit.first_module
              unless @next == false
                redirect_to :action => :lesson, :id =>@tutorial,:uid=>@unit, :mid => @next.id, :type => @next.class and return
              else
               redirect_to :action => :index, :id =>@tutorial and return
              end
       elsif  !@tutorial.unitizations.blank?
                @unit = @tutorial.unitizations.first.unit
                @next = @unit.first_module
                unless @next == false
                  redirect_to :action => :lesson, :id =>@tutorial,:uid=>@unit, :mid => @next.id, :type => @next.class and return
                else
                   redirect_to :action => :index, :id =>@tutorial and return
                end
       end
       redirect_to :action => :index, :id =>@tutorial and return           
  end
  
  def tutorial_end
      @tutorial = Tutorial.find(params[:id]) 
      session[:tutorial] = @tutorial.id
      @student = current_student if session[:student]
  end
  
  def previous_lesson
    @tutorial = Tutorial.find(params[:id]) 
    if params[:uid] and params[:mid]
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
  
  
  def grades
      @tutorial = Tutorial.find(params[:id]) 
      @meta_keywords = @tutorial.tag_list 
      @meta_description = @tutorial.description.to_s + " Instructor Grades"
      @title =  @tutorial.full_name + " |  Grades"
      @students = @tutorial.students
      @sections = @tutorial.sections
     if request.post?
        if params[:section]
            @sect = params[:section]
            @students = @tutorial.get_students(@sect)
         end
    end  
  end
  
   def export
     @tutorial =  Tutorial.find(params[:id])
     @sect = params[:section]
     @students = @tutorial.get_students(@sect)
    respond_to do |format|
            format.csv do
              response.headers["Content-Type"]        = "text/csv; charset=UTF-8; header=present"
              response.headers["Content-Disposition"] = "attachment; filename=#{@tutorial.to_param}-grades-report.csv"
            end
   end
 end
  
  def published_tutorials
    @from = 'published'
    @meta_keywords = "Tutorials, Library Guides"
    @meta_description =  @local.tutorial_page_title 
    @title = @local.tutorial_page_title 
    @tutorials = Tutorial.get_published_tutorials
    @subjects = @tutorials.collect{|t| t.subject}.flatten.uniq.compact
    @tutorials = @tutorials.select{|t| t.subject.blank?}
    @tags = Tutorial.tag_counts(:start_at => Time.now.last_year, :conditions =>["published = ?", true], :order => 'taggings.created_at desc', :limit => 100)
    master = Master.find_by_value("Tutorial")
    @guides = master.pub_guides if master
  end
  
  def archived_tutorials
    @meta_keywords ="Archived Tutorials, Help Guides"
    @meta_description = "Archived" + @local.tutorial_page_title 
    @title = "Archived" + @local.tutorial_page_title
    @tutorials = Tutorial.get_archived_tutorials
  end
  

  
  
  def tagged
   @tag = params[:id]
   @meta_keywords =  @tag 
   @meta_description = @local.tutorial_page_title + " Tagged with: " +  @tag  
   @title = @local.tutorial_page_title + " | Tagged with: " + @tag 
   @tags = Tutorial.tag_counts(:start_at => Time.now.last_year, :conditions =>["published = ?", true], :order => 'taggings.created_at desc', :limit => 100)
   @tutorials = Tutorial.find_tagged_with(@tag)
 end
 
 def subject_list
   @subject = Subject.find(params[:id])
   @meta_keywords =   @local.tutorial_page_title + @subject.subject_name
   @meta_description =  @local.tutorial_page_title +  @subject.subject_name  
   @title =  @local.tutorial_page_title + " | " + @subject.subject_name 
   @tags = Tutorial.tag_counts(:start_at => Time.now.last_year, :conditions =>["published = ?", true], :order => 'taggings.created_at desc', :limit => 100)
   @tutorials = @subject.get_tutorials
  end
  
  
 
def print
      @tutorial = Tutorial.find(params[:id])  
 end
 
   def print_portal
    if params[:from] == 'published'
      @tutorials = Tutorial.get_published_tutorials
      @tags = Tutorial.tag_counts(:start_at => Time.now.last_year, :conditions =>["published = ?", true], :order => 'taggings.created_at desc', :limit => 100)
 
    else
      @tutorials = Tutorial.get_archived_tutorials
      @tags = Tutorial.tag_counts(:start_at => Time.now.last_year, :conditions =>["archived = ?", true], :order => 'taggings.created_at desc', :limit => 100)
    end 
   end
 
   def feed
       @tutorial = Tutorial.find(params[:id]) 
      @mods = @tutorial.units.collect{|u| u.recent_modules}
      @url = url_for :controller => 'ort', :action => 'index', :id => @tutorial
      @title = @tutorial.full_name
      @description = @tutorial.description
      author = @tutorial.users.select{|u| u.id == @tutorial.created_by}.first
      @author_email = author.email + " ("+author.name+")" if author
      response.headers['Content-Type'] = 'application/rss+xml'
      # Render the feed using an xml.builder template
      respond_to do |format|
        format.xml {render  :layout => false}
      end
   end
   
  protected
  
   def authenticate_pass
     authenticate_or_request_with_http_basic do |u,p|
       Tutorial.authenticate(u.to_i,p)
     end
   end
  
  def select_layout
    if ['print', 'grades'].include?(action_name)
      "print"
    else
     "tutorial"
    end
  end 
  
end
