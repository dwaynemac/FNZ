class CreditTransfer < Transaction

  has_one :transfer, :foreign_key => "credit_id", :dependent => :destroy

  has_one :debit, :through => :transfer, :foreign_key => "credit_id", :class_name => "DebitTransfer"

end
