require 'test_helper'

class AccountTest < ActiveSupport::TestCase

  should_belong_to :school
  should_have_many :transactions
  should_have_many :incomes
  should_have_many :expenses

  context "Account with many transactions" do
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
    should "return balance with account#balance" do
      assert_equal(50,@positive.balance)
      assert_equal(-50,@negative.balance)
      assert_equal(0,@zero.balance)
    end
  end

end
