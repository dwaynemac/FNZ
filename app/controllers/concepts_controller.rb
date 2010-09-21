class ConceptsController < ApplicationController

  def index
    @concepts = Tag.for_institution(current_institution)
    @concepts.sort{|a,b| a.balance_for(current_institution) <=> b.balance_for(current_institution) }
    respond_to do |format|
      format.html
    end
  end

  def show
    @concept = Tag.find_by_name(params[:id])
    @transactions = current_institution.transactions.tagged_with(@concept).paginate(:page => params[:page])
    respond_to do |format|
      format.html
    end
  end
end
