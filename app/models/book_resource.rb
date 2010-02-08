class BookResource < ActiveRecord::Base
acts_as_taggable
has_many :resources, :as => :mod,  :dependent => :destroy
has_many :books,  :dependent => :destroy
before_create :private_label  
after_update :save_books

validates_presence_of :module_title

def private_label
  self.label = self.module_title
end

 def new_book_attributes=(book_attributes) 
  book_attributes.each do |attributes| 
    books.build(attributes) 
  end 
end 


 def existing_book_attributes=(book_attributes) 
  books.reject(&:new_record?).each do |book| 
    attributes = book_attributes[book.id.to_s] 
    if attributes 
     book.attributes = attributes 
    else 
      books.delete(book) 
    end 
  end 
 end 

 def save_books
  books.each do |book| 
    book.save(false)
  end 
 end 

 def used?
     self.resources.each do |r|
       return false if r.tab_resources.length < 1 and  r.pages.length < 1 and r.guides.length < 1 and r.resourceables.length < 1
     end
  end

 def get_pages
     return  resources.collect{|r| r.tabs.collect{|t| t.page}}.flatten.uniq
 end
 
  def get_guides
    return  resources.collect{|r| r.tabs.collect{|t| t.guide}}.flatten.uniq
 end
 
  def get_tutorials
    return  resources.collect{|r| r.units.collect{|t| t.tutorials}}.flatten.uniq
 end
 
   def rss_content
    return self.information.blank? ? "" : self.information
  end
  
  def add_tags(tags)
    self.tag_list = tags
    self.save
  end
  
def shared?
  self.resources.each do |r|
    return false if r.users.length > 1
  end
end

end
