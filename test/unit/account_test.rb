require 'test_helper'

class AccountTest < ActiveSupport::TestCase

  should_belong_to :school
  should_have_many :transactions
  should_have_many :incomes
  should_have_many :expenses

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
      assert_equal Money.new(50,@positive.currency), @positive.calculate_balance
      Transaction.make(:type => "Income", :cents => 10, :account => @positive)
      assert_equal Money.new(50,@positive.currency), @positive.balance
      assert_equal Money.new(60,@positive.currency), @positive.calculate_balance
      @positive.reload
      assert_equal Money.new(60,@positive.currency), @positive.balance
    end

  end

end
