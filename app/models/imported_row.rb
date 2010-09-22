class ImportedRow < ActiveRecord::Base

  named_scope :ordered, lambda { |by| {:order => by} }

  validates_presence_of(:import)
  belongs_to(:import)

  belongs_to(:transaction, :dependent => :destroy)
  validates_presence_of(:transaction, :if => Proc.new{ |ir| ir.successfull? })
  validates_presence_of(:row)

  named_scope :successfull, :conditions => "success"
  named_scope :failed, :conditions => "not success"
  named_scope :with_message, :conditions => "success and (message is not null and message <> '')"

  named_scope(:filter, lambda{ |filter|
    case filter
      when "successfull"
        {:conditions => "success"}
      when "failed"
        {:conditions => "not success"}
      when "with_message"
        {:conditions => "success and (message is not null and message <> '')"}
    end
  }) 

  def successfull?
    return self.success
  end

  def failed?
    return !self.success
  end
end
