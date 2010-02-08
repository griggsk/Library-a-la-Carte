require File.dirname(__FILE__) + '/../test_helper'
require 'tutorial_controller'

# Re-raise errors caught by the controller.
class TutorialController; def rescue_action(e) raise e end; end

class TutorialControllerTest < Test::Unit::TestCase
  def setup
    @controller = TutorialController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
