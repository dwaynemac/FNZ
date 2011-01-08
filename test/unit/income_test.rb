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
      answer = "-"
      answer += "<span title='#{@income.amount.currency}'>#{@income.amount.currency.symbol}</span>"
      answer += @income.amount.to_s
      assert_equal("$1.00",@income.prt_amount)
    end
  end
end

