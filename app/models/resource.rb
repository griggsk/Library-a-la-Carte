class Resource < ActiveRecord::Base
belongs_to :mod, :polymorphic =>true
has_and_belongs_to_many :users
has_many :tab_resources, :dependent => :destroy
has_many :tabs, :through => :tab_resources

has_many :resourceables, :dependent => :destroy
has_many :units, :through => :resourceables

has_many :guides
has_many :pages



 
 #protect these attributes so they can not be set with a POST request  
  attr_protected :id
  
  
  def copy_mod(name)
    old_mod = self.mod
    new_mod = old_mod.clone
    case old_mod.class.to_s 
        when "DatabaseResource"
           new_mod.database_dods << old_mod.database_dods.collect{|d| d.clone}.flatten
        when "UploaderResource"
            new_mod.uploadables << old_mod.uploadables
        when "RSSResource"
             new_mod.feeds << old_mod.feeds.collect{|f| f.clone}.flatten
     end
     new_mod.save
    new_mod.label =  old_mod.label+'-'+name
    new_mod.global= false
    return new_mod
  end
 
  
def self.global_list(s = nil, r = nil)
   sortable = s || 'label'
   rev = r || 'true'
   global_mods = self.find(:all).collect{|a| a.mod if a.mod and (a.mod.global == true || a.mod.global == 1) }.compact
   unless global_mods.empty?
     unless sortable == "updated_at"
        global_mods = global_mods.sort! {|a,b| b.send(sortable).downcase   <=> a.send(sortable).downcase}
     else
       global_mods = global_mods.sort! {|a,b|  a.send(sortable) <=> b.send(sortable)}
     end
     if  rev == 'false'
        global_mods = global_mods.reverse
     end
   end  
   return global_mods.uniq
end
  
 def delete_mods
   self.mod.destroy
 end

end
