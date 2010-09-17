# Modifications to acts-as-taggable-on Tag model
class Tag < ActiveRecord::Base

  def balance_for(institution,from=nil,to=nil)
    institution = Institution.find(institution) if institution.is_a?(Integer)
    bal = Money.new(0,institution.default_currency)
    incomes_by_cur = institution.incomes.tagged_with(self).made_before(to).made_after(from).calculate(:sum,:cents, :group => "#{Transaction.table_name}.currency")
    expenses_by_cur = institution.expenses.tagged_with(self).made_before(to).made_after(from).calculate(:sum,:cents, :group => "#{Transaction.table_name}.currency")
    incomes_by_cur.each{|ic| bal += Money.new(ic[1],ic[0])}
    expenses_by_cur.each{|ec| bal -= Money.new(ec[1],ec[0])}
    return bal
  end

end
