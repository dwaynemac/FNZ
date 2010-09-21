require 'test_helper'

class PeopleTransactionTest < ActiveSupport::TestCase
  should_belong_to(:person)
  should_belong_to(:transactions)
  should_validate_presence_of(:person)
  should_validate_presence_of(:transaction)
end
