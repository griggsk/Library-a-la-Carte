require "vendor/plugins/responds_to_parent/init"
class ImageManagerController < ApplicationController
  # GET /images/1
  # GET /images/1.xml
  def show
    @path = params[:path] ||= ""
    @image_managers = ImageManager.find(:all)
    render :layout => false
  end

 # POST /images
  # POST /images.xml
  def create   
    @image_manager = ImageManager.new params[:image]
    if @image_manager.save
      @image_managers= ImageManager.find(:all)
      flash[:notice] = 'Image was successfully added.'
      respond_to do |format|
        format.js do
          responds_to_parent do
            render :action => "create.js.rjs", :object => {@image_managers,flash}
          end          
        end
      end
     else
        respond_to do |format|
          format.js do
            responds_to_parent do
              err_msg = ""
                @image_manager.errors.each { |attr,msg| 
                  err_msg = err_msg << "#{msg}\n" 
                }
               flash[:error] = err_msg
                render :action => "create.js.rjs", :object => flash
            end
          end      
        end
      end
  end

  # DELETE /images/1
  # DELETE /images/1.xml
  def destroy
    @image_manager = ImageManager.find(params[:id])
    if @image_manager.destroy
      respond_to do |format|
        format.js do
          flash[:notice] = 'Image was successfully deleted.'
          @image_managers = ImageManager.find(:all)
          render :action => "create.js.rjs", :object => {@image_managers,flash}
        end
      end
    else
      respond_to do |format|
        format.js do
          err_msg = ""
          @image_manager.errors.each { |attr,msg| 
            err_msg = err_msg << "#{msg}\n" 
          }
          flash[:error] = err_msg
          render :action => "create.js.rjs", :object => flash
        end
      end
    end
  end
#adds the path of the selected picture to the general tab and keeps the 
#description and title if there were any values for them  
  def add_path_to_general
    @path = params[:pic_path] ||= ""
    @desc = params[:norm_desc]
    @title = params[:norm_title]
    render :partial => 'general_tab'
  end
 end




