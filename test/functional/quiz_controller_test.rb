require File.dirname(__FILE__) + '/../test_helper'
require 'quiz_controller'

# Re-raise errors caught by the controller.
class QuizController; def rescue_action(e) raise e end; end

class QuizControllerTest < Test::Unit::TestCase
  def setup
    @controller = QuizController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
