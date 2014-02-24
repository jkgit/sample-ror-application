require 'test_helper'

class WelcomeControllerTest < ActionController::TestCase
  # not including crud tests since crud is supplied by active scaffold
  setup do
    # need a user for devise authentication, and it needs to be in the users table
    @user = users(:one)
    @user.save
  end
  
  test "should get index" do
    # authenticate user via devise
    sign_in :user, @user
    get :index
    assert_response :success
  end
end
