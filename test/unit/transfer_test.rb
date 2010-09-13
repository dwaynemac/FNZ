require File.dirname(__FILE__)+'/../test_helper'

class TransferTest < ActiveSupport::TestCase

  context "for same currency accounts" do
    setup do
      @user = User.make
      @from = Account.make(:currency => "ars")
      Transaction.make(:account => @from, :cents => 100, :type => "CreditTransfer")
      @to = Account.make(:currency => "ars")
      Transaction.make(:account => @to, :cents => 100, :type => "CreditTransfer")
    end
    context "transfer" do
      setup do
        @from.transfer(@user,@to,40)
        @from.reload
        @to.reload
      end
      should_change("general number of transactions",:by => 2){Transaction.count}
      should_change("create a DebitTransfer", :by => 1){@from.debit_transfers.count}
      should_change("create a CreditTransfer", :by => 1){@to.credit_transfers.count}
      should_change("create a Transfer", :by => 1){Transfer.count}
      should "link debit and credit" do
        assert_equal @to.credit_transfers.last.debit, @from.debit_transfers.last
        assert_equal @from.debit_transfers.last.credit, @to.credit_transfers.last
        assert_equal Transfer.last.credit, @to.credit_transfers.last
        assert_equal Transfer.last.debit, @from.debit_transfers.last
      end
      should "debit from @from" do
         assert_equal 60, @from.cents
      end
      should "credit to @to" do
        assert_equal 140, @to.cents
      end
      context ". Destroying credit" do
        setup do
          @credit = CreditTransfer.last
          @credit.destroy
          @from.reload
          @to.reload
        end
        should_change("DebitTransfer.count",:by => -1){DebitTransfer.count}
        should "restore account balance" do
          assert_equal 100, @from.cents
          assert_equal 100, @to.cents
        end
      end
      context ". Destroying debit" do
        setup do
          @debit = DebitTransfer.last
          @debit.destroy
          @from.reload
          @to.reload
        end
        should_change("CreditTransfer.count",:by => -1){CreditTransfer.count}
        should "restore account balance" do
          assert_equal 100, @from.cents
          assert_equal 100, @to.cents
        end
      end
      context ". Destroying tranfer" do
        setup do
          @transfer = Transfer.last
          @transfer.destroy
          @from.reload
          @to.reload
        end
        should_change("DebitTransfer.count",:by => -1){DebitTransfer.count}
        should_change("CreditTransfer.count",:by => -1){CreditTransfer.count}
        should "restore account balance" do
          assert_equal 100, @from.cents
          assert_equal 100, @to.cents
        end
      end
    end
  end

  context "for different currency accounts" do
    setup do
      # override exchange rate for testing.
      Money.add_rate("usd","ars",3.9)
      @user = User.make
      @from = Account.make(:currency => "usd")
      Transaction.make(:account => @from, :cents => 100, :type => "CreditTransfer")
      @to = Account.make(:currency => "ars")
      Transaction.make(:account => @to, :cents => 100, :type => "CreditTransfer")
    end
    context "transfer" do
      setup do
        @from.transfer(@user,@to,40)
        @from.reload
        @to.reload
      end
      should_change("general number of transactions",:by => 2){Transaction.count}
      should_change("create a DebitTransfer", :by => 1){@from.debit_transfers.count}
      should_change("create a CreditTransfer", :by => 1){@to.credit_transfers.count}
      should "debit from @from" do
         assert_equal 60, @from.cents
      end
      should "credit to @to" do
        assert_equal 256, @to.cents
      end
    end
  end

end
