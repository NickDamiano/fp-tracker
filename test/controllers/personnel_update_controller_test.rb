require 'test_helper'

class PersonnelUpdateControllerTest < ActionController::TestCase
  test "should get depart" do
    get :depart
    assert_response :success
  end

  test "should get arrive" do
    get :arrive
    assert_response :success
  end

end
