class Local < ActiveRecord::Base
  serialize :types
  serialize :guides
  before_create :initialize_types
  
  
  def mod_types
    list =[]
    MODULES.each do |m|
      list << m if types_list.include?(m[1])
    end  
    return list
  end
  
  def guides_list
    return guides.flatten
  end
  
  def types_list
    return types.flatten
  end
  
  def initialize_types
   
      self.types = []
      self.guides = []
     
     self.types << 
     ['comment_resource', 'miscellaneous_resource',  'database_resource', 
     'image_resource', 'inst_resource' ,   'lib_resource' ,   'quiz_resource',
     'rss_resource' ,   'url_resource',  'video_resource'
      ]
      
      self.guides << ['pages','guides','tutorials']
  end
  
end
