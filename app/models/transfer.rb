# Join Model for DebitTransfer and CreditTransfer
class Transfer < ActiveRecord::Base
  belongs_to :credit, :class_name => "CreditTransfer", :dependent => :destroy
  belongs_to :debit, :class_name => "DebitTransfer", :dependent => :destroy

  validates_presence_of :credit
  validates_presence_of :debit
end
