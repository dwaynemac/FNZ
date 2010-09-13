class Account < ActiveRecord::Base

  after_save :set_as_default_if_needed

  belongs_to :school

  has_many :transactions # all transactions

  has_many :credits, :class_name => "Transaction", :conditions => { :type => ["Income","CreditTransfer"]} # all credits
  has_many :incomes
  has_many :credit_transfers

  has_many :debits, :class_name => "Transaction", :conditions => { :type => ["Expense","DebitTransfer"]} # all debits
  has_many :expenses
  has_many :debit_transfers

  composed_of :saved_balance, :class_name => "Money", :mapping => [%w(cents cents), %w(currency currency)],
              :constructor => Proc.new { |cents, currency| Money.new(cents || 0, currency || Money.default_currency) }

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
      bal = self.credits.calculate(:sum,:cents) - self.debits.calculate(:sum,:cents)
      self.update_attributes(:cents => bal, :saved_balance_on => Time.zone.now)
    else
      before_balance_date = {:conditions => ["made_on < ?",at]}
      bal = self.credits.calculate(:sum,:cents,before_balance_date) - self.debits.calculate(:sum,:cents,before_balance_date)
    end
    return Money.new(bal,self.currency)
  end

  def transfer(user,to,cents,made_on=nil)
    made_on = Time.zone.now if made_on.nil?
    debit = self.debit_transfers.build(:cents => cents, :user => user, :made_on => made_on)
    credit = to.credit_transfers.build(:cents => cents, :user => user, :made_on => made_on)
    credit.debits << debit
    return credit.save
  end

  private
  def set_as_default_if_needed
    if self.school.default_account.nil?
      self.school.update_attribute(:default_account_id,self.id)
    end
  end
end
