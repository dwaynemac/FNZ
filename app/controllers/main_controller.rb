class MainController < ApplicationController
  def index
    @students = current_user.padma.client.get("/alumnos/count")
    respond_to do |format|
      format.html
    end
  end
end
