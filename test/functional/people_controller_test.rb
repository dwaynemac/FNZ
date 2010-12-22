require 'test_helper'
require 'mocha'

class PeopleControllerTest < ActionController::TestCase

  context "" do
    setup do
      @user = User.find_by_drc_user("homer") || User.make(:drc_user => "homer")
      if @user.padma.nil?
        @user.padma = PadmaToken.make(:user => @user)
        @user.save
      end
      @user.update_attribute(:institution_id, Institution.make.id)
      @institution = @user.institution
      @person = Person.make(:institution => @institution)
    end
    context "get :index" do
      setup do
        @current_user = @user
        @current_user.stubs(:padma).stubs(:people).returns([{"nombres" => "pepe", "apellidos" => "london", "id" => 1},{"nombres" => "maria", "apellidos" => "josefa", "id" => 2}])
        get :index
      end
      should_respond_with(:success)
      should_assign_to(:people)
    end
    context "post :create" do
      setup { post :create, :person => Person.plan }
      should_redirect_to("person"){person_url(assigns(:person))}
      should_change("person#count", :by => 1){ Person.count }
    end
    context "get :new" do
      setup { get :new }
      should_respond_with(:success)
    end
    context "get :show" do
      setup { get :show, :id => @person.id }
      should_respond_with(:success)
    end
    context "get :edit" do
      setup { get :edit, :id => @person.id }
      should_respond_with(:success)
    end
    context "put :update" do
      setup { put :update, :id => @person.id, :person => Person.plan }
      should_redirect_to("person"){person_path(assigns(:person))}
    end
    context "delete :destroy" do
      setup { delete :destroy, :id => @person.id }
      should_change('Person.count', :by => -1){Person.count}
      should_redirect_to("personas"){people_url}
    end
  end
end

