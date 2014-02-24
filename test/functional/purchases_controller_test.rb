require 'test_helper'

class PurchasesControllerTest < ActionController::TestCase
  # not including crud tests since crud is supplied by active scaffold
  setup do
    @purchase = purchases(:one)
    
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

  test "should get new" do
    # authenticate user via devise
    sign_in :user, @user
    get :new
    assert_response :success
  end
  
  test "should import data" do
    # authenticate user via devise
    sign_in :user, @user
    aFile=fixture_file_upload('files/example_input.tab')
    post :do_import, attachment:aFile
    assert_response :redirect
  end
  
end
