class Question < ActiveRecord::Base
belongs_to :quiz_resource
has_many :answers, :order => :position
has_many :results,  :dependent => :destroy
has_many :students, :through => :results, :order => :sect_num

after_update :save_answers
acts_as_list :scope => :quiz_resource

validates_presence_of :question, :on => :update

 def quiz_type
   case q_type
     when 'MC' then return "Multiple Choice"
     when 'TF' then return "True/False" 
     when 'FW' then return "Free Write"
  else return ""
  end
end

def correct_answer
  case q_type
     when 'MC' then return answers.select{|a| a.correct == 1}.first.value
     when 'TF' then return answers.first.correct == 1 ? 'true' : 'false'
     when 'FW' then return answers.blank? ? "" : answers.first.value
  else return ""
  end
end

def grade_answer(answer, student = nil)
  case q_type
     when 'MC' then return grade_MC(answer,student)
     when 'TF' then return grade_TF(answer,student)
     when 'FW' then return grade_FW(answer,student)
  else return ""
  end
end

def grade_MC(answer, student)
  correct = correct_answer.eql?(answer)
  score = correct == true ? points : 0
  unless  student == nil  || students.include?(student) == true
    student =  Student.find(student)
    result = Result.new(:guess => answer, :score => score, :question_id => id )
    student.results << result
  end  
   return id, answer, score
end

def grade_TF(answer, student)
  answer_string = answer == "1" ? 'true' : 'false'
  correct = correct_answer.eql?(answer_string)
  score = correct == true ? points : 0
  unless  student == nil  || students.include?(student) == true
    student = Student.find(student)
    result = Result.new(:guess => answer_string, :score => score, :question_id => id )
    student.results << result
  end  
  return id, answer_string,score
end

def grade_FW(answer, student)
  unless  student == nil  || students.include?(student) == true
      student = Student.find(student)
      result = Result.new(:guess => answer, :score => 0 , :question_id => id)
      student.results << result
  end    
  return id, answer, points
end



 def save_answers
  answers.each do |answer| 
    answer.save(false)
  end 
end

 

def taken(student)
  return false if student == 1
  return students.include?(student)
end

end
