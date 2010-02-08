class Guide < ActiveRecord::Base
acts_as_taggable
has_and_belongs_to_many :users
has_many :tabs,  :order => 'position', :dependent => :destroy
has_and_belongs_to_many :masters
has_and_belongs_to_many :subjects, :order => 'subject_name'
belongs_to :resource

validates_presence_of  :guide_name
validates_uniqueness_of :guide_name

 def to_param
    "#{id}-#{guide_name.gsub(/[^a-z0-9]+/i, '-')}"
  end
  

def add_master_type(master_types)
  masters.clear
  if master_types
    master_types.each do |id|
      master = Master.find(id)
      masters << master
    end
  end
end

def add_related_subjects(subjs)
  subjects.clear
  if subjs
    subjs.each do |id|
      subject = Subject.find(id)
      subjects << subject
    end
  end
end

def add_contact_module(mod)
  self.resource_id = nil
  if mod
   self.resource_id = mod
  end
end

def add_tags(tags)
  self.tag_list = tags
  self.save
end

def create_home_tab
    tab = Tab.new(:tab_name => 'Quick Links')
    self.tabs << tab
end

def add_tab(tab)
  tab.update_attribute(:position, tabs.length + 1)
   tabs << tab
end


def reached_limit?
  tabs.length > 5 ? true : false
end

def modules
 tbs = []
 tbs << tabs.collect{|t| t.modules}
 return tbs.flatten
end

def recent_modules 
   return tabs.collect{|t| t.recent_modules}.flatten
end

def related_pages
  subjects.collect{|s| s.get_pages}.flatten.uniq
end  


def related_guides(id)
   masters.collect{|m| m.pub_guides(id)}.flatten.uniq 
end

def self.published_guides
  return self.find(:all,:conditions =>{:published => true}, :select =>'id, guide_name, description' )
end

def copy_resources(uid, tbs)
     user = User.find(uid)
     tbs.each do |tab|
         mod_copies = tab.resources.collect{|r| r.copy_mod(tab.guide.guide_name)}.flatten
         tab_copy = tab.clone
         if tab_copy.save
           mod_copies.each do |mod|
              mod.update_attribute(:created_by, user.name)
              resource = Resource.create(:mod => mod)
              user.add_resource(resource)
              tab_copy.add_resource(resource)
          end
          add_tab(tab_copy)
        end
    end
end


def copy_tabs(tbs)
  tbs.each do |tab|
         tab_copy = tab.clone
         if tab_copy.save
           tab.resources.each do |res|
              tab_copy.add_resource(res)
          end
           add_tab(tab_copy)
      end
    end  
end

end
