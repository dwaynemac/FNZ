require 'test_helper'

class ImportsControllerTest < ActionController::TestCase

  def setup
    @import = Import.make
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:imports)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create import" do
    assert_difference('Import.count') do
      post :create, :import => Import.plan
    end

    assert_redirected_to import_path(assigns(:import))
  end

  test "should show import" do
    get :show, :id => @import.id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @import.id
    assert_response :success
  end

  test "should update import" do
    put :update, :id => @import.id, :import => Import.plan
    assert_redirected_to import_path(assigns(:import))
  end

  test "should destroy import" do
    assert_difference('Import.count', -1) do
      delete :destroy, :id => @import.id
    end

    assert_redirected_to imports_path
  end
end
