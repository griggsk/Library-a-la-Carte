#Library a la Carte Tool (TM).
#Copyright (C) 2007 Oregon State University
#See license-notice.txt for full license notice

class Tab < ActiveRecord::Base
belongs_to :tabable, :polymorphic => true
has_many :tab_resources, :order => :position, :dependent => :destroy
has_many :resources, :through => :tab_resources
acts_as_list :scope => 'tabable_id=#{tabable_id} AND tabable_type=\'#{tabable_type}\'' 
after_save :update_ferret
after_destroy :update_ferret

validates_presence_of  :tab_name

#updates the ferret index because it was not happening automatically

def update_ferret
  search = Local.find(:first).enable_search?
  if search
   tabable.ferret_update
  end
end


#add a resource to the HABTM relationship
def add_resource(resource)
    resources << resource
    update_users
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
 if resource
  resources << resource 
  update_users 
 end
end

#returns true if the tab is on a page or guide that is shared
def update_users
 if guide != "" and guide.shared?
   guide.update_users
 elsif page != "" and page.shared?
   page.update_users
 end
end

def guide
return (tabable_type == "Guide" and Guide.exists?(tabable_id))  ? Guide.find(tabable_id) : ""
end

def page
  return (tabable_type == "Page" and Page.exists?(tabable_id))  ? Page.find(tabable_id) : ""
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
   m = resources.collect{ |a| a.mod}.compact
   return m.sort!{|a,b|  a.send(sortable) <=> b.send(sortable)}
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
