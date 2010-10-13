require File.dirname(__FILE__) + '/../test_helper'
require 'guide_controller'

# Re-raise errors caught by the controller.
class GuideController; def rescue_action(e) raise e end; end

class GuideControllerTest < Test::Unit::TestCase
  def setup
    @controller = GuideController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
