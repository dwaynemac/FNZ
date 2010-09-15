require 'test_helper'

class AccountTest < ActiveSupport::TestCase

  should_validate_presence_of(:institution)
  should_belong_to :institution
  should_have_many :transactions
  should_have_many :incomes
  should_have_many :expenses

  should_validate_uniqueness_of :name, :scoped_to => :institution_id

  context "if institution doesnt have default account" do
    setup do
      @institution = Institution.make
    end
    context "on create" do
      setup do
        @account = Account.make_unsaved(:institution => @institution)
        @account.save
        @institution.reload
      end
      should "be seted as default" do
        assert_equal @account, @institution.default_account
      end
    end
  end
  context "if institution has default account" do
    setup do
      @default_account = Account.make
      @institution = Institution.make(:default_account => @default_account)
    end
    context "on create" do
      setup do
        @account = Account.make_unsaved(:institution => @institution)
        @account.save
      end
      should "not change institutions default account" do
        assert_equal @default_account, @institution.default_account
      end
    end
    context "on destroy (of default account)" do
      setup do
        @default_account.destroy
        @institution.reload
      end
      should "nullify institution#default_account" do
        assert_nil(@institution.default_account)
      end
    end
  end

  context "account#calculate_balance" do
    setup do
      @positive = Account.make
      Transaction.make(:type => "Income", :cents => 100, :account => @positive)
      5.times{Transaction.make(:type => "Expense", :cents => 10, :account => @positive)}

      @negative = Account.make
      Transaction.make(:type => "Income", :cents => 100, :account => @negative)
      5.times{Transaction.make(:type => "Expense", :cents => 30, :account => @negative)}

      @zero = Account.make
      Transaction.make(:type => "Income", :cents => 100, :account => @zero)
      5.times{Transaction.make(:type => "Expense", :cents => 20, :account => @zero)}
    end
    should "should return balance" do
      assert_equal(Money.new(50,@positive.currency),@positive.calculate_balance)
      assert_equal(Money.new(-50,@negative.currency),@negative.calculate_balance)
      assert_equal(Money.new(0,@zero.currency),@zero.calculate_balance)
    end
    should "save it on account#balance" do
      @positive.update_attribute(:cents,0)
      assert_equal Money.new(0,@positive.currency), @positive.balance
      assert_equal Money.new(50,@positive.currency), @positive.calculate_balance
      @positive.reload
      assert_equal Money.new(50,@positive.currency), @positive.balance
    end

  end

end
