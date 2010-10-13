
require File.dirname(__FILE__) + '/../test_helper'
require 'login_controller'

# Re-raise errors caught by the controller.
class LoginController; def rescue_action(e) raise e end; end

class LoginControllerTest < Test::Unit::TestCase

  self.use_instantiated_fixtures  = true
  fixtures :users

  def setup
    @controller = LoginController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.host = "localhost"
  end

  def test_auth_bob
    #check we can login
    post :login,  { :email => "bob@mcbob.com", :password => "test" }
    assert(@response.has_session_object?( :user_id))
    assert_equal @bob.id, session[:user_id]
    assert_response :redirect
    assert_redirected_to :controller => "page", :action => "my_pages"
  end
 
  def test_invalid_login
    #can't login with incorrect password
    post :login, { :email => "bob@mcbob.com", :password => "not_correct" }
    assert_response :success
    assert(!@response.has_session_object?(:user_id))
    assert flash[:notice]
    assert_template "login/login"
  end

  def test_login_logoff
    #login
    post :login, { :email => "bob@mcbob.com", :password => "test"}
    assert_response :redirect
    assert(@response.has_session_object?(:user_id))
    #then logoff
    get :logout
    assert_response :redirect
    assert(!@response.has_session_object?(:user_id))
    assert_redirected_to :action=>'login'
  end
  
  def test_forgot_password
    #we can index
    post :login, { :email => "bob@mcbob.com", :password => "test"}
    assert_response :redirect
    assert(@response.has_session_object?(:user_id))
    #logout
    get :logout
    assert_response :redirect
    assert(!@response.has_session_object?(:user_id))
    #enter an email that doesn't exist
    post :forgot_password, :user => {:email=>"notauser@doesntexist.com"}
    assert_response :success
    assert(!@response.has_session_object?(:user_id))
    assert_template "login/forgot_password"
    assert flash[:notice]
    #enter bobs email
    get :forgot_password, :user => {:email=>"exbob@mcbob.com"}   
    assert_response :success
  end
  
  

  def test_index_required
    #can't access pages if not logged in
    get :logout
    assert flash[:notice]
    assert_response :redirect
    assert_redirected_to :action=>'login'
    #index
    post :login, { :email => "bob@mcbob.com", :password => "test"}
    assert_response :redirect
    assert(@response.has_session_object?(:user_id))
    #can access it now
    get :logout
    assert_response :redirect
    assert flash.empty?
    assert_redirected_to :action=>'login'
  end
end
