class ApplicationController < ActionController::Base
  helper :all
  
  include AuthSystem
  include DRCClient::HelperMethods

  before_filter DRCClient.filter
  before_filter :create_local_user_if_required
  before_filter :login_required
  before_filter :authorization_required
  before_filter :reconnect_to_padma_if_no_institution
  before_filter :set_locale

  # for application layout
  before_filter :get_accounts_for_account_bar

  private
  def get_accounts_for_account_bar
    return unless logged_in? && current_user.allowed?
    @accounts = current_institution.accounts.all
  end

  def set_locale
    new_locale = params[:locale]
    new_locale ||= current_user.locale if logged_in?
    new_locale ||= request.preferred_language_from(I18n.available_locales)
    I18n.locale = new_locale
  end

  def create_local_user_if_required
    return unless logged_in_drc?
    User.find_or_create_by_drc_user(current_drc_user)
  end

  def reconnect_to_padma_if_no_institution
    # connected to padma but got no institution
    if current_user.connected_to_padma? && current_user.institution.nil?
      school = current_user.padma.current_school
      institution = Institution.find_or_initialize_by_padma_id(school["id"])
      if institution.name.blank?
        institution.name = school["name"]
        unless institution.save
          institution = nil
        end
      end
      current_user.institution = institution
      current_user.save
      if current_user.institution.nil?
        flash[:error] = I18n.t('application.reconnect_got_no_institution')
        redirect_to oauth_consumer_path("padma")
      end
    end
  end

end
