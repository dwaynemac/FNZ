require 'test_helper'

class SchoolTest < ActiveSupport::TestCase

  should_validate_uniqueness_of(:padma_id)
  should_have_many(:users)
  should_have_many(:accounts)
  should_have_many(:transactions)
  should_have_many(:imports)

end
