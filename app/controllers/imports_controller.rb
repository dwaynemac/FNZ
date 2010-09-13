class ImportsController < ApplicationController

  before_filter :set_scope

  # GET /imports
  # GET /imports.xml
  def index
    @imports = @scope.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @imports }
    end
  end

  # GET /imports/1
  # GET /imports/1.xml
  def show
    @import = @scope.find(params[:id])
    @transactions = @import.transactions.all
    @errors = @import.imported_rows.failed.all

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @import }
    end
  end

  # GET /imports/new
  # GET /imports/new.xml
  def new
    @import = @scope.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @import }
    end
  end

  # GET /imports/1/edit
  def edit
    @import = @scope.find(params[:id])
  end

  # POST /imports
  # POST /imports.xml
  def create
    @import = @scope.build(params[:import])

    respond_to do |format|
      if @import.save
        format.html { redirect_to(@import, :notice => 'Import was successfully created.') }
        format.xml  { render :xml => @import, :status => :created, :location => @import }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @import.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /imports/1
  # PUT /imports/1.xml
  def update
    @import = @scope.find(params[:id])

    respond_to do |format|
      if @import.update_attributes(params[:import])
        format.html { redirect_to(@import, :notice => 'Import was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @import.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /imports/1
  # DELETE /imports/1.xml
  def destroy
    @import = @scope.find(params[:id])
    @import.destroy

    respond_to do |format|
      format.html { redirect_to(imports_url) }
      format.xml  { head :ok }
    end
  end

  def load_data
    @import = @scope.find(params[:id])
    @import.load_data!
    @import.reload
    respond_to do |format|
      format.html { redirect_to(imports_url, :notice => "imported!") }
    end
  end

  private
  def set_scope
    @scope = current_user.school.imports
  end
end
