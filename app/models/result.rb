class Result < ActiveRecord::Base
belongs_to :student
belongs_to :question

attr_protected :id
end