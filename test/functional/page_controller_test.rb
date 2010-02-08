require File.dirname(__FILE__) + '/../test_helper'
require 'page_controller'

# Re-raise errors caught by the controller.
class PageController; def rescue_action(e) raise e end; end

class PageControllerTest < Test::Unit::TestCase

  self.use_instantiated_fixtures  = true
  fixtures :pages, :users, :resources

  def setup
    @controller = PageController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.host = "localhost"
    @request.session[:user_id] = 1000001
    
  end

  def test_my_pages
  #check list
    get :my_pages
    assert_response :success
    assert_template 'my_pages'
    assert_not_nil assigns(:title_mssg)
    assert_not_nil assigns(:lclass)
    assert_not_nil assigns(:pages)
    assert_not_nil assigns(:which_pages)
  #check that we only list the current user's pages 
    p = @bob.pages.uniq
    assert_equal  p, assigns(:pages)
  end

  def test_bad_create
  #check that we can't create a page without all required fields  
  post :create_page, :page => {
                            :subject => "ALS",
                            :course_num =>  "201",
                            :course_name => "College Reading",
                            :term => "W",
                            :sect_num => "001"}
   assert_response :success
   #but our schema assigns a default template of 2 for a new page.
   #I'm assuming this is is no longer needed, commenting out.
