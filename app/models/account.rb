class Account < ActiveRecord::Base
  belongs_to :school
  has_many :transactions
  has_many :incomes
  has_many :expenses

  composed_of :total, :class_name => "Money", :mapping => [%w(cents cents), %w(currency currency)]


  # returns balance at a given moment
  # defaults to total balance
  def balance(at=nil)
    if at.nil?
      bal = self.incomes.calculate(:sum,:cents) - self.expenses.calculate(:sum,:cents)
    else
      before_balance_date = {:conditions => ["made_on < ?",at]}
      bal = self.incomes.calculate(:sum,:cents,before_balance_date) - self.expenses.calculate(:sum,:cents,before_balance_date)
    end
    return bal
  end
end
