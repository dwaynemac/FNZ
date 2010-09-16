# Modifications to acts-as-taggable-on Tag model
class Tag < ActiveRecord::Base

  has_many :tag_balances

  def balance_for(institution)
    institution = institution.id if institution.is_a?(Institution)
    return self.tag_balances.find_or_create_by_institution_id(institution).balance
  end

end
