class ImportedRow < ActiveRecord::Base

  validates_presence_of(:import)
  belongs_to(:import)

  belongs_to(:transaction)
  validates_presence_of(:transaction, :if => Proc.new{ |ir| ir.successfull? })
  validates_presence_of(:row, :if => Proc.new{ |ir| ir.failed?})

  named_scope :successfull, :conditions => "success"
  named_scope :failed, :conditions => "not success"

  def successfull?
    return self.success
  end

  def failed?
    return !self.success
  end
end
