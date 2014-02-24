require 'test_helper'

class PurchasesControllerTest < ActionController::TestCase
  # not including crud tests since crud is supplied by active scaffold
  setup do
    @purchase = purchases(:one)
    
    # need a user for devise authentication, and it needs to be in the users table
    @user = users(:one)
    @user.save
    
    # authenticate user via devise
    sign_in :user, @user
  end
  
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end
  
  test "should import data" do
    aFile=fixture_file_upload('files/example_input.tab')
    post :do_import, attachment:aFile
    assert_response :redirect
  end
  
end
