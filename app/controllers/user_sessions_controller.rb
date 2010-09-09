class UserSessionsController < ApplicationController
  skip_filter :login_required
  skip_filter :authorization_required
  def unauthorized
    if logged_in? && current_user.allowed?
      redirect_to root_url
    else
      respond_to do |format|
        format.html
        format.xml do
          headers["Status"] = "Unauthorized"
          render :text => "Could't authenticate you", :status => '401 Unauthorized'
        end
      end
    end
  end

  def destroy
    current_user_session.destroy
    DRCClient.logout(self)
  end
end
