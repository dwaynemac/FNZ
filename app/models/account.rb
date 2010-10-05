class Account < ActiveRecord::Base

  validates_presence_of :currency
  validates_uniqueness_of :name, :scope => :institution_id

  after_save :set_as_default
  after_destroy :remove_from_institution_default

  validates_presence_of :institution
  belongs_to :institution

  has_many :transactions, :dependent => :destroy # all transactions

  has_many :credits, :class_name => "Transaction", :conditions => { :type => ["Income","CreditTransfer"]} # all credits
  has_many :incomes
  has_many :credit_transfers

  has_many :debits, :class_name => "Transaction", :conditions => { :type => ["Expense","DebitTransfer"]} # all debits
  has_many :expenses
  has_many :debit_transfers

  composed_of :saved_balance, :class_name => "Money", :mapping => [%w(cents cents), %w(currency currency)],
              :constructor => Proc.new { |cents, currency| Money.new(cents || 0, currency || Money.default_currency) }

  # printable string of balance
  def prt_balance
    b = self.balance
    return "#{'-' if b.cents<0}#{b.currency.symbol}#{b.abs.to_s}"
  end

  # returns balance
  def balance
    if self.saved_balance_on.nil?
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

  def transfer(user,to,cents,made_on=nil,description=nil)
    made_on = Time.zone.now if made_on.nil?
    debit = self.debit_transfers.build(:cents => cents, :user => user, :made_on => made_on, :description => description)
    credit_cents = Money.new(cents,self.currency).exchange_to(to.currency).cents
    credit = to.credit_transfers.build(:cents => credit_cents, :user => user, :made_on => made_on, :description => description)
    if credit.save
      if debit.save
        t = Transfer.new(:credit => credit, :debit => debit)
        if t.save
          return true
        else
          # rollback
          debit.destroy
          credit.destroy
        end
      else
        # rollback
        credit.destroy
      end
    end
    return false
  end

  private
  def set_as_default
    if self.institution.default_account.nil?
      self.institution.update_attribute(:default_account_id,self.id)
    end
  end

  def remove_from_institution_default
    if self.institution.default_account==self
      self.institution.update_attribute(:default_account_id,nil)
    end
  end
end
