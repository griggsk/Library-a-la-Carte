require File.dirname(__FILE__) + '/../test_helper'

class ReserveResourceTest < Test::Unit::TestCase
  fixtures :reserve_resources

   def test_create_read_update_delete
  #create
   reservesmod = ReserveResource.new(:module_title => "Course Reserces", :saved_name => "My Reserves", :reserves => "Reserves")
   assert reservesmod.save
  #read
   mod = ReserveResource.find(reservesmod.id)
   assert_equal mod.saved_name, reservesmod.saved_name
  #update
   mod.saved_name = " "
   assert mod.save
  #delete
  assert mod.destroy
  end
  
  def test_validation
  #check that we can't create a ReserveResource without all the required values
    #no module_title
    reservesmod = ReserveResource.new(:saved_name => "My Reserves", :reserves => "Reserves")
    assert reservesmod.save
    reservesmod.module_title = ""
     assert !reservesmod.save
    assert reservesmod.errors.invalid?('module_title')
  end
  
  def test_saved
   reservesmod = ReserveResource.new(:saved_name => "My Reserves Info", :reserves => "These are reserved")
   assert reservesmod.save
   assert_equal reservesmod.make_qs, true
   reservesmod.saved_name = ""
   assert reservesmod.save
   assert_equal reservesmod.make_qs, false
   
  end
end
