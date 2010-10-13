#Library a la Carte Tool (TM).
#Copyright (C) 2007 Oregon State University
#See license-notice.txt for full license notice

require 'digest/sha1'
require 'xmlrpc/client'

class User < ActiveRecord::Base
  has_and_belongs_to_many :resources
  has_and_belongs_to_many :pages
  has_and_belongs_to_many :guides
  has_many :authorships,  :dependent => :destroy
  has_many :tutorials, :through => :authorships, :order => 'name'
  has_many :my_tutorials, :through => :authorships, :source => :tutorial,
  :conditions => 'authorships.rights = 1', :order => 'name'
  
  validates_presence_of  :name, :email, :password, :password_confirmation, :salt, :role                  
  validates_length_of :name, :within => 2..54
  validates_length_of :password, :within => 5..54
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "Invalid email"  
  validates_uniqueness_of  :email
  attr_accessor :password_confirmation
  validates_confirmation_of :password

#protect these attributes so they can not be set with a POST request  
  attr_protected :id, :salt
  
#check that the password has been set 
  def validate
    errors.add_to_base("Missing password" ) if hashed_psswrd.blank?
  end


  def self.create_and_add_resource(id, mod_list, item=nil)
     user = find(id)
     mod_list.each do |mod|
       mod.update_attribute(:created_by, user.name)
       resource = Resource.create(:mod => mod)
       user.add_resource(resource)
       unless item == nil
         item.add_resource(resource)
       end
    end 
  end
  

#add a page to the HABTM relationship
def add_page(page)
   page.created_by = name
   page.resource_id = resource_id 
   page.save
   pages << page
end

def add_guide(guide)
  guide.created_by = name
  guide.resource_id = resource_id  
  guide.save
  guides << guide
end

def add_guide_tabs(guide)
   guides << guide
   tr =  guide.tabs.collect{|t| t.tab_resources}.flatten
   res = tr.collect{|t| t.resource}.flatten.compact
   resources << res 
end

def add_page_tabs(page)
   pages << page
   tr =  page.tabs.collect{|t| t.tab_resources}.flatten
   res = tr.collect{|t| t.resource}.flatten.compact
   resources << res 
end


def delete_guide_tabs(guide)
   guides.delete(guide)
   tr =  guide.tabs.collect{|t| t.tab_resources}.flatten
   res = tr.collect{|t| t.resource}.flatten.compact
  res.each do |r|
     resources.delete(r)
   end
end

def delete_page_tabs(page)
   pages.delete(page)
   tr =  page.tabs.collect{|t| t.tab_resources}.flatten
   res = tr.collect{|t| t.resource}.flatten.compact
   res.each do |r|
     resources.delete(r)
   end
end

def find_resource(id, type)
   self.resources.find_by_mod_id_and_mod_type(id, type)
end

#add a resource to the HABTM relationship
def add_resource(resource)
    resources << resource 
end

#add a resource to the HABTM relationship
def add_tutorial(tutorial)
    tutorials << tutorial
end


def num_modules
  return resources.collect { |a| a.mod if a and a.mod}.flatten.length
end

def pub_pages
  return pages.select{|p| p.published == true}
end

def arch_pages
  return pages.select{|p| p.archived == true}
end

def pub_tuts
  return tutorials.select{|p| p.published == true}
end

def arch_tuts
  return tutorials.select{|p| p.archived == true}
end

def pub_guides
   return guides.select{|p| p.published == true}
end

def published_tutorials
  return tutorials.select{|p| p.published == true}
end

def archived_tutorials
  return tutorials.select{|p| p.archived == true}
end

def recent_activity
  mods = resources.collect {|a| a.mod }.select{|m| m and m.updated_at >= 7.days.ago}
  icaps = pages.select{|p| p and p.updated_at >= 7.days.ago}
  srgs = guides.select{|g|g and  g.updated_at >= 7.days.ago}
  orts = tutorials.select{|t|t and  t.updated_at >= 7.days.ago}
  recents =  mods[0..5] + icaps[0..5] + srgs[0..5] + orts[0..5]
  return recents.sort { |x,y| y.updated_at <=> x.updated_at } 
