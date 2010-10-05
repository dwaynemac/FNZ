class TransactionsController < ApplicationController

  include Slider

  before_filter :set_scope

  # GET /transactions
  # GET /transactions.xml
  def index
    @months = months_for_select(1.year.ago.to_date,3.month.from_now.to_date)
    start = Time.zone.now.beginning_of_month
    @since, @until = get_range(:default_since => start,:default_until => start+1.month)
    if params[:search].nil?
      @considered_field = :made_on
    else
      @considered_field = params[:search].delete(:period_field).to_sym
    end

    @transactions = @scope.field_after(@considered_field,@since).field_before(@considered_field,@until).paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @transactions }
    end
  end

  # GET /transactions/1
  # GET /transactions/1.xml
  def show
    @transaction = @scope.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @transaction }
    end
  end

  # GET /transactions/new
  # GET /transactions/new.xml
  def new
    @transaction = @scope.build(:made_on => Time.zone.now)
    @accounts = current_institution.accounts.all
    @categories = current_institution.categories.all

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @transaction }
    end
  end

  # GET /transactions/1/edit
  def edit
    @transaction = @scope.find(params[:id])
    @accounts = current_institution.accounts.all
    @categories = current_institution.categories.all
  end

  # POST /transactions
  # POST /transactions.xml
  def create
    case params[:transaction].delete(:type)
      when "Income"
        @transaction = @scope.incomes.build(params[:transaction])
      else # default to Expense
        @transaction = @scope.expenses.build(params[:transaction])
    end
    if concepts = params[:transaction].delete(:concept_list)
      current_institution.tag(@transaction,:on => :concepts, :with => concepts)
    end
    respond_to do |format|
      if @transaction.save
        format.html { redirect_to(@return_to, :notice => 'Transaction was successfully created.') }
        format.xml  { render :xml => @transaction, :status => :created, :location => @transaction }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @transaction.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /transactions/1
  # PUT /transactions/1.xml
  def update
    @transaction = @scope.find(params[:id])

    respond_to do |format|
      if @transaction.update_attributes(params[:transaction])
        format.html { redirect_to(@return_to, :notice => 'Transaction was successfully updated.') }
        format.xml  { head :ok }
        format.json { render :json => {:result => @transaction.send(params[:wants])}}
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @transaction.errors, :status => :unprocessable_entity }
        format.json { render :json => {:result => @transaction.send(params[:wants]+'_was')}} # return original value
      end
    end
  end

  # DELETE /transactions/1
  # DELETE /transactions/1.xml
  def destroy
    @transaction = @scope.find(params[:id])
    @transaction.destroy

    respond_to do |format|
      format.html { redirect_to(@return_to) }
      format.xml  { head :ok }
    end
  end

  def transfer
    @transfer_form = TransferForm.new(params[:transfer_form])
    # (POST?)
    if params[:transfer_form]
      unless @transfer_form.valid?
        @accounts = current_institution.accounts.all
        respond_to do |format|
          format.html { render :action => 'transfer' }
        end
      else
        from_account = current_institution.accounts.find(@transfer_form.from_account_id)
        to_account = current_institution.accounts.find(@transfer_form.to_account_id)
        cents = @transfer_form.amount.to_money.cents
        if from_account.transfer(current_user,to_account,cents,nil,@transfer_form.description)
          respond_to do |format|
            format.html do
              flash[:notice] = I18n.t('transactions.transfer.transfered')
              redirect_to accounts_url
            end
          end
        else
          @accounts = current_institution.accounts.all
          respond_to do |format|
            format.html { render :action => 'transfer' }
          end
        end
      end
    else
      #form (GET?)
      @accounts = current_institution.accounts.all
      respond_to do |format|
        format.html { render :action => 'transfer' }
      end
    end
  end

  private
  def set_scope
    if params[:account_id]
      account = current_institution.accounts.find(params[:account_id])
      @scope = account.transactions
      @return_to = account_url(account)
    elsif params[:person_id]
      person = current_institution.people.find(params[:person_id])
      @scope = person.transactions
      @return_to = person_url(person)
    else
      @scope = current_user.transactions
      @return_to = transactions_url
    end
  end
end
