class UsersController < ApplicationController

  before_filter :set_scope

  def show
    if params[:id] == "me"
      @user = current_user
    else
      @user = @scope.find(params[:id])
    end
    @transactions = @user.transactions.paginate(:page => params[:page])
    respond_to do |format|
      format.html
    end
  end

  def edit
    if params[:id] == "me"
      @user = current_user
    else
      @user = @scope.find(params[:id])
    end
    respond_to do |format|
      format.html do
        if @user != current_user
          flash[:notice] = I18n.t('not_allowed')
          redirect_to root_url
        end
      end
    end


  end

  private
  def set_scope
    @scope = current_institution.users
  end
end
