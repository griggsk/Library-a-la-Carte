#out of date
require File.dirname(__FILE__) + '/../test_helper'

class PageTest < Test::Unit::TestCase
  self.use_instantiated_fixtures  = true
  fixtures :pages, :resources, :assign_resources, :lib_resources

  
  def test_create_read_update_delete
  #ensure that Page plays well with the DB
  #check create
    p = Page.new( :template => 2, :published => "F", :subject => "ALS", :sect_num => "011", :course_num => "210", :course_name =>"Introduction to CS", :term => "W", :year =>"08")
    assert p.save!  
  #check read
   page = Page.find(p.id)
   assert_equal page.subject, p.subject
  #check update
   page.published = "T"
   assert page.save
   assert_equal page.published, true
  #check delete
   assert page.destroy 
  end
  
  
  def test_inclusions
  #check that we can't create pages with invalid value choices
  p = Page.new(:published => "F", :subject => "ALS", :sect_num => "011", :course_num => "210",:course_name =>"Introduction to CS", :term => "W", :year =>"08")
  #empty template
  p.template = ""
  assert !p.save     
  assert p.errors.invalid?('template')
  #OK
  p.template = 1
  assert p.save  
  assert p.errors.empty?
  #no term
  p.term = nil
  assert !p.save     
  assert p.errors.invalid?('term')
  #not in term list
  p.term = "D"
  assert !p.save     
  assert p.errors.invalid?('term')
  #OK
  p.term = "SU"
  assert p.save  
  assert p.errors.empty?
  #no year
  p.year = nil
  assert !p.save     
  assert p.errors.invalid?('year')
  #not in year list
  p.year = "00"
  assert !p.save     
  assert p.errors.invalid?('year')
  #OK
  p.year = "07"
  assert p.save  
  assert p.errors.empty?
  #no subject
  p.subject = nil
  assert !p.save     
  assert p.errors.invalid?('subject')
  #OK
  p.subject = "AG"
  assert p.save     
  assert p.errors.empty?
  end
  
  def test_number_validation
  #check that couse_num and subject_num are integers
  p = Page.new(:published => "F", :subject => "ALS", :sect_num => "011", :course_num => "210",:course_name =>"Introduction to CS", :term => "W", :year =>"08")
  #section_num bad
  p.sect_num = "Not a Number"
  assert !p.save     
  assert p.errors.invalid?('sect_num')
  
  #course_num bad
  p.course_num = "Not a Number"
  assert !p.save     
  assert p.errors.invalid?('course_num')
  end
  
  def test_titles
  #check that titles are made correctly
  title = @page2.header_title
  assert_not_nil title
  assert_equal "ANTH 230: Introduction to Cultural Anthropology", title
  
  ti = @page1.search_title
  assert_not_nil ti
  
  titles = @page2.search_title
  assert_not_nil titles
  assert_equal "ANTH 230: Introduction to Cultural Anthropology W #012", titles
  
  t = @page3.search_title
  assert_not_nil t
  assert_equal "AG 301: General Chemistry  #011", t
  end
  
  def test_published
  #check that we can set and change the published status of a page
  pub = @page2.published
  assert_not_nil pub
  @page2.publish_page("T")
  assert_equal true, @page2.published
  end
  
  def test_uniqueness
  p = Page.new(:template => 2, :published => "F", :subject => "ALS", :sect_num => "011", :course_num => "310",:course_name =>"Introduction to CS", :term => "W", :year =>"08")
  assert p.save
  p2= Page.new(:template => 2, :published => "F", :subject => "ALS", :sect_num => "011", :course_num => "310",:course_name =>"Introduction to CS", :term => "W", :year =>"08")
  assert !p2.save
  assert p2.errors.invalid?('course_name')
  #change something
  p2 = Page.new(:template => 2, :published => "F", :subject => "ALS", :sect_num => "012", :course_num => "210",:course_name =>"Introduction to CS", :term => "W", :year =>"08")
  assert p2.save
  end
  
  def test_get_modules
  mod_count = @page1.modules.size
  assert_equal(2, mod_count)
  end
  
  def test_find_resource
  resource = @page1.find_resource(1, "AssignResource")
  assert_equal(Resource, resource.class)
  
  end
  
  def test_find_module
  mod = @page1.find_mod(1, "AssignResource")
  assert_equal(1, mod.id)
  assert_equal(AssignResource, mod.class)
  
  end
  
end
