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
    # set user's institution if connected
    if current_user.connected_to_padma?
      institution_hash = current_user.padma.simple_client.get("/api/schools/my")
      institution = Institution.find_or_initialize_by_padma_id(institution_hash["id"])
      if institution.name.blank?
        institution.name = institution_hash["name"]
        if institution.save
          flash[:success] = "institution created"
        end
      end
      current_user.update_attribute(:institution_id, institution.id)
    end
    redirect_to welcome_url
  end
  
end
