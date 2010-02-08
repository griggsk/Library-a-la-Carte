require "fastercsv"

class Student < ActiveRecord::Base
 has_many :results, :order => 'question_id', :dependent => :destroy
 has_many :questions, :through => :results
 belongs_to :tutorial
 
  validates_presence_of  :email, :onid, :name, :sect_num, :tutorial_id
  validates_uniqueness_of  :email, :onid, :scope => [:tutorial_id]
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "Invalid email" 
  
 #generates export grades
  def to_csv
     score = final_score
     FasterCSV.generate_line([
            onid,
            name,
           score]).chomp
   end

  
  #return a user for a tutorial if their email and onid matches the one stored for that user in the database or create a new one with the information if they have never logged in
  def self.authenticate(name, email, onid, id, section)
    student = self.find_by_tutorial_id_and_email(id, email)
    if !student.blank?
      if student.onid != onid || student.sect_num != section
        return nil
      end
    else
      student = self.new(:name => name, :email => email, :onid => onid, :tutorial_id => id, :sect_num => section )
       return student.save ?  student : false
   end
   return student
  end
  
  def send_forgot(url)
    Notifications.deliver_forgot(self.email, self.onid, self.sect_num, url)
  end
    
  
  #returns a students total score on a quiz
  def get_total_score(quiz)
    scores=[]
    quiz = QuizResource.find(quiz)
    quiz_results = results.select{|r| r if quiz.questions.include?(r.question) == true}
    return quiz_results.inject(0){|sum,item| sum + item.score}
  end
  
   #returns a students total score on a tutorial
  def final_score
    scores=[]
    qz = tutorial.quizzes
    qz.each do |q|
      scores << get_total_score(q.id)
    end
     return scores.inject(0){|sum,item| sum + item}
  end
  
  
  #returns a 2X2 array of the quizes the student has taken and a list of the quizes left
  def quizes(t)
    tutorial_quizes = tutorial.quizzes.select{|q| q.graded == 1}.compact
    all_questions = tutorial_quizes.collect{|q| q.questions if q}.flatten.compact
    student_questions = questions.select{|q| q if all_questions.include?(q)}.flatten.compact
    s_quizes = student_questions.collect{|q| q.quiz_resource if q}.flatten.compact
    quizes_left =  tutorial_quizes - s_quizes
    return  s_quizes.uniq, quizes_left.uniq
  end
  
  #returns a 3X3 array of question id ,the guess and the score of the quiz
  def get_results(quiz)
     values=[]
     quiz = QuizResource.find(quiz)
     quiz_results = results.select{|r| r if quiz.questions.include?(r.question)}
     quiz_results.each do |result|
       values << [result.question_id, result.guess, result.score]
     end
    return values.uniq
  end
 
 
 def taken_on
   return results.last.updated_at
 end
 
 end
