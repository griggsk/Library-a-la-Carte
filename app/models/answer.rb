#Library a la Carte Tool (TM).
#Copyright (C) 2007 Oregon State University
#See license-notice.txt for full license notice

class Answer < ActiveRecord::Base
  belongs_to :question
  acts_as_list :scope => :question
  
validates_presence_of :value, :on => :update, :message => "Answer can not be blank", :unless => :skip_it
validates_presence_of :feedback, :on => :update, :message => "Feedback can not be blank", :if => :feedback_type

def skip_it
  if question.q_type =='TF' 
    return true
  elsif question.q_type =='FW'
    return true
  end  
end

def feedback_type
  return true if question.q_type =='FMC' 
end
end
