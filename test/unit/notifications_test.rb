require File.dirname(__FILE__) + '/../test_helper'
require 'notifications'

class NotificationsTest < Test::Unit::TestCase
   fixtures :pages
   
  def setup
    @user = User.new(:name => "Bob", :email => "bob@mail.com", :salt => "1000", :hashed_psswrd => "77a0d943cdbace52716a9ef9fae12e45e2788d39" )
    @instructor = User.new(:name => "Bobby", :email => "bobby@mail.com", :salt => "1000", :hashed_psswrd => "77a0d943cdbace52716a9ef9fae12e45e2788d39" )
    @user2 = User.new(:name => "Bobbi", :email => "bobbi@mail.com", :salt => "1000", :hashed_psswrd => "77a0d943cdbace52716a9ef9fae12e45e2788d39" )
  
  end

  def test_forgot_password
 #check the email's dynamic content
    responce = Notifications.create_forgot_password(@user.email, @user.name, @user.password)
    assert_equal("Your ICAP Creation Tool password is...", responce.subject)
    assert_equal("bob@mail.com", responce.to[0])
    assert_match(/Your new ICA Creation Tool password is/, responce.body)
  end
  
   def test_share_page
 #check the email's dynamic content
    responce = Notifications.create_share_page(@user.email, @user2.email, @page1)
    assert_equal("Sharing this ICAP with you", responce.subject)
    assert_equal("bob@mail.com", responce.to[0])
    assert_match(/I have shared the ICA page/, responce.body)
  end
  
   def test_send_url
 #check the email's dynamic content
    responce = Notifications.create_send_url(@instructor.email, @user2.email,"page.com",@page1)
    assert_equal("A new ICAP for your class", responce.subject)
    assert_equal("bobby@mail.com", responce.to[0])
    assert_match(/A new ICA page has been created for /, responce.body)
  end

  
end
