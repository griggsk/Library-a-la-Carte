require File.dirname(__FILE__) + '/../test_helper'
require 'ort_controller'

# Re-raise errors caught by the controller.
class OrtController; def rescue_action(e) raise e end; end

class OrtControllerTest < Test::Unit::TestCase
  def setup
    @controller = OrtController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
