class CreditTransfer < Transaction
  has_and_belongs_to_many :debits,
                          :class_name => "DebitTransfer",
                          :join_table => :transfers, :foreign_key => :credit_id, :association_foreign_key => :debit_id 

end
