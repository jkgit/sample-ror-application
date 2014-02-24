require 'test_helper'

class MerchantsControllerTest < ActionController::TestCase
  setup do
    @merchant = merchants(:one)
    
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

  test "should create merchant" do
    assert_difference('Merchant.count') do
      post :create, {"commit"=>"Create", record: { address: @merchant.address, name: @merchant.name }}
    end

    @merchant = assigns(:record)
    assert_not_nil @merchant
    assert_redirected_to merchants_path
  end

  test "should show merchant" do
    get :show, id: @merchant
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @merchant
    assert_response :success
  end

  test "should update merchant" do
    put :update, id: @merchant, record: { address: @merchant.address, name: @merchant.name }
    
    assert_not_nil(assigns(:record))
    assert_redirected_to merchants_path
  end

  test "should destroy merchant" do
    assert_difference('Merchant.count', -1) do
      delete :destroy, id: @merchant
    end

    assert_redirected_to merchants_path
  end
end
