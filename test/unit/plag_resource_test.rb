require File.dirname(__FILE__) + '/../test_helper'

class PlagResourceTest < Test::Unit::TestCase
  fixtures :plag_resources
 def test_create_read_update_delete
  #create
   plagmod = PlagResource.new(:module_title => "Plagerism", :saved_name => "My Plagerism", :information => "This is plagerism")
   assert plagmod.save
  #read
   mod = PlagResource.find(plagmod.id)
   assert_equal mod.saved_name, plagmod.saved_name
  #update
   mod.saved_name = " "
   assert mod.save
  #delete
  assert mod.destroy
  end
  
  def test_validation
  #check that we can't create a PlagResource without all the required values
    #no module_title
    plagmod = PlagResource.new(:saved_name => "My Plagerism", :information => "This is Plagerism")
    assert plagmod.save
    plagmod.module_title = ""
     assert !plagmod.save
    assert plagmod.errors.invalid?('module_title')
  end
  
  def test_saved
   plagmod = PlagResource.new(:saved_name => "My Plagerism Info", :information => "This is Plagerism")
   assert plagmod.save
   assert_equal plagmod.make_qs, true
   plagmod.saved_name = ""
   assert plagmod.save
   assert_equal plagmod.make_qs, false
   
  end
end
