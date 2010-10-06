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

  # returns balance of transactions with <tt>consider</tt> between <tt>from</tt> and <tt>to</tt>.
  # Valid options:
  # - :from
  # - :to
  # - :consider :  'made_on' or 'account_on', defaults to 'made_on'
  # - :group_by : field of transaction by which you wish to group subtotals
  def balance(options = {})
    consider = options[:consider] || :made_on

    from = options[:from]
    to = options[:to]
    period_scope = self.transactions.field_before(consider.to_sym, to).field_after(consider.to_sym, from)

    group_by = options[:group_by]
    if group_by.nil?
      bal = Money.new(0,self.institution.default_currency)

      # first consider transactions directly under this category

      # sum in DB transactions for each currency
      incomes_by_cur = period_scope.incomes.calculate(:sum,:cents, :group => "#{Transaction.table_name}.currency")
      expenses_by_cur = period_scope.expenses.calculate(:sum,:cents, :group => "#{Transaction.table_name}.currency")

      # sum here subtotals of each currency for conversion
      incomes_by_cur.each{|ic| bal += Money.new(ic[1],ic[0])}
      expenses_by_cur.each{|ec| bal -= Money.new(ec[1],ec[0])}

      # then consider transactions under child categories
      self.children.each{|c| bal += c.balance(:from => from,:to => to) }

      return bal
    else
      incomes_groups = period_scope.incomes.all(
                                :select => "#{Transaction.table_name}.currency, #{Transaction.table_name}.#{group_by}, sum(cents) as sum_cents",
                                :group => "#{Transaction.table_name}.currency, #{Transaction.table_name}.#{group_by}")
      expenses_groups = period_scope.expenses.all(
                                :select => "#{Transaction.table_name}.currency, #{Transaction.table_name}.#{group_by}, sum(cents) as sum_cents",
                                :group => "#{Transaction.table_name}.currency, #{Transaction.table_name}.#{group_by}")

      return_groups = {}
      incomes_groups.each do |ig|
        if return_groups[ig.send(group_by)].nil?
          return_groups[ig.send(group_by)] = Money.new(0, self.institution.default_currency)
        end
        return_groups[ig.send(group_by)] += Money.new(ig.sum_cents.to_i,ig.currency)
      end
      expenses_groups.each do |eg|
        if return_groups[eg.send(group_by)].nil?
          return_groups[eg.send(group_by)] = Money.new(0, self.institution.default_currency)
        end
        return_groups[eg.send(group_by)] -= Money.new(eg.sum_cents,eg.currency)
      end

      return return_groups
    end
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
