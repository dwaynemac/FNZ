require 'test_helper'

class AccountsControllerTest < ActionController::TestCase

  def setup
    @account = Account.make
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:accounts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create account" do
    assert_difference('Account.count') do
      post :create, :account => Account.plan
    end

    assert_redirected_to accounts_path
  end

  test "should show account" do
    get :show, :id => @account.id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @account.id
    assert_response :success
  end

  test "should update account" do
    put :update, :id => @account.id, :account => Account.plan
    assert_redirected_to account_path(assigns(:account))
  end

  test "should destroy account" do
    assert_difference('Account.count', -1) do
      delete :destroy, :id => @account.id
    end

    assert_redirected_to accounts_path
  end
end
