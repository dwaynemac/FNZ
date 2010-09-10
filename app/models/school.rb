class School < ActiveRecord::Base

  validates_uniqueness_of(:padma_id)

  has_many :users
  has_many :accounts
  has_many :transactions, :through => :accounts

  has_many :imports

  belongs_to :default_account, :class_name => "Account"

end
