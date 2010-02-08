require File.dirname(__FILE__) + '/../test_helper'
require 'reserve_controller'

# Re-raise errors caught by the controller.
class ReserveController; def rescue_action(e) raise e end; end

class ReserveControllerTest < Test::Unit::TestCase
  def setup
    @controller = ReserveController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
