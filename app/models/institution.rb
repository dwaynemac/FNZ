class Institution < ActiveRecord::Base

  acts_as_tagger
  
  #validates_uniqueness_of(:padma_id)

  has_many :users
  has_many :accounts

  has_many :people

  has_many :transactions, :through => :accounts
  has_many :incomes, :through => :accounts
  has_many :expenses, :through => :accounts

  has_many :categories

  has_many :imports

  belongs_to :default_account, :class_name => "Account"

end
