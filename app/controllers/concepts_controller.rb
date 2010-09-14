class ConceptsController < ApplicationController

  def index
    @income_concepts = current_user.school.incomes.tag_counts_on(:concepts)
    @expense_concepts = current_user.school.expenses.tag_counts_on(:concepts)
    respond_to do |format|
      format.html
    end
  end

  def show
    @concept = Tag.find_by_name(params[:id])
    @transactions = current_user.school.transactions.tagged_with(@concept).paginate(:page => params[:page], :include => [:user, :account])
    respond_to do |format|
      format.html
    end
  end
end
