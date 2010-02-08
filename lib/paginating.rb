
module Paginating 
   #return a list of modules for add modules in pages and guides
  
  def paginate_mods(mods,pagin,sort)
    #read and set the variables 
         page = (pagin).to_i
         items_per_page = 25
     #create a Paginator
         mods = mods.paginate :per_page => items_per_page, :page => page , :order => sort
      return  mods
  end
  
  def paginate_guides(guides, pagin, sort)
     #read and set the variables 
         page = (pagin).to_i
         items_per_page = 25
     #create a Paginator
         guides = guides.paginate :per_page => items_per_page, :page => page, :order => sort        
      return  guides
  end 
    
    def paginate_pages(pages, pagin, sort)
          page = (pagin).to_i
          items_per_page = 25
          #create a Paginator
             pages = pages.paginate :per_page => items_per_page, :page => page , :order => sort         
         return pages
    end
    
     def paginate_list(objects, pagin, sort)
          page = (pagin).to_i
          items_per_page = 25
          #create a Paginator
             objects = objects.paginate :per_page => items_per_page, :page => page , :order => sort         
         return objects
    end
end