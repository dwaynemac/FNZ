module AuthSystem
  
  def self.included(base)
    base.send(:helper_method, :current_user, :logged_in?, :current_institution)
  end
  
  private
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find  
  end
  
  def authorization_required
    unless logged_in? && current_user.allowed?
      redirect_to unauthorized_url
    end
  end

  def current_user
    @current_user = current_user_session && current_user_session.record
  end

  def current_institution
    @current_institution ||= current_user.institution
  end
  
  def login_required
    unless logged_in?
      redirect_to unauthorized_url
    end
  end
  
  def logged_in?
    return !current_user_session.nil?
  end

end
