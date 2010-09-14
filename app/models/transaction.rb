class Transaction < ActiveRecord::Base

  before_save :get_currency_from_account
  after_save :recalculate_account_balance
  after_destroy :recalculate_account_balance

  named_scope :made_on_month, lambda{|month_date|{:conditions => { :made_on => (month_date.beginning_of_month...month_date.end_of_month)}}}
  named_scope :made_on_year, lambda{|year_date|{:conditions => { :made_on => (year_date.beginning_of_year...year_date.end_of_year)}}}

  named_scope :credits, :conditions => { :type => ["Income","CreditTransfer"]}
  named_scope :credit_transfer, :conditions => { :type => "CreditTransfer" }
  named_scope :incomes, :conditions => { :type => "Income" }

  named_scope :debits, :conditions => { :type => ["Expense","DebitTransfer"]}
  named_scope :debit_transfer, :conditions => { :type => "DebitTransfer" }
  named_scope :expenses, :conditions => { :type => "Expense" }

  validates_presence_of :made_on

  belongs_to :user
  validates_presence_of :user

  belongs_to :account
  validates_presence_of :account

  # Searchlogic scopes
#  named_scope :ascend_by_made_on, :order => 'made_on asc'
#  named_scope :descend_by_made_on, :order => 'made_on desc'
#  named_scope :ascend_by_cents, :order => 'cents asc'
#  named_scope :descend_by_cents, :order => 'cents desc'


  # if imported from file transaction is linked to a row in such a file
  has_one :imported_row, :dependent => :destroy

  acts_as_taggable_on :concepts

  validates_presence_of :cents
  validates_numericality_of(:cents, :only_integer => true, :less_than => 90000000, :greater_than => -90000000)
  composed_of :amount, :class_name => "Money", :mapping => [%w(cents cents), %w(currency currency)],
              :constructor => Proc.new { |cents, currency| Money.new(cents || 0, currency || Money.default_currency) }


  def amount=(arg)
    self.cents = arg.to_money.cents
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
