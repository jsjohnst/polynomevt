require 'test_helper'

class JobsGenerateTest < ActionController::IntegrationTest
  fixtures :jobs
   
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
  
  def test_generate_discretization_only
    get '/'
    assert_response :success
    post '/jobs/generate', :job => {
      :show_discretized => true
    }
    assert_response :success
    end
end