end

def module_tags
  return resources.collect {|a| a.mod.tag_list if a.mod }.flatten.uniq
end

def find_mods_tagged_with(tag)
  return resources.collect {|a| a.mod if a.mod and a.mod.tag_list.include?(tag) }.compact.uniq
end

def find_resource(id, type)
   return resources.find_by_mod_id_and_mod_type(id, type)
end

def add_profile(rid)
  update_attribute('resource_id', rid)
end

def get_profile
  return (Resource.exists?(resource_id) ? Resource.find(resource_id).mod : "")
end

def contact_resources
 contacts =[]
 res = resources.collect { |a| a if a.mod and a.mod.content_type == "Librarian Profile" || a.mod.content_type == "Custom Content" || a.mod.content_type == "Course Widget"  }.compact
 contacts = res.sort! {|a,b|  a.mod.send('label').downcase <=> b.mod.send('label').downcase} unless res.empty?
 return contacts
end

  #sorts the modules from the search by the sort_by value
  def sort_search_mods(sort_by,search_results)
    sort,reverse = mod_sort_by_values(sort_by)  #determine the value to sort by and which direction to sort
    return  modules(sort, reverse,search_results)
  end
  
  #returns a list of modules for my modules and global modules view
  def sort_mods(sort_by, list_by = nil)
      sort,reverse = mod_sort_by_values(sort_by)  #determine the value to sort by and which direction to sort
      case list_by
        when "global" then (mods =  Resource.global_modules(sort, reverse))
        else  (mods = modules(sort, reverse))
      end
      return mods
  end
  
  #get the users modules through resources
def modules(s = nil, rev = nil,list = nil)
    s = (s.nil? ? "label" : s)
    mods = (list == nil ? resources.collect {|a| a.mod if a and a.mod}.compact : list)

    if s == "label"  || s == "content_type" || s == "created_by" #not a date or special case so we need to downcase to normalize data
       mods =  mods.sort!{|a,b| a.send(s).downcase <=> b.send(s).downcase }
    elsif s == "published"
       mods =  mods.sort_by {|a|[a.published? ? 0 : 1,a.label]}
    elsif s == "global"
       mods =  mods.sort_by {|a|[a.global? ? 0 : 1,a.label]}
    elsif s == "used"
       mods =  mods.sort_by {|a|[a.used? ? 0 : 1,a.label]}
    elsif s == "shared"
       mods =  mods.sort_by {|a|[a.shared? ? 0 : 1,a.label]}
    else #sort by date DESC
       mods = mods.sort!{|a,b| b.send(s) <=> a.send(s)} 
    end 
    
    mods = mods.reverse if rev == 'true'
    return mods.uniq
