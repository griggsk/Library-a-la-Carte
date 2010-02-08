require File.dirname(__FILE__) + '/../test_helper'

class LibResourceTest < Test::Unit::TestCase
  fixtures :lib_resources

  def test_create_read_update_delete
  #create
   libmod = LibResource.new(:module_title => "Course Librarian", :saved_name => "My Librarian Info", :librarian_name => "Fran Smith",:chat_info => "Fran, AIM", :office_location => "Kelly 124", :office_hours => "12-2" )
   assert libmod.save
  #read
   mod = LibResource.find(libmod.id)
   assert_equal mod.saved_name, libmod.saved_name
  #update
   mod.saved_name = " "
   assert mod.save
  #delete
  assert mod.destroy
  end
  
  def test_validation
  #check that we can't create a libresource without all the required values
    #no module_title
    libmod = LibResource.new(:saved_name => "My Librarian Info", :librarian_name => "Fran Smith",:chat_info => "Fran, AIM", :office_location => "Kelly 124", :office_hours => "12-2" )
    assert libmod.save
    libmod.module_title = ""
     assert !libmod.save
    assert libmod.errors.invalid?('module_title')
  end
  
  def test_saved
   libmod = LibResource.new(:saved_name => "My Librarian Info", :librarian_name => "Fran Smith",:chat_info => "Fran, AIM", :office_location => "Kelly 124", :office_hours => "12-2" )
   assert libmod.save
   assert_equal libmod.make_qs, true
   libmod.saved_name = ""
   assert libmod.save
   assert_equal libmod.make_qs, false
   
  end
end
