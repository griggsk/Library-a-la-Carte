class Resourceable < ActiveRecord::Base
 belongs_to :resource
 belongs_to :unit
 acts_as_list :scope => :unit
end
