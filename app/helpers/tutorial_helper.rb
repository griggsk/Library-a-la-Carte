#Library a la Carte Tool (TM).
#Copyright (C) 2007 Oregon State University
#See license-notice.txt for full license notice

module TutorialHelper
  def tutorial_search_params(search,tutorial)
    tutorial_params = {}
    if search #if request came from a search, add search term to paramaters
      tutorial_params['publish'] = {:action => 'publish',:controller => 'tutorial', :id => tutorial, :page => @page, :sort => @sort, :search => search}
      tutorial_params['archive'] = {:action => 'archive', :controller => 'tutorial', :id => tutorial, :page => @page, :sort => @sort, :search => search}
      tutorial_params['destroy'] = {:action => 'destroy', :controller => 'tutorial',:id => tutorial, :page => @page, :sort => @sort, :search => search}
    else
      tutorial_params['publish'] = {:action => 'publish',:controller => 'tutorial', :id => tutorial, :page => @page, :sort => @sort} 
      tutorial_params['archive'] = {:action => 'archive', :controller => 'tutorial', :id => tutorial, :page => @page, :sort => @sort}  
      tutorial_params['destroy'] = {:action => 'destroy', :controller => 'tutorial',:id => tutorial, :page => @page, :sort => @sort}
    end
      return tutorial_params
  end
end
