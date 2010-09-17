require 'test_helper'

class ImportTest < ActiveSupport::TestCase

  should_have_many(:transactions)
  should_have_many(:imported_rows)
                
  should_belong_to(:institution)
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
      @institution = Institution.make
      @account = Account.make(:institution => @institution)
      @import = Import.make(:institution => @institution, :csv_file => ActionController::TestUploadedFile.new(File.dirname(__FILE__) + '/../fixtures/no_accounts.csv', 'text/csv'))
    end
    context "if institution has default account" do
      setup do
        @import.load_data!
      end
      should "set state to :imported once it finished" do
        assert_equal "imported", @import.aasm_state
      end
      should_change("qt of tranasctions", :by => 2){@institution.transactions.all.count}
      should_change("qt of imported rows", :by => 3){@import.imported_rows.all.count}
      should "tag transactions with institution as owner" do
        assert_equal @institution.transactions.last.concepts_from(@institution), ["mantenimiento"]
      end
      should "assign category" do
        assert_equal @institution.categories.last.name, "Mantenimiento"
      end
      should "create category if it doesnt exist" do
        assert_equal @institution.categories.last.name, "Mantenimiento"
      end
    end
    context "if institution doesnt have default account" do
      setup do
        @institution.update_attribute(:default_account_id, nil) # creating account sets it as default
        @institution.reload
        @import.load_data!
      end
      should "set state to :failed" do
        assert_equal "failed", @import.aasm_state
      end
      should_not_change("qt of transactions"){@institution.transactions.all.count}
    end
  end

end