#   assert_invalid_column_on_record "page", ["template", "year"]
   assert_template "page/create_page"
   
  #check can't create new page with existing course name
  post :create_page, :page => {:template => "life.gif",
                            :published => "F",
                            :subject => "ALS",
                            :course_num =>  "201",
                            :course_name => "College Reading",
                            :term => "W",
                            :year => "07",
                            :sect_num => "001"}
   assert_response :success
   assert(find_record_in_template("page").errors.invalid?(:course_name))
   assert_template "page/create_page"
  end
  
  def test_full_create
  #check that we can create a page, make the file name and link the user
    num_pages = @bob.pages.count
    post :create_page, :page => {:template => "life.gif",
                            :published => "F",
                            :subject => "ALS",
                            :course_num =>  "102",
                            :course_name => "College Reading",
                            :term => "W",
                            :year => "07",
                            :sect_num => "001"}
    assert_not_nil assigns(:title_mssg)
    assert_not_nil assigns(:nclass)
    assert_not_nil assigns(:subj_list)                       
    assert_not_nil assigns(:page)
    page = assigns(:page)
   #check that the current user was linked to the page
    assert page.users.include?(@bob)
   #check the the current page is in the session
    assert_equal(session[:page], page.id)
    assert_response :redirect
    assert_redirected_to :controller => 'creation', :action => 'add_modules'
    assert_equal num_pages + 1, @bob.pages.count
  end

  def test_edit
    get :open_page, :id => 1
    assert_not_nil assigns(:page)
    assert assigns(:page).valid?
    assert_equal(session[:page], 1)
    assert_redirected_to :controller => 'creation', :action => 'edit_page'
  end

  def test_publish
  #check that a page sets it's published status
   @page2.published = false
   post :publish, :id => 2
   assert_not_nil assigns(:page)
   page = assigns(:page)
   assert_equal @page2, page
   assert_response :redirect
   assert_redirected_to :action => 'edit_page'
   assert_equal  true, page.published
  end
  
  
  def test_unpublish
  #check that a page sets it's unpublished status 
    @page3.published = true
    post :unpublish, :id => 3
    assert_not_nil assigns(:page)
    page = assigns(:page)
    assert_equal @page3, page
    assert_response :redirect
    assert_redirected_to :action => 'edit_page'
    assert_equal  false, page.published
  end
  
  def test_bad_copy
  #check that pages are copied
  num_pages = @bob.pages.count
  post :copy_page, :id => 2
  assert_equal(session[:page], nil)
  assert_not_nil assigns(:subj_list)       
  assert_not_nil assigns(:old_page)
  assert_not_nil assigns(:page)
  assert_not_nil assigns(:title_mssg)
  #assign vars 
  page = assigns(:page)
  old_page = assigns(:old_page)
  assert_equal @page2, old_page
  
  #check that we can't create a copy with a course name that already exists
  assert_response :success
  assert(find_record_in_template("page").errors.invalid?(:course_name))
  assert_equal num_pages, @bob.pages.count
  end
  
  def test_can_copy
  num_pages = @bob.pages.uniq.size
  assert_equal(2, num_pages)
  post :copy_page, :id => 2, :page => {:year => "08"}
  assert_not_nil assigns(:old_page)
  assert_not_nil assigns(:page)
  assert_valid assigns(:page)
  #assign helper vars 
  page = assigns(:page)
  old_page = assigns(:old_page)
  assert_equal @page2, old_page
  
  #check that the new page got the cloned page's attributes (subset)
  assert_equal page.subject, old_page.subject
  assert_equal page.term, old_page.term
  assert_equal page.sect_num, old_page.sect_num
  
  #check that published is set to false
  assert_equal(page.published, false) 
  #check that the copy was successful
  assert page.save
  assert_equal(page.id, session[:page])
  #check that the new page got the cloned page's modules
  assert_not_nil page.modules
  #check that the current user was linked to the cloned page
  assert page.users.include?(@bob)
  end
  
  def test_share
    post :share_page, :id => 1
    assert_not_nil assigns(:page) 
    assert_not_nil assigns(:page_owners)
    assert_not_nil assigns(:user_list)
    assert_not_nil assigns(:title_mssg)
    # check that only users that own the page are listed
    assert !assigns(:page_owners).include?(@bobtwo)
    assert_redirected_to :action => 'share_page'
  end
  
 
  
  def test_destroy_one_user
  #check that the page get destroyed when it has only one user
    assert_not_nil Page.find(1)
    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'my_pages'
    assert_raise(ActiveRecord::RecordNotFound) {
      Page.find(1)
    }
  end
  
  def destroy_multiple_users
  #check that the page does not get destroyed when there are multiple users
  #but the resource connecting the user and the page does
   assert_not_nil Page.find(2)
   count= @page2.users.count
   assert_equal 2, count
   
   post :destroy, :id => 2
   assert_not_nil assigns(:resource)
   assert assigns(:resource).valid?
   assert assigns(:resource).include?(@resource2)
   assert_raise(ActiveRecord::RecordNotFound) {
      Resource.find(2)
    }
   assert_redirected_to :action => 'my_pages'
   assert_not_nil Page.find(2)
  end
  
  def test_send_url
   get :send_url, :id => 2
   assert_not_nil assigns(:page)
   assert assigns(:page).valid?
   assert_not_nil assigns(:page_url)
   assert_response :success
  end
 
  #Make sure users can change their passwords and that the new password functions
  def test_change_password
    get :my_account
    assert_response :success
    assert_template 'my_account'
    password = "newpassword"
    post :my_account, :user => {:password => password,
                                :password_confirmation => password}
    assert_equal flash[:notice], "Password Changed"
    assert_response :redirect
    assert_redirected_to :action => :my_account

    logout
    assert_nil session[:user_id]
    login_as("bob@mcbob.com", password)
    assert_not_nil session[:user_id]
  end

  def test_change_information
    post :account_info, :user => {:name => "New Name", :email => "newemail@mcbob.com"}
    assert_response :redirect
    assert_equal "Account Changed", flash[:notice]
    assert_redirected_to :action => :my_account
    assert_equal(find_record_in_template("user").email, "newemail@mcbob.com")
    assert_equal(find_record_in_template("user").name, "New Name")
  end

  def test_cant_change_roles
    post :account_info, :user => {:role => "admin"}
    assert_response :redirect
    assert_redirected_to :action => :my_account
    assert_equal(find_record_in_template("user").role, "author")
  end

end
