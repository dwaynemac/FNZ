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

  context "full_name_like scope" do
    setup do
      [
        ["Dwayne","Macgowan"],
        ["Alejandro Diego", "Macgowan"],
        ["Maria Julia","Gomez de Lopez Cinq"]
      ].each do |data|
        Person.make(:name => data[0], :surname => data[1])
      end
    end

    should "return 1 result if exact match found" do
      assert_equal 1, Person.full_name_like("Dw Macg").count
    end

    should "return all results that match query" do
      assert_equal 2, Person.full_name_like("D Macgowan").count
    end

    should "consider middle names" do
      assert_equal 1, Person.full_name_like("Julia").count
    end

  end

end
