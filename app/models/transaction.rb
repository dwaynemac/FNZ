class Transaction < ActiveRecord::Base

  after_save :recalculate_account_balance
  after_destroy :recalculate_account_balance

  named_scope :made_on_month, lambda{|month_date|{:conditions => { :made_on => (month_date.beginning_of_month...month_date.end_of_month)}}}
  named_scope :made_on_year, lambda{|year_date|{:conditions => { :made_on => (year_date.beginning_of_year...year_date.end_of_year)}}}

  validates_presence_of :made_on

  belongs_to :user
  validates_presence_of :user

  belongs_to :account
  validates_presence_of :account


  named_scope :credits, :conditions => { :type => ["Income","CreditTransfer"]}
  named_scope :credit_transfer, :conditions => { :type => "CreditTransfer" }
  named_scope :incomes, :conditions => { :type => "Income" }

  named_scope :debits, :conditions => { :type => ["Expense","DebitTransfer"]}
  named_scope :debit_transfer, :conditions => { :type => "DebitTransfer" }
  named_scope :expenses, :conditions => { :type => "Expense" }

  def credit?
    return self.type == "Income" || self.type == "CreditTransfer"
  end

  def debit?
    return self.type == "Expense" || self.type == "DebitTransfer"
  end


  # if imported from file transaction is linked to a row in such a file
  has_one :imported_row, :dependent => :destroy

  composed_of :amount, :class_name => "Money", :mapping => [%w(cents cents), %w(currency currency)],
              :constructor => Proc.new { |cents, currency| Money.new(cents || 0, currency || Money.default_currency) }

  validates_presence_of :cents
  validates_numericality_of(:cents, :only_integer => true, :less_than => 90000000, :greater_than_or_equal_to => 0)
  before_save :get_currency_from_account

  def amount=(arg)
    self.cents = arg.to_money.cents
  end
  
  def prt_amount
    string = (self.debit?)? "-" : ""
    string += self.amount.currency.symbol
    string += self.amount.to_s
    return string
  end

  acts_as_taggable_on :concepts

  def set_concept_list(string)
    logger.error "Transaction#set_concept_list shouldnt be called on unsaved models" if self.account.nil?
    self.account.institution.tag(self,:with => string, :on => :concepts)
  end

  private
  def get_currency_from_account
    return if account.nil?
    self.currency = self.account.currency
  end

  def recalculate_account_balance
    self.account.calculate_balance
  end

end
