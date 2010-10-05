# Modifications to acts-as-taggable-on Tag model
class Tag < ActiveRecord::Base

  extend ActiveSupport::Memoizable

  def balance_for(institution,from=nil,to=nil, consider = :made_on)
    institution = Institution.find(institution) if institution.is_a?(Integer)
    bal = Money.new(0,institution.default_currency)
    incomes_by_cur = institution.incomes.tagged_with(self).field_before(consider, to).field_after(consider, from).calculate(:sum,:cents, :group => "#{Transaction.table_name}.currency")
    expenses_by_cur = institution.expenses.tagged_with(self).field_before(consider, to).field_after(consider, from).calculate(:sum,:cents, :group => "#{Transaction.table_name}.currency")
    incomes_by_cur.each{|ic| bal += Money.new(ic[1],ic[0])}
    expenses_by_cur.each{|ec| bal -= Money.new(ec[1],ec[0])}
    return bal
  end
  memoize :balance_for

  def self.for_institution(institution)
    self.all(:joins => :taggings,
             :conditions => { :taggings => { :tagger_id => institution.id, :tagger_type => 'Institution'}},
             :group => 'tags.name')
  end
end
