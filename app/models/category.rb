class Category < ActiveRecord::Base
  acts_as_tree

  validates_presence_of :name

  belongs_to :institution
  validates_presence_of :institution

  has_many :transactions

  composed_of :saved_balance, :class_name => "Money", :mapping => [%w(cents cents), %w(currency currency)],
            :constructor => Proc.new { |cents, currency| Money.new(cents || 0, currency || Money.default_currency) }

  # returns balance
  def balance
    if self.cents.nil?
      return self.calculate_balance
    else
      return self.saved_balance
    end
  end

  # returns balance at a given moment
  # if no moment specified defaults to total balance and caches it on self.balance
  def calculate_balance(at=nil)
    bal = Money.new(0,self.institution.default_currency)
    if at.nil?
      # consider self and descendants
      incomes_by_cur = Income.in_category_tree(self).calculate(:sum,:cents, :group => "#{Transaction.table_name}.currency")
      expenses_by_cur = Expense.expenses.in_category_tree(self).calculate(:sum,:cents, :group => "#{Transaction.table_name}.currency")
      incomes_by_cur.each{|ic| bal += Money.new(ic[1],ic[0])}
      expenses_by_cur.each{|ec| bal -= Money.new(ec[1],ec[0])}
      self.update_attributes(:cents => bal.cents, :currency => bal.currency.iso_code)
    else
      before_balance_date = {:conditions => ["made_on < ?",at], :group => "#{Transaction.table_name}.currency"}
      incomes_by_cur = Income.in_category_tree(self).calculate(:sum,:cents,before_balance_date)
      expenses_by_cur = Expense.in_category_tree(self).calculate(:sum,:cents,before_balance_date)
      incomes_by_cur.each{|ic| bal += Money.new(ic[1],ic[0])}
      expenses_by_cur.each{|ec| bal -= Money.new(ec[1],ec[0])}
    end
    return bal
  end

end
