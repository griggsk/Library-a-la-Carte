require File.dirname(__FILE__) + '/../test_helper'

class RssResourceTest < Test::Unit::TestCase
  fixtures :rss_resources

  def test_create_read_update_delete
  #create
   rssmod = RssResource.new(:module_title => "RSS Feed", :saved_name => "My RSS Feed", :rss_feed_url => "feed.xml")
   assert rssmod.save
  #read
   mod = RssResource.find(rssmod.id)
   assert_equal mod.saved_name, rssmod.saved_name
  #update
   mod.saved_name = " "
   assert mod.save
  #delete
  assert mod.destroy
  end
  
  def test_validation
  #check that we can't create a RssResource without all the required values
    #no module_title
    rssmod = RssResource.new(:saved_name => "My RSS Feed", :rss_feed_url => "feed.xml")
    assert rssmod.save
    rssmod.module_title = ""
     assert !rssmod.save
    assert rssmod.errors.invalid?('module_title')
  end
  
  def test_saved
   rssmod = RssResource.new(:saved_name => "My RSS Feed", :rss_feed_url => "feed.xml")
   assert rssmod.save
   assert_equal rssmod.make_qs, true
   rssmod.saved_name = ""
   assert rssmod.save
   assert_equal rssmod.make_qs, false
   
  end
end
