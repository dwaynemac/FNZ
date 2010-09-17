class Category < ActiveRecord::Base

  extend ActiveSupport::Memoizable

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

  def balance(from=nil,to=nil)
    bal = Money.new(0,self.institution.default_currency)

    # check direct transactions
    incomes_by_cur = self.transactions.incomes.made_before(to).made_after(from).calculate(:sum,:cents, :group => "#{Transaction.table_name}.currency")
    expenses_by_cur = self.transactions.expenses.made_before(to).made_after(from).calculate(:sum,:cents, :group => "#{Transaction.table_name}.currency")

    incomes_by_cur.each{|ic| bal += Money.new(ic[1],ic[0])}
    expenses_by_cur.each{|ec| bal -= Money.new(ec[1],ec[0])}

    # check child categories
    self.children.each{|c| bal += c.balance(from,to) }

    return bal
  end
  memoize :balance

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
