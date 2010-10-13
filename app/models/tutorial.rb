#Library a la Carte Tool (TM).
#Copyright (C) 2007 Oregon State University
#See license-notice.txt for full license notice

class Tutorial < ActiveRecord::Base
  acts_as_taggable
  has_many :units, :through => :unitizations
  has_many :unitizations, :order => :position, :dependent => :destroy
  has_many :users, :through => :authorships
  has_many :authorships,  :dependent => :destroy
  has_many :students, :order => :lastname, :dependent => :destroy
  belongs_to :subject
  serialize :section_num
  after_create :password_protect
  
  validates_presence_of  :name
  validates_uniqueness_of :name,
                          :scope => [:course_num, :section_num, :subject_id],
                          :message => "is already in use. Change the Tutorial title to make it unique."

  validates_format_of :section_num,
                      :with =>  /^(\d{1,}\,?\d{1,})*$/,
                      :message => "must be a comma seperated list of numbers or blank"
  validates_format_of :course_num,
                      :with => /^(\d{1,}\/?\d{1,})*$/,
                      :message => "must be a number or number/number."
                      
    
   attr_protected :id
  
   def to_param
      "#{id}-#{full_name.gsub(/[^a-z0-9]+/i, '-')}"
   end
   
   def self.authenticate(u,p)
      find_by_id_and_pass( [ "id = '%d'", u ], ["pass = '%s'", p] )
   end

  def add_tags(tags)
    self.tag_list = tags
    self.save
  end
  
  def full_name
    return course + " " + name 
  end
  
  def course
    return subject ? subject.subject_code + " "+ course_num : ""
  end
  
   def sections
    nums=[]
    nums << section_num.split(',') if !section_num.blank?
    return nums.flatten
  end
  
  def self.get_published_tutorials
    return self.find(:all,:conditions => {:published => true}, :order => 'name')
  end
  
   def self.published_tutorials
    return self.find(:all,:conditions =>{:published => true}, :order => 'name', :select =>'id, name, description' )
  end
  
   def self.get_archived_tutorials
    return self.find(:all,:conditions => {:archived => true}, :order => 'name', :select =>'id, name, description')
  end
  
  def self.get_subjects(tuts)
  return tuts.collect {|t| t.subject}.flatten.uniq
end
  
  def share(role, user, copy)
     if copy  == "1"
       tutorial_copy = clone
       tutorial_copy.name = name + '-copy'
       tutorial_copy.created_by = user.id
       tutorial_copy.published = false
       tutorial_copy.save
       copy(tutorial_copy,user)
     else
       users << user
       mods = units.collect{|u| u.resources}
       mods.each do |resource|
         user.add_resource(resource)
       end
   end
 end
 
 def copy(tut_copy, user)
  tut_copy.users << user
  units.each do |unit|
    mod_copies = unit.resources.collect{|r| r.copy_mod(unit.title)}.flatten
    unit_copy = unit.clone
    tut_copy.units << unit_copy
    if unit_copy.save
           mod_copies.each do |mod|
              mod.update_attribute(:created_by, user.name)
              resource = Resource.create(:mod => mod)
              user.add_resource(resource)
              unit_copy.add_resource(resource)
          end
     end 
  end
end

def remove_from_shared(user)
  update_attribute(:created_by, users.at(1).id) if created_by.to_s == user.id.to_s
   users.delete(user)
   mods = units.collect{|u| u.resources}
       mods.each do |r|
          user.resources.delete(r)
       end
end
  
  def shared?
   return users.length > 1
  end
 
  def any_editors?
    return users.collect{|u| u.rights = 1}.length > 1
  end
  
  def creator
    return User.exists?(created_by) ? User.find(created_by).name : ""
  end
 
 
 def publish
   return published == 1 ? true : false
 end
 
 #update resources with shared users
def update_users
  resources =  units.collect{|t| t.resources}.compact
   resources.each do |resource|
     users.collect{|user| user.add_resource(resource) unless (user.id == @user || user.resources.include?(resource) == true)}
   end
end

  def add_units(uids)
    uids.each do |uid|
      u = Unit.find(uid)
      units << u
    end
  end
  
  def next_unit(current_id)
    uts= unitizations.select{|uz| uz.unit.id == current_id}.first
    next_uz = uts.lower_item
    if !next_uz.blank?
     return next_uz.unit
    else
      return false
    end
  end
  
   def prev_unit(current_id)
    uts= unitizations.select{|uz| uz.unit.id == current_id}.first
    prev_uz = uts.higher_item
    if !prev_uz.blank?
     return prev_uz.unit
    else
      return false
    end
  end
  
  def quizzes
    resources = units.collect{|u| u.resources}.flatten
    mods = resources.collect{|a| a.mod if a.mod.class== QuizResource}.flatten.compact
    return mods.uniq
  end
  
  def get_students(section=nil)
  return section ? students.select{|s| s.sect_num == section} : students
 end
 
 def clear_grades(section=nil)
   studs = section ? students.select{|s| s.sect_num == section} : students
   studs.each do |student|
     student.destroy
   end
   return studs.length > 0 ? "Tutorial grades were successfully cleared." : "There were no grades to clear."
 end
 
 def possible_score
   scores=[]
   quizzes.each do |q|
      scores << q.possible_points
    end
     return scores.inject(0){|sum,item| sum + item}
 end
 
 def password_protect
   words = ["p@ssword","passw0rd", "p@ssw0rd", "pa33word"]
   self.pass = words.rand
   self.save
 end

#Used to create the search index
def index_unit_title
  units.map{|unit| unit.title}.join(", ")
end
def index_unit_slug
  units.map{|unit| unit.slug}.join(", ")
end
end
