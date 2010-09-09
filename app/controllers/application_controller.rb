class ApplicationController < ActionController::Base
  helper :all
  
  include AuthSystem
  include DRCClient::HelperMethods

  before_filter DRCClient.filter
  before_filter :create_local_user_if_required
  before_filter :login_required
  before_filter :authorization_required

  private
  def create_local_user_if_required
    return unless logged_in_drc?
    User.find_or_create_by_drc_user(current_drc_user)
  end
end
