require 'test_helper'

class ConceptsControllerTest < ActionController::TestCase

  context "get :index" do
    setup do
      get :index
    end
    should_respond_with(:success)
  end

  context "get :show" do
    setup do
      get :show, :id => Tag.make.name
    end
    should_respond_with(:success)
  end


end
