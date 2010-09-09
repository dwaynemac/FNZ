require 'test_helper'

class TransactionTest < ActiveSupport::TestCase

  should_belong_to(:account)
  should_belong_to(:user)

  should_validate_presence_of(:made_on)
  should_validate_presence_of(:account)

  context "on creation" do
    setup do
      @account = Account.make(:currency => "BRL")
      @transaction = Transaction.make_unsaved(:account => @account, :currency => nil)
      @transaction.save!
      @transaction.reload
    end
    should "get currency from account" do
      assert_equal(@account.currency,@transaction.currency)
    end
  end

  context "When assigning tags" do
    setup do
      args = Transaction.plan
      args.merge!({:concept_list => "mantenimiento, ventanas"})
      @transaction = Transaction.create(args)
    end
    should "they should be available" do
      assert_equal ["mantenimiento", "ventanas"], @transaction.concepts.map{|t| t.name }
    end
  end

end
