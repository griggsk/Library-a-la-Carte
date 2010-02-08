class Answer < ActiveRecord::Base
  belongs_to :question
  acts_as_list :scope => :question
  
validates_presence_of :value, :on => :update, :message => "Answer can not be blank", :unless => :skip_it

def skip_it
  return  question.q_type =='TF'
end

end
