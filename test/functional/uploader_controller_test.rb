require File.dirname(__FILE__) + '/../test_helper'
require 'uploader_controller'

# Re-raise errors caught by the controller.
class UploaderController; def rescue_action(e) raise e end; end

class UploaderControllerTest < Test::Unit::TestCase
  def setup
    @controller = UploaderController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
