require 'test_helper'

class TransactionsControllerTest < ActionController::TestCase

  context "" do
    setup do
      @current_user = User.first
      @current_user.padma.stubs(:people).returns([{"id"=>1,"nombres"=>"name","apellidos"=>"surname"}])
      @institution = Institution.first || Institution.make
      @account = @institution.accounts.first || Account.make(:institution => @institution)
      @transaction = Transaction.make(:account => @account)
    end
    context "post :create" do
      setup do
        @person = Person.make
        post :create , :transaction => Transaction.plan(:account => @account, :currency => nil).merge({:concept_list => "tag_one, tag_two", :person => { :padma_id => @person.padma_id}})
      end

      should_change("Tranasction.count",:by => 1){Transaction.count}
      should_change("@person.transactions.count", :by => 1){@person.transactions.count}
      should "assign payment to @person" do
        assert_equal @person, Transaction.last.person
      end
      should_redirect_to("transactions#show"){transaction_path(assigns(:transaction))}
      should "add tags with ownership" do
        assert_equal ["tag_one", "tag_two"], Transaction.last.concepts_from(@institution)
      end
    end
    context "get :new" do
      setup do
        get :new
      end

      should_respond_with(:success)
      should_render_a_form
      should_render_template(:new)

      # _form needs these
      should_assign_to(:accounts)
      should_assign_to(:categories)
    end
    context "get :edit" do
      setup do
        get :edit, :id => @transaction.id
      end
      should_respond_with(:success)
      should_render_a_form
      should_render_template(:edit)

      # _form needs these
      should_assign_to(:accounts)
      should_assign_to(:categories)
    end
    context "get :index" do
      setup { get :index }
      should "consider period for balance calculation" do
        assert(false, "write test")
      end
      should_respond_with(:success)
      should_assign_to(:transactions)
    end
    context "get :show" do
      setup { get :show, :id => @transaction.id }
      should_respond_with(:success)
    end
    context "put :update" do
      setup { put :update, :id => @transaction.id, :transaction => Transaction.plan }
      should_redirect_to("transaction"){transaction_path(assigns(:transaction))}
    end
    context "delete :destroy" do
      setup { delete :destroy, :id => @transaction.id }
      should_change("Transaction.count", :by => -1){Transaction.count}
      should_redirect_to("transactions"){transactions_url}
    end
  end
end
