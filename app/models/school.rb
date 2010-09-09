class School < ActiveRecord::Base

  validates_uniqueness_of(:padma_id, :allow_nil => true)

  has_many :users
  has_many :accounts
  has_many :transactions, :through => :accounts

end
