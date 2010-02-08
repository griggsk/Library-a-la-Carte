class DatabaseController < ApplicationController
  before_filter :module_types
  before_filter :current_page
  before_filter :current_guide
  before_filter :current_tutorial
  layout 'tool'
 
 def add_databases
   @mod ||= find_mod(params[:id], "DatabaseResource")
   if request.xhr?
     unless session[:selected].include?(params[:cid].to_s)
        session[:selected] << params[:cid]
     end
     render :nothing => true, :layout => false
   elsif request.post? and !session[:selected].blank?
        session[:selected].each do |db|
          dod = Dod.find(db)
          @mod.add_dod(dod)
        end 
        session[:selected] = nil if session[:selected]
        redirect_to  :action => 'edit_databases', :id =>@mod.id
    else
     redirect_to  :action => 'edit_databases', :id =>@mod.id
   end
  end
  
  def edit_databases
     @ecurrent = 'current'
     begin
        @mod ||= find_mod(params[:id], "DatabaseResource")
        session[:selected] ||= Array.new 
     rescue ActiveRecord::RecordNotFound
        logger.error("Attempt to access invalid module #{params[:id]}" )
        flash[:notice] = "You are trying to access a module that doesn't yet exist. "
        redirect_to  :back
     else
       @letter = params[:sort] ? params[:sort] : "A" 
       @dbs = Dod.sort(@letter)
   end
   if request.xhr?
        render :partial => "a_z_list", :layout => false
    end
  end 
  
  #Save a database module. 
 def update_databases
    @mod ||= find_mod(params[:id], "DatabaseResource")
    if request.post?
        @mod.update_attributes( params[:mod]) 
        @mod.database_dods.each { |t| t.attributes = params[:database_dod][t.id.to_s] } 
        @mod.database_dods.each(&:save!)
        if params[:db_remove_list]
          params[:db_remove_list].each do |did|
             dod = @mod.dods.find(did)
             @mod.dods.delete(dod) if dod
          end   
        end
        session[:selected] = nil if session[:selected]
        redirect_to :controller => 'module', :action => "preview" , :id =>@mod.id, :type=> @mod.class
    end
 end
 
 def copy_databases
    begin
     @old_mod = find_mod(params[:id], "DatabaseResource")
    rescue Exception => e
     logger.error("Exception in add_copy: #{e}")
     flash[:notice] = "You are trying to access a module that doesn't yet exist. "
     redirect_to :back
   else
      @mod = @old_mod.clone
      @mod.global = false
      if @mod.save
        @mod.label =  @old_mod.label+'-copy'
        @mod.database_dods << @old_mod.database_dods.collect{|d| d.clone}.flatten
        create_and_add_resource(@user,@mod)
        flash[:notice] = "Saved as #{@mod.label}"
        redirect_to  :controller => 'module', :action => "edit_content" , :id =>@mod.id, :type=> @mod.class
      end  
   end  
 end
 
 end 