class TabResource < ActiveRecord::Base
 belongs_to :tab
 belongs_to :resource
 acts_as_list :scope => :tab
end
