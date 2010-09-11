require 'test_helper'

class ImportedRowTest < ActiveSupport::TestCase

  def setup
    ImportedRow.make(:success)
  end

  should_belong_to(:import)
  should_belong_to(:transaction)
  should_validate_presence_of(:import)

  context "successfull" do
    should "validate presence of transaction" do
      i = ImportedRow.make(:success)
      i.transaction_id = nil
      assert(!i.valid?)
    end
  end
  context "failed" do
    should "validate presence of row" do
      i = ImportedRow.make(:failed)
      i.row = nil
      assert(!i.valid?)
    end
  end
end
