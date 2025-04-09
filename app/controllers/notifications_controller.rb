class NotificationsController < ApplicationController
  before_action :set_current_user

  def index
    @notifications = Current.user.notifications.order(created_at: :desc)
  end

  def mark_as_read
    @notification = Notification.find(params[:id])
    @notification.update(letto: true)

    redirect_to events_path
  end
end
