require 'test_helper'

class PersonTest < ActiveSupport::TestCase

  context "person" do
    setup do
      @person = Person.make
    end
    subject { @person }
    
    should_validate_uniqueness_of(:padma_id)

    should_belong_to(:institution)
    should_validate_uniqueness_of(:email, :scoped_to => :institution, :case_sensitive => false)

    should_validate_presence_of(:name)

    should_have_many(:transactions)
    context "sync_from_padma" do
      should "" do
        assert(false, "write test")
      end
    end
  end

end
