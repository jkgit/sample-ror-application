require 'test_helper'

class PurchasersControllerTest < ActionController::TestCase
  setup do
    @purchaser = purchasers(:one)
    
    # need a user for devise authentication, and it needs to be in the users table
    @user = users(:one)
    @user.save
    
    # authenticate user via devise
    sign_in :user, @user
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:records)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create purchaser" do
    assert_difference('Purchaser.count') do
      post :create, {"commit"=>"Create", record: { name: @purchaser.name }}
    end

    @purchaser = assigns(:record)
    assert_not_nil @purchaser
    assert_redirected_to purchasers_path
  end

  test "should show purchaser" do
    get :show, id: @purchaser
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @purchaser
    assert_response :success
  end

  test "should update purchaser" do
    put :update, id: @purchaser, record: { name: @purchaser.name }
    assert_not_nil(assigns(:record))
    assert_redirected_to purchasers_path
  end

  test "should destroy purchaser" do
    assert_difference('Purchaser.count', -1) do
      delete :destroy, id: @purchaser
    end

    assert_redirected_to purchasers_path
  end
end
