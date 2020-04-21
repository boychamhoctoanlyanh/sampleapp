module SessionsHelper

  # Login with the passed user
  def log_in(user)
    session[:user_id] = user.id
  end

  # Make a user's session persistent
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # Returns true if the passed user is a logged-in user
  def current_user?(user)
    user == current_user
  end

  #Return the currently logged in user (if any)
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end
  
  # Returns true if the user is logged in, false otherwise
  def logged_in?
    !current_user.nil?
  end

  # Destroy a persistent session
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # Log out current user
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  # Redirect to remembered URL (or default value)
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # Remember the URL you tried to access
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end
