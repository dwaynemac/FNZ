class PeopleController < ApplicationController

  before_filter :set_scope

  # GET /people
  # GET /people.xml
  def index
    @people = @scope.paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @people }
    end
  end

  def in_padma
    search = {"order" => "ascend_by_nombres"}.merge(params[:search]||{})
    @people = current_user.padma.people({:search => search, :page => params[:page]||1})
    respond_to do |format|
      format.html
    end
  end

  # GET /people/1
  # GET /people/1.xml
  def show
    @person = get_person
    if !@person.sync_from_padma(current_user.padma)
      flash[:notice] = I18n.t('people.show.not_synced')
    end
    @transactions = @person.transactions.paginate(:page => params[:page])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @person }
    end
  end

  # GET /people/new
  # GET /people/new.xml
  def new
    @person = @scope.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @person }
    end
  end

  # GET /people/1/edit
  def edit
    @person = @scope.find(params[:id])
  end

  # POST /people
  # POST /people.xml
  def create
    if params[:padma_id]
      pp = current_user.padma.person(params[:padma_id])
      # TODO email
      @person = @scope.build(:name => pp["name"], :surname => pp["surname"], :padma_id => pp["id"])
      @person.synced_at = Time.now
    else
      @person = @scope.build(params[:person])
    end
    respond_to do |format|
      if @person.save
        format.html { redirect_to(@person, :notice => I18n.t('people.create.success')) }
        format.xml  { render :xml => @person, :status => :created, :location => @person }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @person.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /people/1
  # PUT /people/1.xml
  def update
    @person = @scope.find(params[:id])

    respond_to do |format|
      if @person.update_attributes(params[:person])
        format.html { redirect_to(@person, :notice => I18n.t('people.update.success')) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @person.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /people/1
  # DELETE /people/1.xml
  def destroy
    @person = @scope.find(params[:id])
    @person.destroy

    respond_to do |format|
      format.html { redirect_to(people_url) }
      format.xml  { head :ok }
    end
  end

  private
  def set_scope
    @scope = current_institution.people
  end

  # gets person by params[:id] or params[:padma_id]
  # if no person with :padma_id is found it's created.
  def get_person
    if params[:id]
      p = @scope.find(params[:id])
    elsif params[:padma_id]
      p = @scope.find_by_padma_id(params[:padma_id])
      if p.nil?
        current_user.padma.person(params[:padma_id])
        p = @scope.build(:name => pp["name"], :surname => pp["surname"], :padma_id => pp["id"], :synced_at => Time.now)
        if !p.save
          p = nil
        end
      end
    end
    # TODO if p.nil? raise 404 ?
    return p
  end
end
