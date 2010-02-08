require File.dirname(__FILE__) + '/../test_helper'

class LearnObjResourceTest < Test::Unit::TestCase
  fixtures :learn_obj_resources
def test_create_read_update_delete
  #create
   learningmod = LearnObjResource.new(:module_title => "Learning Objects", :saved_name => "My Learning Objects", :objects => "This is an object")
   assert learningmod.save
  #read
   mod = LearnObjResource.find(learningmod.id)
   assert_equal mod.saved_name, learningmod.saved_name
  #update
   mod.saved_name = " "
   assert mod.save
  #delete
  assert mod.destroy
  end
  
  def test_validation
  #check that we can't create a LearnObjResource without all the required values
    #no module_title
    learningmod = LearnObjResource.new(:saved_name => "My Learning Objects", :objects => "This is an object")
    assert learningmod.save
    learningmod.module_title = ""
     assert !learningmod.save
    assert learningmod.errors.invalid?('module_title')
  end
  
  def test_saved
   learningmod = LearnObjResource.new(:saved_name => "My Learning Objects", :objects => "This is an object")
   assert learningmod.save
   assert_equal learningmod.make_qs, true
   learningmod.saved_name = ""
   assert learningmod.save
   assert_equal learningmod.make_qs, false
   
  end
end
