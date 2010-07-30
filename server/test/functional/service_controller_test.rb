require 'test_helper'

class ServiceControllerTest < ActionController::TestCase
  test "should get connect" do
    get :connect
    assert_response :success
  end

end