end 


  #determines value to sort by and which direction to sort by
  def mod_sort_by_values(sort_by)
    case sort_by
      when "name"  then  (sort = "label")  and (reverse = "false")
      when "date"   then (sort =  "updated_at")  and (reverse = "true")
      when "type" then (sort =  "content_type")  and (reverse = "false")
      when "author"  then (sort =  "created_by")  and (reverse = "false")
      when "publish"  then (sort =  "published")  and (reverse = "false")
      when "shared"  then (sort =  "shared")  and (reverse = "false")
      when "used"  then (sort =  "used")  and (reverse = "false") 
      when "global"  then (sort =  "global")  and (reverse = "false")
      when "name_reverse"  then (sort =  "label") and (reverse = "true")
      when "date_reverse"   then (sort =  "updated_at") and (reverse = "false")
      when "type_reverse" then (sort =  "content_type") and (reverse = "true")
      when "author_reverse"  then (sort =  "created_by") and (reverse = "true")
      when "publish_reverse"  then (sort =  "published") and (reverse = "true")
      when "global_reverse"  then (sort =  "global") and (reverse = "true")
      when "shared_reverse"  then (sort =  "shared")  and (reverse = "true")
      when "used_reverse"  then (sort =  "used")  and (reverse = "true")
      else (sort = "label")  and (reverse = "false")
     end
    return sort,reverse
  end

  def sort_search_guides(sort_by,search_results)
    sort,reverse = guide_sort_by_values(sort_by)  #determine the value to sort by and which direction to sort
    return sorted_guides(sort,reverse,search_results)
  end
  
  def sort_guides(sort_by)
       sort,reverse = guide_sort_by_values(sort_by)  #determine the value to sort by and which direction to sort
       return sorted_guides(sort,reverse,guides)  
   end
   
   def sorted_guides(sort, reverse, list)
    if sort == "guide_name"  #not a date so we need to downcase to normalize data
      guides = list.sort!{|a,b| a.send(sort).downcase <=> b.send(sort).downcase }
    elsif sort == "published"
      guides = list.sort_by {|a|[a.published? ? 0 : 1,a.guide_name]}#Couldn't use the default search because this is a boolean value
     elsif sort == "shared"
      guides = list.sort_by {|a|[a.shared? ? 0 : 1,a.guide_name]}
    else #sort by date DESC
      guides = list.sort!{|a,b| b.send(sort) <=> a.send(sort)} 
    end  
    guides = guides.reverse if reverse == 'true'
    return guides.uniq
   end
   
   #determines value to sort by and which direction to sort by
  def guide_sort_by_values(sort_by)
    case sort_by
      when "name"  then  (sort = "guide_name")  and (reverse = "false")
      when "date"   then (sort =  "updated_at")  and (reverse = "true")
      when "publish"   then (sort =  "published")  and (reverse = "false")
      when "shared"  then (sort =  "shared")  and (reverse = "false")
      when "name_reverse"  then (sort =  "guide_name") and (reverse = "true")
      when "date_reverse"   then (sort =  "updated_at") and (reverse = "false")
      when "publish_reverse"   then (sort =  "published")  and (reverse = "true")
      when "shared_reverse"  then (sort =  "shared")  and (reverse = "true")
      else (sort = "guide_name")  and (reverse = "false")
     end
    return sort,reverse
  end
  

  def sort_search_pages(sort_by,search_results)
    sort,reverse = page_sort_by_values(sort_by)  #determine the value to sort by and which direction to sort
   return sorted_pages(sort,reverse,search_results)  
  end
  
     
  def sort_pages(sort_by)
       sort,reverse = page_sort_by_values(sort_by)  #determine the value to sort by and which direction to sort
       return sorted_pages(sort,reverse,pages)  
  end
    
    def sorted_pages(sort, reverse, list)
      if sort == "course_name"  #not a date so we need to downcase to normalize data
        pages = list.sort!{|a,b| a.send(sort).downcase <=> b.send(sort).downcase }
      elsif sort == "published"
        pages = list.sort_by {|a|[a.published? ? 0 : 1,a.course_name]}#sorts by the boolean value in published then by the course name
      elsif  sort == "archived"
        pages = list.sort_by {|a|[a.archived? ? 0 : 1,a.course_name]}
      elsif  sort == "shared"
        pages = list.sort_by {|a|[a.shared? ? 0 : 1,a.course_name]}  
      else #sort by date DESC
        pages = list.sort!{|a,b| b.send(sort) <=> a.send(sort)} 
      end  
      pages = pages.reverse if reverse == 'true'
      return pages.uniq
    end
   #determines value to sort by and which direction to sort by
  def page_sort_by_values(sort_by)
    case sort_by
      when "name"  then  (sort = "course_name")  and (reverse = "false")
      when "date"   then (sort =  "updated_at")  and (reverse = "true")
      when "publish"   then (sort =  "published")  and (reverse = "false")
      when "archive"   then (sort =  "archived")  and (reverse = "false")
      when "shared"  then (sort =  "shared")  and (reverse = "false")
      when "name_reverse"  then (sort =  "course_name") and (reverse = "true")
      when "date_reverse"   then (sort =  "updated_at") and (reverse = "false")
      when "shared_reverse"  then (sort =  "shared")  and (reverse = "true")
      when "publish_reverse"   then (sort =  "published")  and (reverse = "true")
      when "archive_reverse"   then (sort =  "archived")  and (reverse = "true")
      else (sort = "course_name")  and (reverse = "false")
     end
    return sort,reverse
  end

  def sort_search_tutorials(sort_by,search_results)
    sort,reverse = tutorial_sort_by_values(sort_by)  #determine the value to sort by and which direction to sort
    return sorted_tuts(sort,reverse,search_results) 
  end
  
    def sort_tutorials(sort_by)
       sort,reverse = tutorial_sort_by_values(sort_by)  #determine the value to sort by and which direction to sort
       return sorted_tuts(sort,reverse,my_tutorials) 
   end
   
   def sorted_tuts(sort, reverse, list)
     if sort == "name"  #not a date so we need to downcase to normalize data
      tutorials = list.sort!{|a,b| a.send(sort).downcase <=> b.send(sort).downcase }
    elsif sort == "published"
      tutorials = list.sort_by {|a|[a.published? ? 0 : 1,a.name]}
    elsif  sort == "archived"
      tutorials = list.sort_by {|a|[a.archived? ? 0: 1,a.name]}
    elsif  sort == "shared"
      tutorials = list.sort_by {|a|[a.shared? ? 0: 1,a.name]}
    else #sort by date DESC
      tutorials = list.sort!{|a,b| b.send(sort) <=> a.send(sort)} 
    end  
    tutorials = tutorials.reverse if reverse == 'true'
    return tutorials.uniq
  end
  
  #determines value to sort by and which direction to sort by
  def tutorial_sort_by_values(sort_by)
    case sort_by
      when "name"  then  (sort = "name")  and (reverse = "true")
      when "date"   then (sort =  "updated_at")  and (reverse = "false")
      when "publish"   then (sort =  "published")  and (reverse = "true")
      when "archive"   then (sort =  "archived")  and (reverse = "true")
      when "shared"  then (sort =  "shared")  and (reverse = "true")
      when "name_reverse"  then (sort =  "name") and (reverse = "false")
      when "date_reverse"   then (sort =  "updated_at") and (reverse = "true")
      when "publish_reverse"   then (sort =  "published")  and (reverse = "false")
      when "archive_reverse"   then (sort =  "archived")  and (reverse = "false")
      when "shared_reverse"  then (sort =  "shared")  and (reverse = "false")
      else (sort = "name")  and (reverse = "false")
     end
    return sort,reverse
  end

   
