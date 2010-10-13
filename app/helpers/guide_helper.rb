#Library a la Carte Tool (TM).
#Copyright (C) 2007 Oregon State University
#See license-notice.txt for full license notice

module GuideHelper
  def guide_search_params(search,guide)
    guide_params = {}
    if search #if request came from a search, add search term to paramaters
      guide_params['publish'] = {:action => 'publish',:controller => 'guide', :id => guide, :page => @page, :sort => @sort, :search => search}
    else
      guide_params['publish'] = {:action => 'publish',:controller => 'guide', :id => guide, :page => @page, :sort => @sort} 
    end
      return guide_params
  end
end
