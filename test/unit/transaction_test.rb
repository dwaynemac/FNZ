require 'test_helper'

class TransactionTest < ActiveSupport::TestCase

  should_belong_to(:category)
  should_belong_to(:account)
  should_belong_to(:user)

  should_validate_presence_of(:made_on)
  should_validate_presence_of(:account)
  should_validate_presence_of(:user)
  should_validate_presence_of(:cents)

  should_allow_values_for(:cents, 10, 14482554,0)
  should_not_allow_values_for(:cents, -5, 124256365,-9658745236,2125.23,"asd")

  

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
  context "on save" do
    setup do
      @account = Account.make
      t = Transaction.make_unsaved(:account => @account, :cents => 100, :type => "Income")
      t.save!
    end
    should "save accounts balance" do
      assert_equal 100, @account.cents
    end
  end
  context "on destroy" do
    setup do
      @account = Account.make
      t = Transaction.make_unsaved(:account => @account, :cents => 100, :type => "Income")
      t.save!
      t.destroy
    end
    should "save accounts balance" do
      assert_equal 0, @account.cents
    end
  end

  context "" do
    setup do
      @institution = Institution.make
      @account = Account.make(:institution => @institution)
    end
    context "When assigning tags" do
      setup do
        args = Transaction.plan(:account => @account)
        @transaction = Transaction.create(args)
        @institution.tag(@transaction,:with => "mantenimiento, ventanas",:on => :concepts)
      end
      should "they should be available" do
        assert_equal ["mantenimiento", "ventanas"], @transaction.concepts_from(@institution)
      end
    end
  end


end
