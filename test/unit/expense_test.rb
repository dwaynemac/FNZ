require 'test_helper'

class ExpenseTest < ActiveSupport::TestCase
  context "for expense" do
    setup do
      @expense = Transaction.make(:type => "Expense", :cents => 100, :currency => "ars")
    end
    should "return .credit? false" do
      assert(!@expense.credit?)
    end
    should "return .debit? true" do
      assert(@expense.debit?)
    end
    should "return .prt_amount '-$1.00'" do
      answer = "-"
      answer += "<span title='#{@expense.amount.currency}'>#{@expense.amount.currency.symbol}</span>"
      answer += @expense.amount.to_s
      assert_equal(answer,@expense.prt_amount)
    end
  end
end

