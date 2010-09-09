class Account < ActiveRecord::Base
  belongs_to :school
  has_many :transactions
  has_many :incomes
  has_many :expenses

  composed_of :saved_balance, :class_name => "Money", :mapping => [%w(cents cents), %w(currency currency)]

  # returns balance
  def balance
    if self.saved_balance.nil?
      return self.calculate_balance
    else
      return self.saved_balance
    end
  end

  # returns balance at a given moment
  # if no moment specified defaults to total balance and caches it on self.balance
  def calculate_balance(at=nil)
    if at.nil?
      bal = self.incomes.calculate(:sum,:cents) - self.expenses.calculate(:sum,:cents)
      self.update_attributes(:cents => bal, :saved_balance_on => Time.zone.now)
    else
      before_balance_date = {:conditions => ["made_on < ?",at]}
      bal = self.incomes.calculate(:sum,:cents,before_balance_date) - self.expenses.calculate(:sum,:cents,before_balance_date)
    end
    return Money.new(bal,self.currency)
  end
end
