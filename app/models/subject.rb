class Subject < ActiveRecord::Base
  has_and_belongs_to_many :guides, :order => 'guide_name'
  has_and_belongs_to_many :pages, :order => 'course_num, course_name'
  has_many :tutorials, :order => 'name'
  
  validates_presence_of :subject_code,
                        :message => "may not be blank!"
  validates_presence_of :subject_name,
                        :message => "may not be blank!"
  validates_uniqueness_of :subject_code,
                        :message => "{{value}} is already being used!"
  validates_uniqueness_of :subject_name,
                        :message => "{{value}} is already being used!"

def get_pages
   return pages.select{ |a| a.published? }.sort! {|a,b|  a.route_title <=> b.route_title} 
end

def get_tutorials
   return tutorials.select{ |a| a.published? }.sort! {|a,b|  a.full_name <=> b.full_name} 
end

#subject and master subject lists

  #list the subject codes
  def self.get_subjects
    find(:all, :order => 'subject_code')
  end

 #list the subject names
  def self.get_subject_values
    find(:all, :order => 'subject_name')
  end
  
  
  

end
