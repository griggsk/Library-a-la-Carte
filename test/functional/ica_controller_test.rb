require File.dirname(__FILE__) + '/../test_helper'
require 'ica_controller'

# Re-raise errors caught by the controller.
class IcaController; def rescue_action(e) raise e end; end

class IcaControllerTest < Test::Unit::TestCase
  self.use_instantiated_fixtures  = true
  fixtures :pages, :users, :resources, :miscellaneous_resources, :lib_resources
  
  def setup
    @controller = IcaController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end


  def test_index
    get :index, :id => 1
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:mods)
    assert_not_nil assigns(:page)
  end
  
  def test_more_info
   get :more_info, :page => 1, :id => 1
   assert_not_nil assigns(:page)
   assert_not_nil assigns(:mod)
   assert_response :success
   assert_template 'more_info'
  end
  
  
  
end
