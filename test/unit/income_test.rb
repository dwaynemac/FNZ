require 'test_helper'

class IncomeTest < ActiveSupport::TestCase

  context "for income" do
    setup do
      @income = Transaction.make(:type => "Income", :cents => 100, :currency => "ars" )
    end
    should "return .credit? true" do
      assert(@income.credit?)
    end
    should "return .debit? false" do
      assert(!@income.debit?)
    end
    should "return .prt_amount '$1.00'" do
      assert_equal("$1.00",@income.prt_amount)
    end
  end
end
