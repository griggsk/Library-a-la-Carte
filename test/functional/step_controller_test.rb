require File.dirname(__FILE__) + '/../test_helper'
require 'step_controller'

# Re-raise errors caught by the controller.
class StepController; def rescue_action(e) raise e end; end

class StepControllerTest < Test::Unit::TestCase
  def setup
    @controller = StepController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
