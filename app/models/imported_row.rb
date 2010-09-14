class ImportedRow < ActiveRecord::Base

  named_scope :ordered, lambda { |by| {:order => by} }

  validates_presence_of(:import)
  belongs_to(:import)

  belongs_to(:transaction, :dependent => :destroy)
  validates_presence_of(:transaction, :if => Proc.new{ |ir| ir.successfull? })
  validates_presence_of(:row)

  named_scope :successfull, :conditions => "success"
  named_scope :failed, :conditions => "not success"

  def successfull?
    return self.success
  end

  def failed?
    return !self.success
  end
end
