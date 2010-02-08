require File.dirname(__FILE__) + '/../test_helper'

class MiscellaneousResourceTest < Test::Unit::TestCase
  fixtures :miscellaneous_resources

  def test_create_read_update_delete
  #create
   miscmod = MiscellaneousResource.new(:module_title => "Miscellaneous", :saved_name => "My Miscellaneous", :content => "This is Miscellaneous")
   assert miscmod.save
  #read
   mod = MiscellaneousResource.find(miscmod.id)
   assert_equal mod.saved_name, miscmod.saved_name
  #update
   mod.saved_name = " "
   assert mod.save
  #delete
  assert mod.destroy
  end
  
  def test_validation
  #check that we can't create a MiscellaneousResource without all the required values
    #no module_title
    miscmod = MiscellaneousResource.new(:saved_name => "My Miscellaneous", :content => "This is Miscellaneous")
    assert miscmod.save
    miscmod.module_title = ""
     assert !miscmod.save
    assert miscmod.errors.invalid?('module_title')
  end
  
  def test_saved
   miscmod = MiscellaneousResource.new(:saved_name => "My Miscellaneous Info", :content => "This is Miscellaneous")
   assert miscmod.save
   assert_equal miscmod.make_qs, true
   miscmod.saved_name = ""
   assert miscmod.save
   assert_equal miscmod.make_qs, false
   
  end
  
  def test_more_info
   miscmod = MiscellaneousResource.new(:saved_name => "My Miscellaneous Info", :content => "This is Miscellaneous")
   miscmod.more_info = "This is some more info"
   assert miscmod.save
   info = miscmod.more_info
   assert_equal("This is some more info",info)
  end
end
