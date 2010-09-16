require 'test_helper'

class TagBalanceTest < ActiveSupport::TestCase

  should_belong_to(:institution,:tag)

  context "for a tag" do
    setup do
      @institution = Institution.make(:default_currency => "ars")
      @tag = Tag.make
    end
    context "without transactions" do
      context "calculate_balance" do
        setup do
          @bal = @tag.balance_for(@institution)
          @tag.reload
        end
        should "return 0" do
          assert_equal 0, @bal.cents
        end
        should "cache balance" do
          @tag.reload
          assert_equal Money.new(0,@institution.default_currency), @tag.tag_balances.find_by_institution_id(@institution.id).saved_balance
        end
      end
    end
    context "with transactions of same currency" do
      setup do
        @account = Account.make(:institution => @institution)

        20.times{ Transaction.make(:type => "Income", :concept_list => @tag.name, :account => @account, :cents => 1)}
        5.times{ Transaction.make(:type => "Expense", :concept_list => @tag.name, :account => @account, :cents => 1)}
      end
      context "calculate_balance" do
        setup do
          @bal = @tag.balance_for(@institution)
          @tag.reload
        end
        should "return 15" do
          assert_equal 15, @bal.cents
        end
        should "cache balance" do
          assert_equal 15, @tag.tag_balances.find_by_institution_id(@institution.id).cents
        end
      end
    end
    context "with transactions of different currency" do
      setup do
        Money.add_rate("usd","ars",4)
        @usd_account = Account.make(:institution => @institution, :currency => "usd")
        @ars_account = Account.make(:institution => @institution, :currency => "ars")

        10.times do
          t = Transaction.make(:type => "Income", :account => @ars_account, :cents => 100)
          t.set_concept_list(@tag.name)
        end
        10.times  do
          t = Transaction.make(:type => "Income", :account => @usd_account, :cents => 100)
          t.set_concept_list(@tag.name)
        end
        10.times do
          t = Transaction.make(:type => "Expense", :account => @ars_account, :cents => 100)
          t.set_concept_list(@tag.name)
        end
      end
      context "calculate_balance" do
        setup do
          @bal = @tag.balance_for(@institution)
          @tag.reload
        end
        should "return 4000" do
          assert_equal 4000, @bal.cents
        end
        should "cache balance" do
          assert_equal 4000, @tag.tag_balances.find_by_institution_id(@institution.id).cents
        end
      end
    end
  end   

end
