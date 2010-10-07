require 'test_helper'

class TransactionsControllerTest < ActionController::TestCase

  context "" do
    setup do
      @current_user = User.first
      @current_user.padma.stubs(:people).returns([{"id"=>1,"nombres"=>"name","apellidos"=>"surname"}])
      @institution = @current_user.institution || Institution.make(:user => @current_user)
      @account = @institution.accounts.first || Account.make(:institution => @institution)
      @transaction = Transaction.make(:account => @account)
    end
    context "post :create" do
      context "without scope" do
        context "with valid data" do
          setup do
            @person = Person.make
            post :create ,
                 :transaction => Transaction.plan(:account => @account, :currency => nil).merge(
                         {:concept_list => "tag_one, tag_two",
                          :person_id => @person.id})
          end

          should_change("Tranasction.count",:by => 1){Transaction.count}
          should "assign payment to @person" do
            assert_equal @person, Transaction.last.person
          end
          should_redirect_to("transactions"){transactions_url}
          should "add tags with ownership" do
            assert_equal ["tag_one", "tag_two"], Transaction.last.concepts_from(@institution)
          end
        end
        context "with INvalid data" do
          setup do
            @person = Person.make
            post :create,
                 :transaction => Transaction.plan(:account => nil, :currency => nil).merge({:person_id => @person.id})
          end
          should_not_change("Transaction.count"){Transaction.count}
          should_respond_with(:success)
        end
      end
      context "scoped to account_id" do
        setup do
          @person = Person.make
          post :create ,
               :account_id => @account.id,
               :transaction => Transaction.plan(:currency => nil).merge(
                       {:concept_list => "tag_one, tag_two",
                        :person_id => @person.id})
        end
        should_redirect_to("account"){account_url(@account)}
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

      should_assign_to(:accounts, :categories, :people)
    end
    context "get :index" do
      setup do
        @account = Account.make(:institution => @institution)
        @not_include = Transaction.make(:account => @account, :made_on => 2.months.ago)
        @include = Transaction.make(:account => @account, :made_on => 10.days.ago)
        get :index, :search => { :period_field => 'made_on', :since => I18n.l(1.month.ago.to_date), :until => I18n.l(1.month.from_now.to_date)}
      end
      should "consider period for balance calculation" do
        assert(assigns(:transactions).include?(@include))
        assert(!assigns(:transactions).include?(@not_include))
      end
      should_respond_with(:success)
      should_assign_to(:transactions)
    end
    context "get :show" do
      setup { get :show, :id => @transaction.id }
      should_respond_with(:success)
    end
    context "put :update" do
      context "with valid data" do
        setup { put :update, :id => @transaction.id, :transaction => Transaction.plan }
        should_redirect_to("transactions"){transactions_url}
      end
      context "with invalid data" do
        setup { put :update, :id => @transaction.id, :transaction => Transaction.plan(:account_id => nil) }
        should_respond_with(:success)
        should_render_a_form
        should_render_template(:edit)
        should_assign_to(:accounts, :categories, :people)
      end
    end
    context "delete :destroy" do
      setup { delete :destroy, :id => @transaction.id }
      should_change("Transaction.count", :by => -1){Transaction.count}
      should_redirect_to("transactions"){transactions_url}
    end
    context "delete :destroy_multiple" do
      setup { 10.times{Transaction.make} }
      context "" do
        setup do
          ids = Transaction.all(:limit => 3).map{|t| t.id }
          delete :destroy_multiple, :transaction_ids => ids
        end
        should_change("Transaction.count", :by => -3){Transaction.count}
      end
    end
    context "get :transfer" do
      setup do
        @account_a = Account.make(:institution => @institution, :currency => "ars")
        @account_b = Account.make(:institution => @institution, :currency => "ars")
      end
      context "with form data" do
        setup do 
          get :transfer, :transfer_form => {:from_account_id => @account_a.id,
                                            :to_account_id => @account_b.id,
                                            :amount => "10",
                                            :description => Faker::Lorem.sentence
          }
        end
        should_change("account A cents", :by => -1000){@account_a.calculate_balance.cents}
        should_change("account B cents", :by => 1000){@account_b.calculate_balance.cents}
        should_change("Transaction.count", :by => 2){Transaction.count}
        should_change("Transfer.count", :by => 1){Transfer.count}
        should_redirect_to("transactions"){accounts_url}
      end
      context "withou form data" do
        setup { get :transfer }
        should_respond_with(:success)
        should_assign_to(:transfer_form)
        should_assign_to(:accounts)
      end
    end
  end
end
