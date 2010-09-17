require 'test_helper'

class CategoriesControllerTest < ActionController::TestCase

  def setup
    @institution = User.find_or_create_by_drc_user("homer").institution
    @category = Category.make(:institution => @institution)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:categories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create category" do
    assert_difference('Category.count') do
      post :create, :category => Category.plan
    end

    assert_redirected_to category_path(assigns(:category))
  end

  test "should show category" do
    get :show, :id => @category.id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @category.id
    assert_response :success
  end

  test "should update category" do
    put :update, :id => @category.id, :category => Category.plan
    assert_redirected_to category_path(assigns(:category))
  end

  test "should destroy category" do
    assert_difference('Category.count', -1) do
      delete :destroy, :id => @category.id
    end

    assert_redirected_to categories_path
  end
end
