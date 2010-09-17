class Category < ActiveRecord::Base
  acts_as_tree

  before_save :capitalize_name

  validate :parent_is_not_descendant

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :institution_id

  belongs_to :institution
  validates_presence_of :institution

  has_many :transactions

  def all_transactions
    Transaction.in_category_tree(self)
  end

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
  def calculate_balance(from=nil,to=nil)

    # TODO go through child categories for better performance

    bal = Money.new(0,self.institution.default_currency)
    # consider self and descendants
    incomes_by_cur = Income.in_category_tree(self).search(:made_after => from, :made_befor => to).calculate(:sum,:cents, :group => "#{Transaction.table_name}.currency")
    expenses_by_cur = Expense.expenses.in_category_tree(self).search(:made_after => from, :made_befor => to).calculate(:sum,:cents, :group => "#{Transaction.table_name}.currency")
    incomes_by_cur.each{|ic| bal += Money.new(ic[1],ic[0])}
    expenses_by_cur.each{|ec| bal -= Money.new(ec[1],ec[0])}
    return bal
  end

  private
  def capitalize_name
    return if self.name.nil?
    self.name.capitalize!
  end

  def parent_is_not_descendant
    return if self.parent.nil?
    if self.self_and_descendants.include?(self.parent)
      self.errors.add(:parent_id, I18n.t('category.parent_cant_be_descendant'))
    end
  end

end
