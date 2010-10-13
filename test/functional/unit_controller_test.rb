require File.dirname(__FILE__) + '/../test_helper'
require 'unit_controller'

# Re-raise errors caught by the controller.
class UnitController; def rescue_action(e) raise e end; end

class UnitControllerTest < Test::Unit::TestCase
  def setup
    @controller = UnitController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
