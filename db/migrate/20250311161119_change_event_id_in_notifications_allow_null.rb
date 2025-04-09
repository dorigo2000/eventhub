class ChangeEventIdInNotificationsAllowNull < ActiveRecord::Migration[7.1]
  def change
    change_column_null :notifications, :event_id, true
  end  
end
