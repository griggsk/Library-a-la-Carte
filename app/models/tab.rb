class Tab < ActiveRecord::Base
belongs_to :guide
belongs_to :page
has_many :tab_resources, :order => :position, :dependent => :destroy
has_many :resources, :through => :tab_resources
acts_as_list :scope => :guide
acts_as_list :scope => :page

validates_presence_of  :tab_name

#add a resource to the HABTM relationship
def add_resource(resource)
    resources << resource
end

#update a users resource list
def update_resource(resrs)
    resrs.each do |value|
               id = value.gsub(/[^0-9]/, '')
               type = value.gsub(/[^A-Za-z]/, '')
               resource = Resource.find_by_mod_id_and_mod_type(id,type)
               resources << resource
           end
end


def add_module(id, type)
  resource = Resource.find_by_mod_id_and_mod_type(id,type)
  resources << resource if resource
end

def find_resource(id, type)
   return resources.find_by_mod_id_and_mod_type(id, type)
end

#get the collection of associated resources
def modules
   resources.collect {|a| a.mod if a}.compact
end 

def recent_modules 
   sortable = "updated_at"
   return resources.collect{ |a| a.mod}.sort! {|a,b|  a.send(sortable) <=> b.send(sortable)}
end

def sorted_modules
  return tab_resources.collect{|t| t.resource.mod if t and t.resource}.compact
end

def left_resources
      odd = []
      odd << tab_resources.select{|t|t.position.odd? and t.resource and t.resource.mod}
     return odd.flatten.compact
end

def right_resources
   even = []
   even << tab_resources.select{|t|t.position.even? and t.resource and t.resource.mod}
   return even.flatten.compact
end

def left_modules
      odd = []
      tr = tab_resources.select{|t|t.position.odd?}
      odd << tr.collect{|t| t.resource.mod if t.resource}
     return odd.flatten.compact
end

def right_modules
  even = []
      tr = tab_resources.select{|t|t.position.even?}
      even << tr.collect{|t| t.resource.mod if t.resource}
  return even.flatten.compact
end


end
