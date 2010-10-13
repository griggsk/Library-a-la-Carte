ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  
   map.connect '' ,:controller => 'login', :action => 'login'
	
  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'
  
  #ICA Pages list
    map.connect 'course-guides/', 
    :controller => "ica",
    :action => "published_pages"
    
    map.connect 'course-guides/archived/', 
    :controller => "ica",
    :action => "archived"
    
     map.connect 'course-guides/tagged/:id', 
    :controller => "ica",
    :action => "tagged"
   
   map.connect 'course-guide/:id',
    :controller => "ica",
    :action => "index"
    
    map.connect 'subject-guides/', 
    :controller => "srg",
    :action => "published_guides"
    
    map.connect 'subject-guides/tagged/:id', 
    :controller => "srg",
    :action => "tagged"
    
   map.connect 'subject-guide/:id',
    :controller => "srg",
    :action => "index" 
    
    map.connect 'guides/search/',
    :controller => "srg",
    :action => "search" 
    
    map.connect 'tutorials',
    :controller => "ort",
    :action => "published_tutorials"
    
    map.connect 'tutorials/archived/',
    :controller => "ort",
    :action => "archived_tutorials"
      
    map.connect 'tutorials/:id',
    :controller => "ort",
    :action => "index"  
    
    map.connect 'tutorials/unit/:id',
    :controller => "ort",
    :action => "unit"  
   
   map.connect 'tutorials/lesson/:id',
    :controller => "ort",
    :action => "lesson" 
    
    map.connect 'tutorials/tagged/:id',
    :controller => "ort",
    :action => "tagged"
    
     map.connect 'tutorials/subject/:id',
    :controller => "ort",
    :action => "subject_list"
    
    map.connect 'tutorials/my-quizzes/:id',
    :controller => "student",
    :action => "quizzes"  
    
    map.connect 'tutorials/login/:id',
    :controller => "student",
    :action => "login"
    
    map.connect 'tutorials/create-account/:id',
    :controller => "student",
    :action => "create_account"
    
    map.connect '/javascripts/tiny_mce/plugins/advimage_uploader/image.htm',
    :controller => "image_manager",
    :action => "create" , 
    :conditions => { :method => :post }
  
    map.connect '/javascripts/tiny_mce/plugins/advimage_uploader/image.htm',
    :controller => "image_manager",
    :action => "show" , 
    :conditions => { :method => :get }

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
  
end
