#out of date will not pass
require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  self.use_instantiated_fixtures  = true
  fixtures :users, :resources, :assign_resources, :lib_resources

  def test_auth 
    #check that we can authenticate with a valid user 
    assert_equal  @bob, User.authenticate("bob@mcbob.com", "test")    
    #wrong username
    assert_nil    User.authenticate("nonbob", "test")
    #wrong password
    assert_nil    User.authenticate("bob@mcbob.com", "wrongpass")
    #wrong name and pass
    assert_nil    User.authenticate("nonbob", "wrongpass")
  end


  def test_passwordchange
    # check success
    assert_equal @longbob, User.authenticate("lbob@mcbob.com", "longtest")
    #change password
    @longbob.password = @longbob.password_confirmation = "nonbobpasswd"
    assert @longbob.save
    #new password works
    assert_equal @longbob, User.authenticate("lbob@mcbob.com", "nonbobpasswd")
    #old pasword doesn't work anymore
    assert_nil   User.authenticate("lbob@mcbob.com", "longtest")
    #change back again
    @longbob.password = @longbob.password_confirmation = "longtest"
    assert @longbob.save
    assert_equal @longbob, User.authenticate("lbob@mcbob.com", "longtest")
    assert_nil   User.authenticate("lbob@mcbob.com", "nonbobpasswd")
  end

  def test_disallowed_passwords
    #check that we can't create a user with any of the disallowed paswords
    u = User.new    
    u.name = "nonbob"
    u.email = "nonbob@mcbob.com"
    #too short
    u.password = u.password_confirmation = "tiny" 
    assert !u.save     
    assert u.errors.invalid?('password')
    #too long
    u.password = u.password_confirmation = "hugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehuge"
    assert !u.save     
    assert u.errors.invalid?('password')
    #empty
    u.password = u.password_confirmation = ""
    assert !u.save    
    assert u.errors.invalid?('password')
    #ok
    u.password = u.password_confirmation = "bobs_secure_password"
    assert u.save     
    assert u.errors.empty? 
  end

  def test_bad_names
    #check we can't create a user with an invalid username
    u = User.new  
    u.password = u.password_confirmation = "bobs_secure_password"
    u.email = "okbob@mcbob.com"
    #too short
    u.name = "x"
    assert !u.save     
    assert u.errors.invalid?('name')
    #too long
    u.name = "hugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhug"
    assert !u.save     
    assert u.errors.invalid?('name')
    #empty
    u.name = ""
    assert !u.save
    assert u.errors.invalid?('name')
    #ok
    u.name = "okbob"
    assert u.save  
    assert u.errors.empty?
    #no email
    u.email=nil   
    assert !u.save     
    assert u.errors.invalid?('email')
    #invalid email
    u.email='notavalidemail'   
    assert !u.save     
    assert u.errors.invalid?('email')
    #ok
    u.email="validbob@mcbob.com"
    assert u.save  
    assert u.errors.empty?
  end


  def test_collision
    #check can't create new user with existing email
    u = User.new
    u.email = "exbob@mcbob.com"
    u.password = u.password_confirmation = "bobs_secure_password"
    assert !u.save
  end


  def test_create
    #check create works and we can authenticate after creation
    u = User.new
    u.name = "nonexistingbob"
    u.password = u.password_confirmation = "bobs_secure_password"
    u.email="nonexistingbob@mcbob.com"  
    assert_not_nil u.salt
    assert u.save
    assert_equal 10, u.salt.length
    assert_equal u, User.authenticate(u.email, u.password)

    u = User.new(:name => "newbob", :password => "newpassword", :password_confirmation => "newpassword", :email => "newbob@mcbob.com" )
    assert_not_nil u.salt
    assert_not_nil u.password
    assert_not_nil u.hashed_psswrd
    assert u.save 
    assert_equal u, User.authenticate(u.email, u.password)

  end

  def test_new_password
    #check user authenticates
    assert_equal  @bob, User.authenticate("bob@mcbob.com", "test")    
    #set new password
    new_pass = @bob.set_new_password
    assert_not_nil new_pass
    #old password no longer works
    assert_nil User.authenticate("bob@mcbob.com", "test")
    #can authenticate with the new password
    pass = @bob.password
    assert_not_nil pass
    assert_equal  @bob, User.authenticate("bob@mcbob.com",pass)    
  end

  def test_rand_str
    #check random string generator
    new_pass = User.random_string(10)
    assert_not_nil new_pass
    assert_equal 10, new_pass.length
  end

  def test_sha1
    #check SHA1 digest
    u=User.new
    u.name      = "nonexistingbob"
    u.email="nonexistingbob@mcbob.com"  
    u.salt="1000"
    u.password = u.password_confirmation = "bobs_secure_password"
    assert u.save   
    assert_equal 'b1d27036d59f9499d403f90e0bcf43281adaa844', u.hashed_psswrd
    assert_equal 'b1d27036d59f9499d403f90e0bcf43281adaa844', User.encrypt("bobs_secure_password", "1000")
  end

  def test_protected_attributes
    #check attributes are protected
    u = User.new(:id=>999999, :salt=>"I-want-to-set-my-salt", :name => "badbob", :password => "newpassword", :password_confirmation => "newpassword", :email => "badbob@mcbob.com" )
    assert u.save
    assert_not_equal 999999, u.id
    assert_not_equal "I-want-to-set-my-salt", u.salt

    u.update_attributes(:id=>999999, :salt=>"I-want-to-set-my-salt", :name => "verybadbob")
    assert u.save
    assert_not_equal 999999, u.id
    assert_not_equal "I-want-to-set-my-salt", u.salt
    assert_equal "verybadbob", u.name
  end
  
  def test_get_modules
  mod_count = @bob.modules.size
  assert_equal(1, mod_count)
  end
  
  def test_find_module
  mod = @bob.find_mod(1, "AssignResource")
  assert_equal(1, mod.id)
  assert_equal(AssignResource, mod.class)
  end
end