#sorts a users units through tutorials    
    def sort_units(sort_by)
      sort = case sort_by
               when "name"  then "title"
               when "date"   then "updated_at"
               when "name_reverse"  then "title"
               when "date_reverse"   then "updated_at"
               else "title"
           end
          units = my_tutorials.collect{|t| t.units if t}.flatten.uniq
          if sort == "updated_at" 
              units = units.sort!{|a,b| b.send(sort) <=> a.send(sort)} 
          else 
             units = units.sort!{|a,b| a.send(sort).downcase <=> b.send(sort).downcase } 
          end  
           if sort_by == 'name_reverse' || sort_by =='date_reverse'
            units = units.reverse 
          end
          return  units
    end
    
    

#authentication and account
  
#return a user if they are hashed password matches the one stored for that user in the database  
  def self.authenticate(email, password)
    user = self.find_by_email(email)
    if user
      expected_password = encrypt(password, user.salt)
      if user.hashed_psswrd != expected_password
        user = nil
      end
    end
    user
  end
  
 def self.authenticate_sso(cookie,sso_service_name,sso_service_password,sso_redirect_url)
    if cookie
      sso_session_data = self.validate_cookie(cookie,sso_service_name,sso_service_password)#use sid from sso cookie to find out if cookie is still valid
      if sso_session_data['valid'] == true        #a value of 1 means the cookie is valid and 0 means it is not
        user_data = self.getUserInfo(cookie,sso_service_name,sso_service_password)         #retrieve user data from validated sso cookie
      else 
        user_data = nil
      end 
    else  
        user_data = nil
    end 
    return user_data
 end
 #End the session on the sso server and delete the cookie
 def self.sso_session_destroy(sso_session_id,sso_service_name,sso_service_password)
    server = XMLRPC::Client.new("secure.onid.oregonstate.edu","/sso/rpc",443,nil,nil,nil,nil,1,0) #Had to send all of the parameters to this function because the 443 for the port was not the default and we had to set the ssl flag as well
    server.call('sso.session_destroy',sso_service_name + ":" + sso_service_password,sso_session_id)#sso_service_password and sso_session_id can be set in config/initializers/sso_settings.rb
  end
 
