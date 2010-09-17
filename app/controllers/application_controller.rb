class ApplicationController < ActionController::Base
  helper :all
  
  include AuthSystem
  include DRCClient::HelperMethods

  before_filter DRCClient.filter
  before_filter :create_local_user_if_required
  before_filter :login_required
  before_filter :authorization_required
  before_filter :reconnect_to_padma_if_no_institution

  private

  def create_local_user_if_required
    return unless logged_in_drc?
    User.find_or_create_by_drc_user(current_drc_user)
  end

  def reconnect_to_padma_if_no_institution
    # connected to padma but got no institution
    if current_user.connected_to_padma? && current_user.institution.nil?
      current_user.update_attribute(:institution_id, current_user.padma.current_institution.try(:id))
      if current_user.institution.nil?
        flash[:error] = I18n.t('application.reconnect_got_no_institution')
        redirect_to oauth_consumer_path("padma")
      end
    end
  end

end
