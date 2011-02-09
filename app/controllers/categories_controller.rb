class CategoriesController < ApplicationController

  include Slider

  before_filter :set_scope

  # GET /categories
  # GET /categories.xml
  def index
    @months = months_for_select(1.year.ago.to_date,3.month.from_now.to_date)
    start = Time.zone.now.beginning_of_month
    @since, @until = get_range(:default_since => start,:default_until => start+1.month)

    respond_to do |format|
      format.html do
        @roots = @scope.roots.paginate(:page => params[:page])
        @roots.sort!{|a,b| b.balance(:from => @since,:to => @until,:consider => :account_on) <=> a.balance(:from => @since,:to => @until,:consider => :account_on) } # order by balance
      end
      format.xml do
        @categories = @scope.all
      end
    end
  end

  # GET /categories/1
  # GET /categories/1.xml
  def show
    @months = months_for_select(1.year.ago.to_date,3.month.from_now.to_date)
    start = Time.zone.now.beginning_of_month
    @since, @until = get_range(:default_since => start,:default_until => start+1.month)

    @category = @scope.find(params[:id])
    @transactions = @category.all_transactions.field_after(:account_on,@since).field_before(:account_on,@until).paginate(:page => params[:page])

    #paarmetrizar para que user_id sea parametrizado y drcuser sea el que es básicamente
    #en kshema lo hizo dw con un case: when instructor .. then ...
    subtotals = @category.balance(:group_by => :user_id,:from => @since, :to => @until, :consider => :account_on)
    subtotals = subtotals.sort{|a,b| b[1]<=>a[1]}
    @users_subtotals = subtotals.map{|g| [current_institution.users.find(g[0]).try(:drc_user),g[1]]}

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @category }
    end
  end

  # GET /categories/new
  # GET /categories/new.xml
  def new
    @category = @scope.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @category }
    end
  end

  def subcategory
    @parent = @scope.find(params[:id])
    @category = Category.new(:parent_id => params[:id])
    respond_to do |format|
      format.html { render :action => :new }
    end
  end

  # GET /categories/1/edit
  def edit
    @category = @scope.find(params[:id])
    @categories = @scope.all
  end

  # POST /categories
  # POST /categories.xml
  def create
    @category = @scope.build(params[:category])

    respond_to do |format|
      if @category.save
        format.html { redirect_to(categories_url, :notice => 'Category was successfully created.') }
        format.xml  { render :xml => @category, :status => :created, :location => @category }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /categories/1
  # PUT /categories/1.xml
  def update
    @category = @scope.find(params[:id])

    respond_to do |format|
      if @category.update_attributes(params[:category])
        format.html { redirect_to(@category, :notice => 'Category was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1
  # DELETE /categories/1.xml
  def destroy
    @category = @scope.find(params[:id])
    @category.destroy

    respond_to do |format|
      format.html { redirect_to(categories_url) }
      format.xml  { head :ok }
    end
  end

  def edit_multiple
    @categories = @scope.find(params[:category_ids])
    @all_categories = @scope.all(:conditions => ["id not in (?)",params[:category_ids]])
  end

  def update_multiple
    @categories = @scope.find(params[:category_ids])
    @categories.each do |c|
      c.update_attributes(params[:category])
      # TODO consider validations may fail
    end
    redirect_to categories_path, :notice => "Updated categories!"
  end

  private
  def set_scope
    @scope = current_institution.categories
  end
end

