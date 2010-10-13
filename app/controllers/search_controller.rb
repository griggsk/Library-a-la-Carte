#Library a la Carte Tool (TM).
#Copyright (C) 2007 Oregon State University
#See license-notice.txt for full license notice

class SearchController < ApplicationController
  include Paginating
  skip_before_filter :authorize, :only =>[:view]
  before_filter :module_types, :except => [:view]
  before_filter :custom_page_data, :only => [:search_pages]
  layout 'tool'
  
  def index
    # sets all of the sorting instance variables as well as gets the users modules which 
    # match the search term into the @search_results instance variable
    set_module_variables(params[:all],params[:mod][:search],params[:sort],params[:list])
    @mcurrent = 'current'
    @types = module_types
    @seccurrent = 'current'
    @mods = @search_results = paginate_mods(@search_results,(params[:page] ||= 1),@sort)
    if request.xhr? 
      render :partial => "search_list", :layout => false
    end
  end
  
  def search_pages
    set_page_variables(params[:all],params[:mod][:search],params[:sort],params[:list])
    @search_results = paginate_pages(@search_results, params[:page] ||= 1,@sort)
    if request.xhr?
      render :partial => "pages_list", :layout => false 
    end
  end
  
  def search_guides
    set_guide_variables(params[:all],params[:mod][:search],params[:sort],params[:list])
    @search_results = paginate_guides(@search_results, params[:page] ||= 1,@sort)
    if request.xhr?
      render :partial => "guides_list", :layout => false 
    end    
  end
  
  def search_tutorials
    set_tutorial_variables(params[:all],params[:mod][:search],params[:sort],params[:list])
    @search_results = paginate_list(@search_results,(params[:page] ||= 1),@sort)
    if request.xhr?
      render :partial => "tutorials_list", :layout => false 
    end    
  end
  
  def add_modules
    #determine if we are adding modules to guide or page tab, or tutorial unit
    if session[:guide_id]
      get_Guide
    elsif session[:page_id]
      get_Page
    elsif session[:tutorial_id]
      get_Tutorial
    end
    
    # sets all of the sorting instance variables as well as gets the users modules which 
    # match the search term into the @search_results instance variable
    set_module_variables(params[:all],params[:mod][:search],params[:sort],params[:list])
    @amcurrent = 'current'
    @mods = @search_results = paginate_mods(@search_results,(params[:page] ||= 1),@sort)
    if request.xhr? #Required for sorting
      render :partial => "search_modules_list", :layout => false
    end
  end
  
private
  def get_Guide
    @guide = Guide.find(:first,:conditions=> "id = #{session[:guide_id]}")
    @tabs = @guide.tabs
    @tab  = @tabs.select{ |t| t.id == params[:tab].to_i}.first
  end

  def get_Page
    @page= Page.find(:first,:conditions=> "id = #{session[:page_id]}")
    @tabs = @page.tabs
    @tab  = @tabs.select{ |t| t.id == params[:tab].to_i}.first
  end
  
  def get_Tutorial
    @tutorial= Tutorial.find(:first,:conditions=> "id = #{session[:tutorial_id]}")
    @units = @tutorial.units
    @unit ||= Unit.find(session[:unit])
  end
  
  def set_module_variables(all,search_term,sort,list)
    @all = all
    @search_term = search_term
    @sort = sort || 'name'
    @list = list || 'mine'
    @mods = @user.modules('label') #get the list of the users modules
    @search_results = @user.sort_search_mods(@sort,@user.search(@search_term, @mods,'shared'))#sorts and returns the users modules which match the search terms
  end

  def set_page_variables(all,search_term,sort,list)
    @search_term = search_term
    @pcurrent = 'current'
    @subj_list = Subject.get_subjects
    @sort = params[:sort] || 'name'
    @pages = @user.sort_pages(@sort)
    @search_results = @user.sort_search_pages(@sort,@user.search(@search_term,@pages,'shared_page'))#sorts and returns the users pages which match the search terms
  end
  
  def set_guide_variables(all,search_term,sort,list)
    @search_term = search_term
    @gcurrent = 'current'
    @sort = params[:sort] || 'name'
    @guides = @user.sort_guides(@sort)
    @search_results = @user.sort_search_guides(@sort,@user.search(@search_term,@guides,'shared_guide'))#sorts and returns the users guides which match the search terms
  end
  
  def set_tutorial_variables(all,search_term,sort,list)
    @search_term = search_term
    @tcurrent = 'current'
    @sort = params[:sort] || 'name'
    @tutorials = @user.sort_tutorials(@sort)
    @search_results = @user.sort_search_tutorials(@sort,@user.search(@search_term,@tutorials,'shared_tutorial'))#sorts and returns the users tutorials which match the search terms
  end
end