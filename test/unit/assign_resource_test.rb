require File.dirname(__FILE__) + '/../test_helper'

class AssignResourceTest < Test::Unit::TestCase
  fixtures :assign_resources


  def test_create_read_update_delete
  #create
   assignmod = AssignResource.new(:module_title => "Research Assignment", :saved_name => "My Assignment Info", :description => "This is an assigment",:assignment_url => "www.assign.com", :syllabus_url => "www.syllabus.com")
   assert assignmod.save
  #read
   mod = AssignResource.find(assignmod.id)
   assert_equal mod.saved_name, assignmod.saved_name
  #update
   mod.saved_name = " "
   assert mod.save
  #delete
  assert mod.destroy
  end
  
  def test_validation
  #check that we can't create a AssignResource without all the required values
    #no module_title
    assignmod = AssignResource.new(:saved_name => "My Assignment Info", :description => "This is an assigment",:assignment_url => "www.assign.com", :syllabus_url => "www.syllabus.com")
    assert assignmod.save
    assignmod.module_title = ""
     assert !assignmod.save
    assert assignmod.errors.invalid?('module_title')
  end
  
  def test_saved
   assignmod = AssignResource.new(:saved_name => "My Assignment Info", :description => "This is an assigment",:assignment_url => "www.assign.com", :syllabus_url => "www.syllabus.com")
   assert assignmod.save
   assert_equal assignmod.make_qs, true
   assignmod.saved_name = ""
   assert assignmod.save
   assert_equal assignmod.make_qs, false
   
  end
end


