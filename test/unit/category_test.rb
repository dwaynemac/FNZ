require 'test_helper'

class CategoryTest < ActiveSupport::TestCase

  def setup
    Category.make
  end

  should_validate_presence_of(:name, :institution)
  should_validate_uniqueness_of(:name, :scoped_to => :institution_id)
  should_belong_to(:institution)
  should_have_many(:transactions)

  context "Category from different institutions" do
    setup do
      @ia = Institution.make
      @a = Category.make(:institution => @ia)
      @ib = Institution.make
      @b = Category.make(:institution => @ib)
    end

    should "validate parent is from same institution" do
      @a.parent_id = @b.id
      assert(!@a.save)
    end
  end

  context "category name" do
    setup do
      @asdf = Category.make(:name => "ASDF")
      @qwer = Category.make(:name => "qwer")
    end
    should "always be capitalized" do
      assert_equal "Asdf", @asdf.name
      assert_equal "Qwer", @qwer.name
      assert_not_equal "ASDF", @asdf.name
      assert_not_equal("qwer", @qwer.name)
    end
  end

  context "for a category" do
    setup do
      @institution = Institution.make(:default_currency => "ars")
      @category = Category.make(:institution => @institution)
    end
    context "without transactions" do
      context "balance()" do
        setup do
          @bal = @category.balance
          @category.reload
        end
        should "return 0" do
          assert_equal 0, @bal.cents
        end
      end
      context "balance(:group_by => 'person_id')" do
        setup do
          @bal = @category.balance(:group_by => 'person_id')
        end
        should "return {}" do
          assert_equal({}, @bal)
        end
      end
    end
    context "with transactions of same currency" do
      setup do
        @account = Account.make(:institution => @institution, :currency => "ars")

        20.times{ Transaction.make(:type => "Income", :category_id => @category.id, :account => @account, :cents => 1)}
        5.times{ Transaction.make(:type => "Expense", :category_id  => @category.id, :account => @account, :cents => 1)}
      end
      context "balance()" do
        setup do
          @bal = @category.balance
          @category.reload
        end
        should "return 15" do
          assert_equal 15, @bal.cents
        end
      end
      context "done by different persons" do
        setup do
          @aperson = Person.make(:institution => @institution)
          @bperson = Person.make(:institution => @institution)

          5.times{ Transaction.make(:person => @aperson, :type => "Income", :category_id  => @category.id, :account => @account, :cents => 1)}
          10.times{ Transaction.make(:person => @bperson, :type => "Income", :category_id  => @category.id, :account => @account, :cents => 1)}
        end
        context "balance(:group_by => person_id)" do
          setup do
            @bal = @category.balance(:group_by => 'person_id')
          end
          should "return balances grouped by person" do
            assert_equal 5, @bal[@aperson.id].cents
            assert_equal 10, @bal[@bperson.id].cents
          end
        end
      end
    end
    context "with transactions of different currency" do
      setup do
        Money.add_rate("usd","ars",4)
        @usd_account = Account.make(:institution => @institution, :currency => "usd")
        @ars_account = Account.make(:institution => @institution, :currency => "ars")

        10.times do
          Transaction.make(:type => "Income", :account => @ars_account, :cents => 100, :category => @category)
        end
        10.times  do
          Transaction.make(:type => "Income", :account => @usd_account, :cents => 100, :category => @category)
        end
        10.times do
          Transaction.make(:type => "Expense", :account => @ars_account, :cents => 100, :category => @category)
        end
      end
      context "balance" do
        setup do
          @bal = @category.balance
          @category.reload
        end
        should "return 4000" do
          assert_equal 4000, @bal.cents
        end
      end
    end
  end

  context "for a category tree" do
    setup do
      @institution = Institution.make(:default_currency => "ars")
      @account = Account.make(:institution => @institution, :currency => "ars")

      @person = Person.make(:institution => @institution)

      @other_root = Category.make(:institution => @institution)
      Transaction.make(:type => "Income", :account => @account, :category => @other_root, :cents => 100, :person => @person)

      @root = Category.make(:institution => @institution)
      Transaction.make(:type => "Income", :account => @account, :category => @root, :cents => 100, :person => @person)
      10.times do
        @last = Category.make(:institution => @institution, :parent => @root)
        Transaction.make(:type => "Income", :account => @account, :category => @last, :cents => 100, :person => @person)
      end
      @grand_son = Category.make(:institution => @institution, :parent => @last)
      Transaction.make(:type => "Income", :account => @account, :category => @grand_son, :cents => 100, :person => @person)
    end

    should "consider all descendants for balance" do
      assert_equal 1200, @root.balance.cents
    end

    should "validate that a loop is not being created (ancestor descendant of descendant)" do
      @root.parent_id = @grand_son.id
      assert(!@root.save)
    end

    context "@root.all_transactions" do
      should "consider root and root-descendants transactions" do
        assert_equal( 12,@root.all_transactions.count )
      end
    end

    context "balance(:group_by => 'person_id')" do
      setup do
        @bal = @root.balance(:group_by => 'person_id')
      end
      should "consider sub categories" do
        assert_equal @root.balance.cents, @bal[@person.id].cents
      end
    end
  end

end

