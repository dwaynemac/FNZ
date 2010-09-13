require 'test_helper'

class ImportTest < ActiveSupport::TestCase

  should_have_many(:transactions)
  should_have_many(:imported_rows)
                
  should_belong_to(:school)
  should_belong_to(:user)

  should_have_attached_file :csv_file
  should("validate attachment presence") do
    t = Import.make_unsaved(:csv_file => nil)
    assert(!t.save)
  end
  should("only accept csv files") do
    t = Import.make_unsaved(:csv_file => ActionController::TestUploadedFile.new(File.dirname(__FILE__) + '/../fixtures/non_csv.file', 'image/png'))
    assert(!t.save)
  end

  context "initial state" do
    setup do
      @import = Import.make
    end
    should "be :ready" do
      assert_equal "ready", @import.aasm_state
    end
  end

  context "import#load_data!" do
    setup do
      @school = School.make
      @account = Account.make(:school => @school)
      @import = Import.make(:school => @school, :csv_file => ActionController::TestUploadedFile.new(File.dirname(__FILE__) + '/../fixtures/no_accounts.csv', 'text/csv'))
    end
    context "if school has default account" do
      setup do
        @import.load_data!
      end
      should "set state to :imported once it finished" do
        assert_equal "imported", @import.aasm_state
      end
      should_change("qt of tranasctions"){@school.transactions.all.count}
    end
    context "if school doesnt have default account" do
      setup do
        @school.update_attribute(:default_account_id, nil) # creating account sets it as default
        @school.reload
        @import.load_data!
      end
      should "set state to :failed" do
        assert_equal "failed", @import.aasm_state
      end
      should_not_change("qt of transactions"){@school.transactions.all.count}
    end
  end

end
