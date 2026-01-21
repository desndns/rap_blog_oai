module Authentication
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :logged_in?, :admin?
  end

  private

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = User.find_by(id: session[:user_id])
  end

  def logged_in?
    current_user.present?
  end

  def admin?
    current_user&.admin?
  end

  def require_login
    return if logged_in?

    redirect_to login_path, alert: "Please sign in to continue."
  end

  def require_admin
    return if admin?

    redirect_to root_path, alert: "Admin access required."
  end
end
