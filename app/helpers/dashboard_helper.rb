#Library a la Carte Tool (TM).
#Copyright (C) 2007 Oregon State University
#See license-notice.txt for full license notice

module DashboardHelper
 
  def activity_link(object)
    case object.class.name
      when 'Page'
        link_to truncate(h(object.header_title),:length => 20), {:controller => 'page', :action => 'edit',  :id => object.id}, :title => "edit page"
      when 'Guide'
        link_to truncate(h(object.guide_name),:length => 20), {:controller => 'guide', :action => 'edit',  :id => object.id}, :title => "edit guide"
     when 'Tutorial'
        link_to truncate(h(object.full_name),:length => 20), {:controller => 'tutorial', :action => 'update',  :id => object.id}, :title => "edit tutorial"   
      else
        link_to truncate(h(object.label),:length => 20), {:controller => 'module', :action => 'edit_content',  :id => object.id, :type => object.class}, :title => "edit module"
    end  
  end
  
  
end
