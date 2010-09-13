class MainController < ApplicationController
  def index
    begin
      @students = current_user.padma.client.get("/alumnos/count")
    rescue
      @no_connection = true
      flash[:error] = t('api.problem_with_connetion')
    end
    @income_concepts = Income.tag_counts_on(:concepts)
    @expense_concepts = Expense.tag_counts_on(:concepts)
    respond_to do |format|
      format.html
    end
  end

  def welcome
    respond_to do |format|
      format.html
    end
  end
end
