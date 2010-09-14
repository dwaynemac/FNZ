class MainController < ApplicationController
  def index
    respond_to do |format|
      format.html
    end
  end

  def welcome
    begin
      @students = current_user.padma.client.get("/alumnos/count")
    rescue
      @no_connection = true
      flash[:error] = t('api.problem_with_connetion')
    end
    respond_to do |format|
      format.html
    end
  end
end
