require File.dirname(__FILE__) + '/../test_helper'
require 'admin_controller'

# Re-raise errors caught by the controller.
class AdminController; def rescue_action(e) raise e end; end

class AdminControllerTest < Test::Unit::TestCase
  self.use_instantiated_fixtures = true
  fixtures :users

  def setup
    @controller = AdminController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @request.host = "localhost"
  end

  #Test we can't register new users without being an admin
  def test_unauthorized_register
    login_as("bob@mcbob.com", "test")
    post 'register', :user =>  { :name => "newbob", :password => "newpassword", :password_confirmation => "newpassword", :email => "newbob@mcbob.com", :role => "author" }
    assert_response :redirect
    assert_redirected_to :controller => :page, :action => :my_pages
  end
  
  #Test admins can register new users
  def test_register
    #login_as is in test-helper.rb, logs us in as a specific user.
    login_as("admin@your-domain.com", "adm!n")
    post 'register', :user =>  { :name => "newbob", :password => "newpassword", :password_confirmation => "newpassword", :email => "newbob@mcbob.com", :role => "author" }
    assert_response :redirect
    assert_redirected_to :action => 'list_users'
  end

  #Make sure registering a user bombs if not all fields are formatted correctly or present
  def test_bad_signup
    login_as("admin@your-domain.com", "adm!n")
    post 'register', :user => { :name => "newbob", :password => "newpassword", :password_confirmation => "wrong" , :email => "newbob@mcbob.com", :role => "author"}
    assert_response :success
    assert(find_record_in_template("user").errors.invalid?(:password))
    assert_template "register"

    post :register, :user => { :name => "y", :password => "newpassword", :password_confirmation => "newpassword" , :email => "newbob@mcbob.com", :role => "author"}
    assert_response :success
    assert(find_record_in_template("user").errors.invalid?(:name))
    assert_template "register"

    post :register, :user => { :name => "y", :password => "newpassword", :password_confirmation => "wrong" , :email => "newbob@mcbob.com", :role => "author"}
    assert_response :success
    assert(find_record_in_template("user").errors.invalid?(:password))
    assert_template "register"
  end

end

  
  
