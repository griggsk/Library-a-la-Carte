#Library a la Carte Tool (TM).
#Copyright (C) 2007 Oregon State University
#See license-notice.txt for full license notice

class BookController < ApplicationController
  include CatalogScraper
  before_filter :module_types
  before_filter :current_page
  before_filter :current_guide
  before_filter :current_tutorial, :except=>[:copy_book]
  layout 'tool'

 
 def retrieve_results
    @mod = find_mod(params[:id], "BookResource")
if request.xhr?
      #The scraper just wants the URI, not the entire html link tag.
      /href="(.*)"/.match(params[:title])
      link = $1 if $1
      if link
        results = search_catalog(nil, link)
        #we have to put the reserves somewhere "safe" across the AJAX request
        #so we tuck it into the session, and then erase it when we are done
        #saving our changes to the module
        @result = session[:results] = results
        @title = params[:title].scan(/\>(.*?)\</) 
     end
       render :partial => "book/catalog_title", :locals => {:results => results, :mod =>@mod} and return
    end
    redirect_to :back
  end
 
 
 
 def edit_book
     @ecurrent = 'current'
     begin
        @mod = find_mod(params[:id], "BookResource")
     rescue ActiveRecord::RecordNotFound
        redirect_to :controller => 'module', :action => 'index', :list=> 'mine'
     else 
      session[:mod_id] = @mod.id
      session[:mod_type] = @mod.class
     end
end
 
def search_book
      @mod = find_mod(params[:id], "BookResource")
      @query = params[:query]
      @results = search_catalog(@query)
      session[:results] =  @results
      render :partial => "book/catalog_title", :locals => {:results => @results, :mod =>@mod} and return  
end

def save_book
    @mod = find_mod(params[:id], "BookResource")
    image =  params[:isbn] ? params[:isbn].scan(/^(.*?)\s/) : ""
    new = Book.new(:url => 'http://',:image_id => image.to_s,  :catalog_results => params[:results])
    @mod.books << new
   render :partial => "book/book", :collection => @mod.books, :locals => {:mod =>@mod} and return
end

def update_book
  params[:mod][:existing_book_attributes] ||= {} 
  params[:mod][:new_book_attributes] ||= {} 
  @mod = find_mod(params[:id], "BookResource")
  @mod.update_attributes(params[:mod]) 
    if @mod.save 
       redirect_to :controller => 'module', :action => "preview" , :id =>@mod.id, :type=> @mod.class
    else 
      render :action => 'edit_book' , :mod => @mod
    end
end

def copy_book
    begin
     @old_mod = find_mod(params[:id], "BookResource")
    rescue Exception 
     redirect_to :controller => 'module', :action => 'index', :list=> 'mine'
   else
      @mod = @old_mod.clone
      @mod.global = false
     if @mod.save
       @mod.label =  @old_mod.label+'-copy'
        @mod.books << @old_mod.books.collect{|v| v.clone if v}
        create_and_add_resource(@user,@mod)
          flash[:notice] = "Saved as #{@mod.label}"
        redirect_to  :controller => 'module', :action => "edit_content" , :id =>@mod.id, :type=> @mod.class
     end
   end  
 end
  #Sort modules function for drag and drop  
def sort
  if params['books'] then 
     sortables = params['books'] 
     sortables.each do |id|
      book = Book.find(id)
      book.update_attribute(:position, sortables.index(id) + 1 )
     end
   end
   render :nothing => true 
end

end
