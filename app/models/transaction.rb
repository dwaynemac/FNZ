class Transaction < ActiveRecord::Base

  before_save :get_currency_from_account

  validates_presence_of :made_on

  belongs_to :user
  belongs_to :account

  acts_as_taggable_on :concepts

  composed_of :amount, :class_name => "Money", :mapping => [%w(cents cents), %w(currency currency)]
  private
  def get_currency_from_account
    return if account.nil?
    self.currency = self.account.currency
  end

end
