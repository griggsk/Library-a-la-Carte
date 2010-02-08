class UnitController < ApplicationController
  include Paginating
  before_filter :current_tutorial
  before_filter :current_unit , :only => [:new_module]
  before_filter :module_types, :only =>[:add_modules]
  before_filter :clear_unit, :only => 'units'
  layout 'tool'
  
  def units
    @uscurrent = 'current'
    @units = @tutorial.unitizations
    session[:unit] = nil
  end
  
  def create
    if request.post?
        @unit = Unit.new
        @unit.attributes = params[:unit]
        @unit.created_by = @user.id
        if @unit.save 
           @tutorial.units << @unit
           session[:unit] = @unit.id
           redirect_to  :action => 'update', :id => @unit
         else
          flash[:error] = "Could not create the unit. There were problems with the following fields:
                           #{@unit.errors.full_messages.join(", ")}" 
          flash[:unit_name] = params[:unit][:unit_name]  
          flash[:unit_name_error] = ""
          redirect_to :action => 'add' and return
       end
     end  
  end

  def add
     @sort = params[:sort] || 'name'
     session[:added] ||= []
     @units = @user.sort_units(@sort) 
     @units = paginate_list(@units, params[:page] ||= 1, @sort) 
      if request.xhr? 
          render :partial => "unit/unit_list", :layout => false
       elsif request.post? and !session[:added].nil?
         @tutorial.add_units(session[:added]) 
         session[:added] = nil
         redirect_to :action => "units"  and return
      end
  end
  
  def add_to_list
    unless session[:added].include?(params[:uid])
      session[:added] << params[:uid]
   end
 end   
  
  
  def update
   @uscurrent = 'current'
   @unit = @tutorial.units.find(params[:id])
    session[:unit] = @unit.id
   @tag_list = @unit.tag_list
    @mods = @unit.resourceables
      if request.post?
         @unit.attributes = params[:unit]
         @unit.add_tags(params[:tags])
         if @unit.save
           case params[:commit]
              when "Save" 
                redirect_to :action => 'units'
              when "Save & Add Modules" 
                redirect_to  :action => 'add_modules', :id =>@unit and return
            end
         end
      end
  end
  
    def remove_unit
      unit = @tutorial.units.find(params[:id])
      uz = @tutorial.unitizations.select{|u| u.unit_id == unit.id}.first
      uz.remove_from_list
      @tutorial.units.delete(unit)
      unit.destroy if unit.tutorials.empty?
      redirect_to :back
    end
  
   def sort
   if params['full'] then 
      sortables = params['full'] 
      sortables.each do |id|
        unitz = @tutorial.unitizations.find(id)
        unitz.update_attribute(:position, sortables.index(id) + 1 )
      end
    end
   render :nothing => true 
 end
 
 def remove_module
      unit = @tutorial.units.find(params[:id])
      resource = unit.resources.find(params[:rid])
      resable = unit.resourceables.select{|r| r.resource_id == resource.id}.first
      resable.remove_from_list
      unit.resources.delete(resource)
      redirect_to :back, :id =>unit
   end


def sort_mods
  @tutorial.units.each do |uz|
     unit = uz.id.to_s
     if params['full'+unit] then 
        sortables = params['full'+unit] 
        sortables.each do |id|
          resource = uz.resourceables.find(id)
          resource.update_attribute(:position, sortables.index(id) + 1 )
       end
      end
    end
   render :nothing => true 
 end
  
  def add_mod
    s = params[:mid1] + params[:mid2]
    unless session[:add_mods].include?(s)
      session[:add_mods] << s
   end
 end  
 
  def add_modules
     @unit ||= Unit.find(params[:id])
     session[:unit] = @unit.id
     @sort = params[:sort] || 'label'
     session[:add_mods] ||= []
     @mods = @user.sort_mods(@sort)
      @mods = paginate_mods(@mods, params[:page] ||= 1, @sort)     
       if request.xhr? 
          render :partial => "shared/add_modules_list", :layout => false
       elsif request.post? and !session[:add_mods].nil?
         @unit.update_resources(session[:add_mods]) 
         session[:add_mods] = nil
         redirect_to :action => "update", :id => @unit
      end
  end 
  
  def new_module
       unless params[:mod][:type].empty? 
           @mod = create_module_object(params[:mod][:type])
           @mod.attributes = params[:mod]
           if @mod.save 
             create_and_add_resource(@user,@mod,@unit)
             redirect_to  :controller => 'module',:action => 'edit_content' , :id =>@mod.id, :type => @mod.class
          else
             flash[:error] = "Could not create the module. There were problems with the following fields: #{@mod.errors.full_messages.join(", ")}" 
             flash[:mod_title] = params[:mod][:module_title]  
             flash[:mod_type] = params[:mod][:type] 
             flash[:mod_title_error] = @mod.errors[:module_title]
             flash[:mod_type_error] = @mod.errors[:type]
             redirect_to  :back
          end
        else
             flash[:error] = "Could not create the module. There were problems with the following fields: Content Type"
             if params[:mod][:module_title].empty? 
               flash[:error] =+ "and Module Name can not be blank." 
             end
             flash[:mod_title] = params[:mod][:module_title]  
             flash[:mod_type] = params[:mod][:type] 
             flash[:mod_title_error] = "" unless params[:mod][:module_title]  
             flash[:mod_type_error] = ""
             redirect_to  :back
      end
  end
  
end
