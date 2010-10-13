#Library a la Carte Tool (TM).
#Copyright (C) 2007 Oregon State University
#See license-notice.txt for full license notice

class Result < ActiveRecord::Base
belongs_to :student
belongs_to :question
attr_protected :id

def self.saved_answer(id, sid)
 return find(:first, :conditions => ["question_id = ? AND student_id = ?", id, sid])
end

def self.clear_answer(id, sid)
  result = find(:first, :conditions => ["question_id = ? AND student_id = ?", id, sid])
  destroy(result) if result
end

def self.clear_all_saved_answers(sid)
  results = find(:all, :conditions => ["student_id = ?", sid])
  results.each do |result| destroy(result) end if results
end

def self.get_answer(id,sid)
  result =  find(:first, :conditions => ["question_id = ? AND student_id = ?", id, sid])
  result ? result.guess : nil
end
end