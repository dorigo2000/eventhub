class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :event, optional: true

  scope :unread, -> { where(letto: nil) }
end
