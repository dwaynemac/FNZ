class Tag < ActiveRecord::Base
  acts_as_tree

  # override count for cloud to be built using this criteria
  # TODO just for testing this math makes no sence
  def count
    return Income.tagged_with(self).sum(:cents) - Expense.tagged_with(self).sum(:cents)
  end
end