#creates accounts for alaCarte users
  def self.create_new_account(params)
    user = User.new
    new_password = user.generate_password  #This password is not actually being used.  It is just there so we don't have blank password fields for the accounts
    if(params[:from_login])#Check to see if the request is going to contain password information (meaning that it came from /login/request_account as oppossed to sso_login)
      user = User.new(:name => params[:name],:email => params[:email],:password => params[:password],:password_confirmation => params[:password_confirmation])
    else
      user = User.new(:name => params[:name],:email => params[:email],:password => new_password,:password_confirmation => new_password)
    end
    user.role = "pending"
    user.save

    return user
  end

def self.send_pending_user_mail(user,url)
    local = Local.find(:first)  #need to get a locals object to get the email addresses to send to and from
    begin   
        Notifications.deliver_add_pending_user(user.email, local.admin_email_from)
        Notifications.deliver_notify_admin_about_pending_user(local.admin_email_to, local.admin_email_from,url)
        msg = "An account was created for you.  It is now waiting for administrator approval."
    rescue Exception => e
        logger.error("Exception in register user: #{e}}" )
        msg = "Could not send email"
    end
    return msg
end

#create instance variable for password  
  def password
    @password
  end

#set the variable 'password' and store the encrypted version
  def password=(pwd)
    @password = pwd
    self.salt = User.random_string(10) if !self.salt?
    self.hashed_psswrd = User.encrypt(self.password, self.salt)
  end
 
#generate a new random password, change the users password to the new password, and email new password to the user
def set_new_password
    new_pass = User.random_string(10)
    self.password = self.password_confirmation = new_pass
    self.save    
    Notifications.deliver_forgot_password(self.email, self.password)
end 

def is_admin
 return self.role == 'admin'
end

def is_pending
 return self.role == 'pending'
end

def generate_password
  return User.random_string(10)
end

# Uses ActsAsFerret to first search the given index and returns only resources that belong to the user via the intersection operator
def search(search_term,klass,index)
      search_results = ActsAsFerret.find("#{search_term}","#{index}",:per_page => 100)
      return (search_results & klass)
end

private
#create a unique salt value, combine it with the plaintext password into a single string, and
#then run an SHA1 digest on the result, returning a 40 character string of hex digits
  def self.encrypt(password, salt)
    string_to_hash = password + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end
 
  
#generate a random password consisting of strings and digits, returning a newpassword of length equal
#to parameter len
  def self.random_string(len)
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
  end

#verifies that the sso cookie is still valid
  def self.validate_cookie(sso_session_id,sso_service_name,sso_service_password)
      server = XMLRPC::Client.new("secure.onid.oregonstate.edu","/sso/rpc",443,nil,nil,nil,nil,1,0) #Had to send all of the parameters to this function because the 443 for the port was not the default and we had to set the ssl flag as well
      user_data = server.call('sso.session_check',sso_service_name + ":" + sso_service_password,sso_session_id,1)#sso_service_password and sso_session_id can be set in config/initializers/sso_settings.rb
      return user_data
  end
 
 #retrieve the user information from the SSO session data.  
  def self.getUserInfo(sso_session_id,sso_service_name,sso_service_password)
    server = XMLRPC::Client.new("secure.onid.oregonstate.edu","/sso/rpc",443,nil,nil,nil,nil,1,0) #Had to send all of the parameters to this function because the 443 for the port was not the default and we had to set the ssl flag as well
    user_data = server.call('sso.session_userinfo',sso_service_name + ":" + sso_service_password,sso_session_id)#sso_service_password and sso_session_id can be set in config/initializers/sso_settings.rb
    return user_data
  end
end
