class Dod < ActiveRecord::Base
  has_many :database_dods, :dependent => :destroy
  has_many :database_resources, :through => :database_dods
  validates_presence_of :title,
                        :message => "may not be blank!"
  validates_presence_of :url,
                        :message => "may not be blank!"
  validates_presence_of :provider,
                        :message => "may not be blank!"
  validates_presence_of :descr,
                        :message => "may not be blank!"
  validates_uniqueness_of :title,
                        :message => "{{value}} is already being used!"
   
def self.sort(sort=nil)
  unless sort==nil
    find(:all, :conditions => ['title LIKE ?', "#{sort}%"])
  else
    find(:all, :order => 'title')
  end  
end

def coverage_label
  return startdate + " - " + enddate
end

end
