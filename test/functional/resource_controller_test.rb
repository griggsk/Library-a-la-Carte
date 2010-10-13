require File.dirname(__FILE__) + '/../test_helper'
require 'creation_controller'

# Re-raise errors caught by the controller.
class CreationController; def rescue_action(e) raise e end; end

class CreationControllerTest < Test::Unit::TestCase
  self.use_instantiated_fixtures  = true
  fixtures :pages, :users, :resources, :miscellaneous_resources
  
  def setup
    @controller = CreationController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.host = "localhost"
    @request.session[:user_id] = 1000001
    @request.session[:page] = 1
    @request.session[:selected] = [MiscellaneousResource, LibResource]
  end

  def test_page_setup
  post :page_setup, :page => {}
  assert_equal(session[:selected], nil)
  assert_not_nil assigns(:title_mssg)
  assert_not_nil assigns(:nclass)
  assert_not_nil assigns(:subj_list) 
  assert_redirected_to :action => 'add_modules'
  end
  
  def test_add_modules
  post :add_modules
  assert_equal nil, session[:selected] 
  assert_not_nil assigns(:title_mssg)
  assert_not_nil assigns(:aclass)
  assert_not_nil assigns(:mods)
  #check that the mods are bobs
  assert @bob.modules.eql?(assigns(:mods))
  assert_not_nil assigns(:which_pages) 
  assert_not_nil assigns(:list)  
  assert_template 'add_modules'
  end
  
  
  def test_selected_modules
  post :selected_modules, :mods => ['Custom Information', 'Course Librarian']
  assert(@response.has_session_object?(:selected))
  assert_redirected_to :action => :create_module
  end
  
  def test_no_selected_modules
  post :selected_modules
  assert_redirected_to :action => :add_modules
  end
  
  def test_create_module
    post :create_module
    assert_not_nil assigns(:title_mssg)
    assert_not_nil assigns(:aclass)
    assert_not_nil assigns(:mod)
    assert_equal(session[:reserves], nil)
    mod = assigns(:mod)
  end

  def test_edit_page
    post :edit_page
    assert_equal(session[:selected], nil)
    assert_not_nil assigns(:title_mssg)
    assert_not_nil assigns(:mclass)
    assert_not_nil assigns(:mods)
    #check that the mods are the pages
    assert @page1.modules.eql?(assigns(:mods)) 
    assert_template 'edit_page'
  end


  
  def test_remove_more
  post :remove_more, :id => 1, :type => 'MiscellaneousResource'
  assert_not_nil assigns(:mod)
  assert assigns(:mod).more_info == ""
  assert assigns(:mod).save
  end
  
  def test_retrieve_reserves
    xhr :post, :retrieve_reserves
    assert_not_nil @response.has_session_object?(:reserves)
    assert_template "_reserved_titles"
  end
end
