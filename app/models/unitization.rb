class Unitization < ActiveRecord::Base
 belongs_to :unit
 belongs_to :tutorial
 acts_as_list :scope => :tutorial
 
 
   
end
