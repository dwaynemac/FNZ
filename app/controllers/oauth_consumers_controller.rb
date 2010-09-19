require 'oauth/controllers/consumer_controller'
class OauthConsumersController < ApplicationController
  include Oauth::Controllers::ConsumerController
  skip_filter :authorization_required

  def index
    @consumer_tokens=ConsumerToken.all :conditions=>{:user_id=>current_user.id}
    @services=OAUTH_CREDENTIALS.keys-@consumer_tokens.collect{|c| c.class.service_name}
  end
  
  protected
  
  # Change this to decide where you want to redirect user to after callback is finished.
  # params[:id] holds the service name so you could use this to redirect to various parts
  # of your application depending on what service you're connecting to.
  def go_back
    if current_user.connected_to_padma?

      # set user's institution
      school = current_user.padma.current_school
      institution = Institution.find_or_initialize_by_padma_id(school["id"])
      if institution.name.blank?
        institution.name = school["name"]
        institution.default_currency = school["currency_code"]
        unless institution.save
          institution = nil
        end
      end
      current_user.institution = institution

      # set user's locale
      current_user.locale = current_user.padma.current_user["locale"]
      
      current_user.save
    end
    redirect_to welcome_url
  end
  
end
