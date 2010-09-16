require 'test_helper'

class TransactionsControllerTest < ActionController::TestCase

  def setup
    @transaction = Transaction.make
  end

  context "" do
    setup do
      @institution = Institution.first
      @account = Account.make(:institution => @institution)
      @transaction = Transaction.make(:account => @account)
    end
    context "create" do
      setup do
        post :create , :transaction => Transaction.plan(:account => @account, :currency => nil).merge({:concept_list => "tag_one, tag_two"})
      end

      should_change("Tranasction.count",:by => 1){Transaction.count}
      should_redirect_to("transactions#show"){transaction_path(assigns(:transaction))}
      should "add tags with ownership" do
        assert_equal ["tag_one", "tag_two"], Transaction.last.concepts_from(@institution)
      end
    end
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:transactions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should show transaction" do
    get :show, :id => @transaction.id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @transaction.id
    assert_response :success
  end

  test "should update transaction" do
    put :update, :id => @transaction.id, :transaction => Transaction.plan
    assert_redirected_to transaction_path(assigns(:transaction))
  end

  test "should destroy transaction" do
    assert_difference('Transaction.count', -1) do
      delete :destroy, :id => @transaction.id
    end

    assert_redirected_to transactions_path
  end
end
