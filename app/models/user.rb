require 'digest/sha1'

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
   return resources.collect {|a| a.mod.class.tag_counts if a.mod }.flatten.uniq
end

def find_mods_tagged_with(tag)
  tagged =[]
  klasses = resources.collect {|a|a.mod.class}.flatten.uniq
  klasses.each do |klass|
    tagged << klass.find_tagged_with(tag)
  end
  return tagged.flatten
end

def find_resource(id, type)
   return resources.find_by_mod_id_and_mod_type(id, type)
end

def add_profile(rid)
  update_attribute('resource_id', rid)
end

def contact_resources
 contacts =[]
 res = resources.collect { |a| a if a.mod and a.mod.content_type == "Librarian Profile" || a.mod.content_type == "Custom Content" || a.mod.content_type == "Course Widget"  }.compact
 contacts = res.sort! {|a,b|  a.mod.send('label').downcase <=> b.mod.send('label').downcase} unless res.empty?
 return contacts
end


  #returns a list of modules for my modules and global modules view
  def sort_mods(sort_by, list_by = nil)
      case sort_by
               when "name"  then  (sort = "label")  and (reverse = "false")
               when "date"   then (sort =  "updated_at")  and (reverse = "true")
               when "type" then (sort =  "content_type")  and (reverse = "false")
               when "author"  then (sort =  "created_by")  and (reverse = "false")
               when "name_reverse"  then (sort =  "label") and (reverse = "true")
               when "date_reverse"   then (sort =  "updated_at") and (reverse = "false")
               when "type_reverse" then (sort =  "content_type") and (reverse = "true")
               when "author_reverse"  then (sort =  "created_by") and (reverse = "true")
               else (sort = "label")  and (reverse = "false")
       end
       
       case list_by
           when "global" then (mods =  Resource.global_list(sort, reverse))
           else  (mods = modules(sort, reverse))
       end
       return mods
  end
  
  #get the users modules through resources
def modules(s = nil, rev = nil)
    s = s || 'label'
    rev = rev || 'false'
    mods = resources.collect {|a| a.mod if a and a.mod}.compact
    unless s == "updated_at" #not a date so we need to downcase to normalize data
      mods = mods.sort!{|a,b| a.send(s).downcase <=> b.send(s).downcase } 
    else #sort by date DESC
      mods = mods.sort!{|a,b| b.send(s) <=> a.send(s)} 
    end  
    mods = mods.reverse if rev == 'true'
    return mods.uniq
end 

  def sort_guides(sort_by)
      sort = case sort_by
               when "name"  then "guide_name"
               when "date"   then "updated_at DESC"
               when "publish" then "published, guide_name"
               when "archive"  then "archived, guide_name"
               when "name_reverse"  then "guide_name DESC"
               when "date_reverse"   then "updated_at, guide_name"
               when "publish_reverse" then "published DESC, guide_name"
               when "archive_reverse"  then "archived DESC, guide_name"
               else "guide_name"
           end
       return  guides.find(:all, :order => sort.downcase)   
   end
   
     def sort_tutorials(sort_by)
      sort = case sort_by
               when "name"  then "name"
               when "date"   then "updated_at DESC"
               when "publish" then "published, name"
               when "archive"  then "archived, name"
               when "name_reverse"  then "name DESC"
               when "date_reverse"   then "updated_at, name"
               when "publish_reverse" then "published DESC, name"
               when "archive_reverse"  then "archived DESC, name"
               else "name"
           end
       return  my_tutorials.find(:all, :order => sort.downcase)   
   end
   
  def sort_pages(sort_by)
         sort = case sort_by
                   when "name"  then "subjects.subject_code"
                   when "date"   then "updated_at DESC, subjects.subject_code"
                   when "publish" then "published, subjects.subject_code"
                   when "archive"  then "archived, subjects.subject_code"
                   when "name_reverse"  then "subjects.subject_code DESC"
                   when "date_reverse"   then "updated_at, subjects.subject_code"
                   when "publish_reverse" then "published DESC, subjects.subject_code"
                   when "archive_reverse"  then "archived DESC, subjects.subject_code"
                   else  "subjects.subject_code"
               end 
          return  pages.find(:all, :include => ['subjects'], :order => sort.downcase)
    end
    
    #need to fix to work for revers - maybe pull out of user table since no association.
    def sort_units(sort_by)
      sort = case sort_by
               when "name"  then "title"
               when "date"   then "updated_at"
               when "name_reverse"  then "title"
               when "date_reverse"   then "updated_at"
               else "title"
           end
          units = my_tutorials.collect{|t| t.units if t}.flatten.uniq
          if sort == "updated_at" #not a date so we need to downcase to normalize data
              units = units.sort!{|a,b| b.send(sort) <=> a.send(sort)} 
          else #sort by date DESC
             units = units.sort!{|a,b| a.send(sort).downcase <=> b.send(sort).downcase } 
          end  
           if sort_by == 'name_reverse' || sort_by =='date_reverse'
            units = units.reverse 
          end
          return  units
    end
    
    
    def sort_chapters(sort_by)
      sort = case sort_by
               when "name"  then "title"
               when "date"   then "updated_at"
               when "name_reverse"  then "title"
               when "date_reverse"   then "updated_at"
               else "title"
           end
           chapters = my_tutorials.collect{|t| t.units.collect{|u| u.chapters if u}}.flatten.uniq
          if sort == "updated_at" #not a date so we need to downcase to normalize data
               chapters =  chapters.sort!{|a,b| b.send(sort) <=> a.send(sort)} 
          else #sort by date DESC
              chapters =  chapters.sort!{|a,b| a.send(sort).downcase <=> b.send(sort).downcase } 
          end  
           if sort_by == 'name_reverse' || sort_by =='date_reverse'
            chapters =  chapters.reverse 
          end
          return   chapters

    end
    
    def sort_lessons(sort_by)
      sort = case sort_by
               when "name"  then "title"
               when "date"   then "updated_at"
               when "name_reverse"  then "title"
               when "date_reverse"   then "updated_at"
               else "title"
           end
          lessons = my_tutorials.collect{|t| t.units.collect{|u| u.chapters.collect{|c| c.lessons if c}}}.flatten.uniq
          if sort == "updated_at" #not a date so we need to downcase to normalize data
               lessons =  lessons.sort!{|a,b| b.send(sort) <=> a.send(sort)} 
          else #sort by date DESC
              lessons =  lessons.sort!{|a,b| a.send(sort).downcase <=> b.send(sort).downcase } 
          end  
          if sort_by == 'name_reverse' || sort_by =='date_reverse'
            lessons =  lessons.reverse 
          end
          return   lessons
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
  
 
end
