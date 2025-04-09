class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :event

  after_create :check_max_participants
  
  validates :user_id, uniqueness: { scope: :event_id, message: "Sei già iscritto a questo evento!" }
  validate :no_conflicting_events

  private

  def no_conflicting_events
    overlapping_events = user.subscribed_events.where("data_inizio = ?", event.data_inizio)
    
    if overlapping_events.exists?
      errors.add(:base, "Impossibile effettuare l'iscrizione, sei già iscritto a un evento nella stessa data!")
    end
  end

  def check_max_participants
    if event.subscriptions.count >= event.max_partecipanti
      Notification.create(
        user: event.user,
        event: event,
        messaggio: "L'evento '#{event.nome}' ha raggiunto il numero massimo di partecipanti."
      )
    end
  end
end
