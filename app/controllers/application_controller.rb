class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :exception
    before_action :authenticate_user!
    helper_method :user_signed_in?, :current_user
    
#    protected
    
#    def authenticate_user
#      cookies.delete(:user_id) && redirect_to(root_url) if current_user.blank?
#    end
#    def current_user
#      @current_user ||= User.find_by(id: cookies.signed[:user_id])
#    end
#    def user_signed_in?
#      current_user.present?
#    end

    private

    def current_user
      @current_user ||= User.find(session[:user_id]) if session[:user_id]

    end
    
    helper_method :current_user
 end
