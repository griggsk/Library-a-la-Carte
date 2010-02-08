require File.dirname(__FILE__) + '/../test_helper'

class InstResourceTest < Test::Unit::TestCase
  fixtures :inst_resources

  def test_create_read_update_delete
  #create
   instmod = InstResource.new(:module_title => "Course Instructor", :saved_name => "My Instructor Info", :instructor_name => "Fran Smith",:email => "fran@oregonstate.edu", :office_location => "Kelly 124", :office_hours => "12-2" )
   assert instmod.save
  #read
   mod = InstResource.find(instmod.id)
   assert_equal mod.saved_name, instmod.saved_name
  #update
   mod.saved_name = " "
   assert mod.save
  #delete
  assert mod.destroy
  end
  
  def test_validation
  #check that we can't create a InstResource without all the required values
    #no module_title
    instmod = InstResource.new(:saved_name => "My Instructor Info", :instructor_name => "Fran Smith", :email => "fran@oregonstate.edu", :office_location => "Kelly 124", :office_hours => "12-2" )
    assert instmod.save
    instmod.module_title = ""
     assert !instmod.save
    assert instmod.errors.invalid?('module_title')
  end
  
  def test_saved
   instmod = InstResource.new(:saved_name => "My Instructor Info", :instructor_name => "Fran Smith", :email => "fran@oregonstate.edu", :office_location => "Kelly 124", :office_hours => "12-2" )
   assert instmod.save
   assert_equal instmod.make_qs, true
   instmod.saved_name = ""
   assert instmod.save
   assert_equal instmod.make_qs, false
   
  end
end
