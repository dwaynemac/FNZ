require 'test_helper'

class UserTest < ActiveSupport::TestCase
  should_have_many :transactions
  should_have_many :incomes
  should_have_many :expenses
  should_belong_to :school
  should_have_many :imports
end
