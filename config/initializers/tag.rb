# Modifications to acts-as-taggable-on Tag model
class Tag < ActiveRecord::Base
  acts_as_tree

  has_many :tag_balances

  def balance_for(institution)
    institution = institution.id if institution.is_a?(Institution)
    return self.tag_balances.find_or_create_by_institution_id(institution).balance
  end

  # override count for cloud to be built using this criteria
  #def count
  #  self.balances
  #end
end
