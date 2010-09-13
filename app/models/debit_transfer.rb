class DebitTransfer < Transaction

  has_one :credit, :through => :transfer, :class_name => "CreditTransfer"

  has_one :transfer, :foreign_key => "debit_id", :dependent => :destroy

end
