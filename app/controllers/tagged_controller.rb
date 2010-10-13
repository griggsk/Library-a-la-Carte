#Library a la Carte Tool (TM).
#Copyright (C) 2007 Oregon State University
#See license-notice.txt for full license notice

class TaggedController < ApplicationController
  include Paginating
  before_filter :module_types
  layout 'tool'
  
 def index
    set_module_variables(params[:all],params[:tag],params[:sort])
    @types = module_types
    @tgcurrent = 'current'
    @tags = @user.module_tags
    @mods = @tag == "" ?  @user.sort_mods(@sort) : @user.find_mods_tagged_with(@tag)
    @mods = paginate_mods(@mods,(params[:page] ||= 1),@sort)
    if request.xhr?
      render :partial => "tag_list", :layout => false
    end
 end
 
  
   def set_module_variables(all,tag,sort)
    @mcurrent = 'current'
    @all = all || 'all'
    @tag = tag || ""
    @sort = sort || 'name'
  end
  end