#Library a la Carte Tool (TM).
#Copyright (C) 2007 Oregon State University
#See license-notice.txt for full license notice

class MobileController < ApplicationController
  has_mobile_fu #to force mobile mode, pass in true to this function
  include Paginating
  skip_before_filter :authorize
  before_filter :local_customization
 
  def index
    if params[:mod] #only run the search if a search term has been received
      @search_term = params[:mod][:search]
      @search_results = ActsAsFerret.find("#{@search_term}, published:1",'shared',:per_page => 100)#returns the published modules which match the search term
      @search_results = paginate_mobile_search(@search_results,(params[:page] ||= 1),@sort)
  end
 end
 
 def show
    @class ='thumbnail'
    @style ='width:255px; height:220px;'
    begin
      @mod = find_mod(params[:id],params[:type] )
    rescue Exception => e
      redirect_to :back and return
    end
     @preview = true if @mod.class == QuizResource
    respond_to do |format|
      @search_term = params[:search]            #save the search term to allow the user to return to their search index
      format.html {render :layout => 'popup'}   #/layouts/popup.html.erb
      format.mobile {render :layout => 'mobile'} #/layouts/popup.mobile.erb
    end
 end
 
 #returns xml page of results from the module search
 def search
    @search_results =  ActsAsFerret.find("#{params[:id]}, published:1",'shared',:per_page => 100)#returns the published modules which match the search term
      
    respond_to do|format|
      format.xml {render :layout => false}
     end
 end
 
end
