require File.dirname(__FILE__) + '/../test_helper'

class ResourceTest < Test::Unit::TestCase
  fixtures :resources

  def test_create_read_update_delete
  #create
   resource = Resource.new(:page_id => 1, :user_id => 1, :resource_id => 1,:resource_type => "LibraryResource" )
   assert resource.save
  #read
   resc = Resource.find(resource.id)
   assert_equal resource.resource_type, resc.resource_type
  #update
   resc.user_id = 2
   assert resc.save
  #delete
   assert resource.destroy
  end
  
  def test_validation
    #check that we can't create a resource without all the required values
     #no user_id
     resource = Resource.new(:page_id => 1, :resource_id => 1,:resource_type => "LibraryResource" )
     assert !resource.save     
     assert resource.errors.invalid?('user_id')
  end
  
  def test_protected_attributes
    #check attributes are protected
    resource = Resource.new(:id => 1, :page_id => 1, :user_id => 1, :resource_id => 1,:resource_type => "LibraryResource" )
    assert resource.save
    assert_not_equal 1, resource.id
  end
  
  
end
