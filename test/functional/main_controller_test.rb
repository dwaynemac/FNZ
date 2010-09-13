require 'test_helper'

class MainControllerTest < ActionController::TestCase

  context "get :index" do
    setup do
      get :index
    end
    should_respond_with(:success)
  end

  context "get :welcome" do
    setup do
      get :welcome
    end
    should_respond_with(:success)
  end
end
