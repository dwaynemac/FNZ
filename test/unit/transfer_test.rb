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
      should "debit from @from" do
         assert_equal 60, @from.cents
      end
      should "credit to @to" do
        assert_equal 140, @to.cents
      end
    end
  end

end