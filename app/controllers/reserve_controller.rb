#Library a la Carte Tool (TM).
#Copyright (C) 2007 Oregon State University
#See license-notice.txt for full license notice

class ReserveController < ApplicationController
  include ReservesScraper
  before_filter :module_types
  before_filter :current_page
  before_filter :current_module, :except => [:edit_reserves]
  before_filter :current_guide
  before_filter :current_tutorial
  layout 'tool' 

def retrieve_reserves
    if request.xhr?
      #The scraper just wants the URI, not the entire html link tag.
      /href="(.*)"/.match(params[:title])
      link = $1 if $1
      if link
        reserves = search_reserves(nil, link)
        #we have to put the reserves somewhere "safe" across the AJAX request
        #so we tuck it into the session, and then erase it when we are done
        #saving our changes to the module
        session[:reserves] = reserves
      end
       course = params[:title].scan(/\>(.*?)\</) 
       @mod.update_attribute(:course_title, course.to_s)
       render :partial => "reserve/reserved_titles", :locals => {:reserves => reserves} and return
    end
    redirect_to :back
  end
 

def edit_reserves
     begin
        @mod = find_mod(params[:id], "ReserveResource")
     rescue ActiveRecord::RecordNotFound
        flash[:notice] = "You are trying to access a module that doesn't yet exist. "
        redirect_to  :back
     else   
      @ecurrent = 'current'
      @subj_list = Subject.get_subject_values
      if request.xhr?
        @mod.update_attribute(:course_title,nil)
        render :partial => "add_reserves" and return
      end
       unless @mod.course_title.blank? #already have a course set?
            @course_title = @mod.course_title
            @reserves = search_reserves(@mod.course_title)
            session[:reserves] =  @reserves
       end
    end
 end
 
 
 #Save a reserves module. 
 def update_reserves
     if request.xhr?
         @mod.update_attribute(:course_title,"#{params[:page_subject]} #{params[:page_cnum]}")
         @reserves = search_reserves(@mod.course_title)
         session[:reserves] =  @reserves
         render :partial => "reserve/reserved_titles", :locals => {:reserves => @reserves}  
     elsif request.post?
          @mod.attributes = params[:mod] 
          if @mod.save
               desired_reserves = []
               if params[:reserves]
                   #if no box is checked in the view, no param is passed
                   #get the tucked away reserves from the session. The counterpart to this is found
                   #in :retrieve_reserves. 
                   @reserves = session[:reserves] 
                   @reserves.each { |r| desired_reserves << r if params[:reserves].include?(r[:id].to_s) }
                   session[:reserves] = nil 
                end
                @mod.update_attribute(:library_reserves, desired_reserves)
                session[:mod] = nil
                redirect_to :controller => 'module', :action => "preview" , :id =>@mod.id, :type=> @mod.class
          end
     end
 end
  
  
end
