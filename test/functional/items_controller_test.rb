require 'test_helper'

class ItemsControllerTest < ActionController::TestCase
  setup do
    @item = items(:one)
    
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

  test "should create item" do
    assert_difference('Item.count') do
      post :create, {"commit"=>"Create", record: { description: @item.description, price: @item.price }}
    end

    @item = assigns(:record)
    assert_not_nil @item
    assert_redirected_to items_path
  end

  test "should show item" do
    get :show, id: @item
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @item
    assert_response :success
  end

  test "should update item" do
    put :update, id: @item, record: { description: @item.description, price: @item.price }
    
    assert_not_nil(assigns(:record))
    assert_redirected_to items_path
  end

  test "should destroy item" do
    assert_difference('Item.count', -1) do
      delete :destroy, id: @item
    end

    assert_redirected_to items_path
  end
end
