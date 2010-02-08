# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

gem 'active_youtube'
gem 'flickr-fu'
require 'flickr_fu'
class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  #add authorize and local variable to everything
  before_filter :authorize
  before_filter :local_customization
  #You can use either advimage or advimage_uploader for image editing, but only one of these options may be used at a time.
  #Replace advimage with advimage_uploader below to use the image manager
uses_tiny_mce :options => {
                            :theme =>'advanced',
                            :plugins => %w{advimage advlink preview paste fullscreen spellchecker},
                            :theme_advanced_buttons1 => %w{ forecolor bold italic underline link unlink anchor image bullist numlist blockquote hr separator outdent indent pasteword removeformat code undo redo fullscreen preview charmap spellchecker },
                            :theme_advanced_buttons2 => %w{},
                            :theme_advanced_buttons3 => %w{},
                            :spellchecker_languages => "+English=en",
                            :content_css => "/stylesheets/tool.css",
                            :fix_list_elements => true,
                            :fix_table_elements => true,
                            :height => "50",
                            :theme_advanced_resizing => true,
                            :theme_advanced_statusbar_location => 'bottom',
                            :theme_advanced_resize_horizontal => false
                              }
  
 #Authorizations

#check to see if a user is logged in, if not they are redirected to login 
  def authorize
    user = User.find_by_id(session[:user_id])

    unless user
      session[:original_uri] = request.request_uri #remember where the user was trying to go
      flash[:notice]= "Please log in"
      redirect_to(:controller=> "login", :action => "login")
      return false
    else
      @user = user
    end
  end
  
    def student_authorize
      student = Student.find_by_id_and_tutorial_id(session[:student],session[:tutorial])
    unless student
      session[:tut_uri] = request.request_uri #remember where the user was trying to go
      return false
    else
      @student = student
    end
  end

  #check to see if user is admin
  def authorize_admin
     user = User.find_by_id(session[:user_id])

    unless user and  user.is_admin == true
      session[:original_uri] = request.request_uri #remember where the user was trying to go
      flash[:notice]= "Please log in"
      redirect_to(:controller=> "login", :action => "login")
      return false
    else
        @admin = user
        return true
      end
  end

  #create and add a resource to the HABTM relationship for user and page, guides,tutorials
  def create_and_add_resource(user, mod, item=nil)
     mod.update_attribute(:created_by, user.name)
     resource = Resource.create(:mod => mod)
     user.add_resource(resource)
     unless item == nil
       item.add_resource(resource)
     end
  end
  
  #find a particular module
  def find_mod(id, type)
    klass = type.constantize
    return  klass.find(id)
  end
 
 #create a new module
  def create_module_object(klass)
     klass.camelize.constantize.new
 end
 
 #set variables
 def module_types
   @types = Local.first.mod_types
 end

 
def custom_page_data
   @terms = TERMS
   @years = YEARS
end

 #session varables

#returns customizations
   def local_customization
       @local = Local.find(:first)
   end

    #returns the current page in a session 
    def current_page
        @page = Page.find(session[:page]) if session[:page]
    end
  
   
    def current_guide
      @guide = Guide.find(session[:guide]) if session[:guide]
    end
    
   def current_tab
        @tab = Tab.find(session[:current_tab]) if session[:current_tab]
   end
   
   
    #returns the current module in a session 
    def current_module
        @mod = find_mod(session[:mod_id],session[:mod_type]) if session[:mod_id] and session[:mod_type]
   end
   
   def current_tutorial
     @tutorial = Tutorial.find(session[:tutorial]) if session[:tutorial]
   end
   
    def current_student
        @student = Student.find_by_id_and_tutorial_id(session[:student],session[:tutorial])
        return @student ? @student : session[:student] = nil
   end
   
    def current_unit
     @unit = Unit.find(session[:unit]) if session[:unit]
   end
   
  # clean up sessions
  
  
  
  def clear_tab_sessions
    session[:current_tab] = nil if session[:current_tab]
    session[:tab] = nil if  session[:tab]
    session[:page_tabs] = nil if  session[:page_tabs]
    session[:tabs] = nil if  session[:tabs]
  end
  
  def clear_guide_sessions
    session[:guide] = nil if  session[:guide]
  end
  
  def clear_tutorial_sessions
    session[:tutorial] = nil if  session[:tutorial]
    session[:unit] = nil if session[:unit]
  end
  

  def clear_page_sessions
    session[:page] = @page = nil if  session[:page]
  end
  
  def clear_module_sessions
    session[:mod_id] = nil if session[:mod_id]
    session[:mod_type] = nil if  session[:mod_type]
  end
  
  def clear_unit
    session[:unit] = nil if session[:unit]
  end
  
  def clear_student
   session[:student] = nil if session[:student]
  end
  
  def clear_sessions
    clear_tab_sessions
    clear_guide_sessions
    clear_page_sessions
    clear_module_sessions
    clear_tutorial_sessions
    clear_student
  end

  def clean
    ActiveRecord::Base.connection.execute( "
      DELETE FROM sessions
      WHERE NOW() - updated_at > 3600
    " ) if rand( 1000 ) % 10 == 0
  end 
  
 # This method sets the theme for the tinymce editor.  The image theme contains only two buttons 
#  (image and code) where the advanced theme uses all of the available buttons.  To change a theme
#  for a module, add a when statment for the appropriate module (if changing to the image theme) or
#  delete the existing when statment to revert back to the advanced theme 
   def set_theme(mod)
   if !@uses_tiny_mce.blank? 
    case @mod.class.to_s
      when "LibResource":
        @tiny_mce_options[:theme] = "image"
      else
        @tiny_mce_options[:theme] = "advanced"
    end
   end
 end
  
end
