class PeopleTransaction < ActiveRecord::Base
  validates_presence_of :transactions
  validates_presence_of :person
  belongs_to :person
  belongs_to :transaction
end
