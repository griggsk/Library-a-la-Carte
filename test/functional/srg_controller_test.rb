require File.dirname(__FILE__) + '/../test_helper'
require 'srg_controller'

# Re-raise errors caught by the controller.
class SrgController; def rescue_action(e) raise e end; end

class SrgControllerTest < Test::Unit::TestCase
  def setup
    @controller = SrgController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
