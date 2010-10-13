require File.dirname(__FILE__) + '/../test_helper'

class RecomResourceTest < Test::Unit::TestCase
  fixtures :recom_resources

  def test_create_read_update_delete
  #create
   recomendmod = RecomResource.new(:module_title => "Instructor Recomendations", :saved_name => "My Recomendations", :recommendations => "This is My Recomendations")
   assert recomendmod.save
  #read
   mod = RecomResource.find(recomendmod.id)
   assert_equal mod.saved_name, recomendmod.saved_name
  #update
   mod.saved_name = " "
   assert mod.save
  #delete
  assert mod.destroy
  end
  
  def test_validation
  #check that we can't create a RecomResource without all the required values
    #no module_title
    recomendmod = RecomResource.new(:saved_name => "My Recomendations", :recommendations => "This is Recomendations")
    assert recomendmod.save
    recomendmod.module_title = ""
     assert !recomendmod.save
    assert recomendmod.errors.invalid?('module_title')
  end
  
  def test_saved
   recomendmod = RecomResource.new(:saved_name => "My Recomendations Info", :recommendations => "This is My Recomendations")
   assert recomendmod.save
   assert_equal recomendmod.make_qs, true
   recomendmod.saved_name = ""
   assert recomendmod.save
   assert_equal recomendmod.make_qs, false
   
  end
end
