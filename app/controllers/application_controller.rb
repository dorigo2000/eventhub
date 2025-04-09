class ApplicationController < ActionController::Base
  before_action :set_current_user
  before_action :set_notifications

  def set_current_user
    if session[:user_id]
        Current.user = User.find_by(id: session[:user_id])
    end
  end

  def set_notifications
    @notifications = Current.user.notifications.where(letto: false) if set_current_user
  end
end