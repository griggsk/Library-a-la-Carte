class Master < ActiveRecord::Base
  has_and_belongs_to_many :guides
  validates_presence_of :value,
                        :message => "Master value may not be blank!"
  validates_uniqueness_of :value,
                        :message => "{{value}} is already being used!"
  
 def pub_guides(gid = nil)
   return guides.select{ |a| a.published? and a.id != gid }.sort! {|a,b|  a.guide_name <=> b.guide_name} 
 end
 
 #list the master subjects
  def self.get_guide_types
    find(:all, :order => 'value')
  end
  

 
end
