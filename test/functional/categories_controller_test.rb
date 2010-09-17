require 'test_helper'

class CategoriesControllerTest < ActionController::TestCase

  context "" do
    setup do
      @institution = User.find_or_create_by_drc_user("homer").institution
      @category = Category.make(:institution => @institution)
    end
    context "get :edit" do
      setup { get :edit, :id => @category.id }
      should_respond_with(:success)
      should_assign_to(:categories)
      should_assign_to(:category)
    end
    context "get :show" do
      setup { get :show, :id => @category.id }
      should_respond_with(:success)
      should_assign_to(:transactions)
    end
    context "get :index" do
      setup { get :index }
      should_respond_with(:success)
      should_assign_to(:roots)
    end

  end

  def setup
    @institution = User.find_or_create_by_drc_user("homer").institution
    @category = Category.make(:institution => @institution)
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create category" do
    assert_difference('Category.count') do
      post :create, :category => Category.plan
    end

    assert_redirected_to categories_url
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
