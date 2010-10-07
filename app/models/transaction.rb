class Transaction < ActiveRecord::Base

  after_save :recalculate_account_balance
  after_destroy :recalculate_account_balance

  named_scope :field_on_month, lambda{|field, month_date|{:conditions => { field.to_sym => (month_date.beginning_of_month...month_date.end_of_month)}}}
  named_scope :field_on_year, lambda{|field, year_date|{:conditions => ["YEAR(#{field})=:year",{:year => year_date.year}]}}
  named_scope :field_after, lambda{|field, time| time.nil?? {} : {:conditions => ["#{field} >= ?",time]}}
  named_scope :field_before, lambda{|field, time| time.nil?? {} : {:conditions => ["#{field} <= ?",time]}}

  # Scopes
  def self.made_on_month(month_date)
    logger.warn('DEPRECATED METHOD: Transaction.made_on_month is deprecated, use Transaction.field_on_month(:made_on)')
    self.field_on_month(:made_on,month_date)
  end
  def self.made_on_year(year_date)
    logger.warn('DEPRECATED METHOD: Transaction.made_on_year is deprecated, use Transaction.field_on_year(:made_on)')
    self.field_on_year(:made_on,year_date)
  end
  def self.made_after(time)
    logger.warn('DEPRECATED METHOD: Transaction.made_after is deprecated, use Transaction.field_after(:made_on)')
    self.field_after(:made_on,time)
  end
  def self.made_before(time)
    logger.warn('DEPRECATED METHOD: Transaction.made_before is deprecated, use Transaction.field_before(:made_on)')
    self.field_before(:made_on,time)
  end

  validates_presence_of :made_on
  validates_presence_of :account_on
  before_validation :default_account_on

  belongs_to :user
  validates_presence_of :user

  # optional, if payer needs to be identified.
  belongs_to :person

  belongs_to :account
  validates_presence_of :account

  belongs_to :category
  acts_as_taggable_on :concepts

  named_scope :in_category_tree, lambda{|root_category| {:conditions => { :category_id => root_category.self_and_descendants }} }

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
    return if arg.nil?
    self.cents = arg.to_money.cents.abs
  end

  # prints amount
  def prt_amount
    string = (self.debit?)? "-" : ""
    string += "<span title='#{self.amount.currency}'>#{self.amount.currency.symbol}</span>"
    string += self.amount.to_s
    return string
  end

  def set_concept_list(string)
    logger.error "Transaction#set_concept_list shouldn't be called on unsaved models" if self.account.nil?
    self.account.institution.tag(self,:with => string, :on => :concepts)
  end

  private
  def default_account_on
    self.account_on = self.made_on if self.account_on.nil?
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
