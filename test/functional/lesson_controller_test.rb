require File.dirname(__FILE__) + '/../test_helper'
require 'lesson_controller'

# Re-raise errors caught by the controller.
class LessonController; def rescue_action(e) raise e end; end

class LessonControllerTest < Test::Unit::TestCase
  def setup
    @controller = LessonController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
