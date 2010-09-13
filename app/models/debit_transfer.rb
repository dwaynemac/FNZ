class DebitTransfer < Transaction
  has_and_belongs_to_many :credits,
                          :class_name => "CreditTransfer",
                          :join_table => :transfer, :foreign_key => :debit_id, :association_foreign_key => :credit_id
end
