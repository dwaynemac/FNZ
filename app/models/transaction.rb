class Transaction < ActiveRecord::Base

  before_save :get_currency_from_account
  after_save :recalculate_account_balance

  named_scope :incomes, :conditions => { :type => "Income" }
  named_scope :expenses, :conditions => { :type => "Expense" }

  validates_presence_of :account
  validates_presence_of :made_on

  belongs_to :user
  belongs_to :account

  acts_as_taggable_on :concepts

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
