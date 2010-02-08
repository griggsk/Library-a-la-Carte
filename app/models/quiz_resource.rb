class QuizResource < ActiveRecord::Base
acts_as_taggable
has_many :resources, :as => :mod,  :dependent => :destroy
has_many :questions, :order => :position, :dependent => :destroy
 
before_create :private_label  
validates_presence_of :module_title
after_update :save_questions



def copy_questions
  question_copies[]
     questions.each do |question|
         answer_copies = question.answers.collect{|a| a.clone if a}.flatten
         question_copy = question.clone
         if question_copy.save
           answer_copies.each do |answer|
             question_copy.answers << answer
           end
         question_copies << question_copy
        end
    end
    return question_copies
end

def private_label
  self.label = self.module_title
end


 def save_questions
  questions.each do |question| 
    question.save(false)
  end 
 end 

def used?
     self.resources.each do |r|
       return false if r.tab_resources.length < 1 and  r.pages.length < 1 and r.guides.length < 1 and r.resourceables.length < 1
     end
  end

 def get_pages
   return  resources.collect{|r| r.tabs.collect{|t| t.page}}.flatten.uniq
 end
 
  def get_guides
    return  resources.collect{|r| r.tabs.collect{|t| t.guide}}.flatten.uniq
 end
 
  def get_tutorials
    return  resources.collect{|r| r.units.collect{|t| t.tutorials}}.flatten.uniq
 end
 
   def rss_content
    return self.description.blank? ? "" : self.description
  end
  
  def add_tags(tags)
    self.tag_list = tags
    self.save
  end
  
def shared?
  self.resources.each do |r|
    return false if r.users.length > 1
  end
end
  
  def check_student(student)
   num =  questions.select{|q| q if q.taken(student) == true}
   return true if num and num.length > 0 
   return false
 end
 
 def possible_points
    return questions.inject(0){|sum,item| sum + item.points}
 end
 
end
