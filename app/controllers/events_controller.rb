class EventsController < ApplicationController
  before_action :require_login

  def index
    @events = Event.where("data_inizio >= ?", Date.today).order(:data_inizio, :orario_inizio)

    if params[:search_city].present?
      @events = @events.where("LOWER(paese) LIKE ?", "%#{params[:search_city].downcase}%")
    end
  end

  def my_events
    @events = Current.user.events.order(Arel.sql("CASE WHEN data_inizio >= CURRENT_DATE THEN 0 ELSE 1 END, data_inizio ASC, orario_inizio ASC"))
  end

  def new
    @event = Event.new
  end

  def create
    @event = Current.user.events.new(event_params)

    if @event.save
      redirect_to events_path, notice: "Evento creato con successo!"
    else
      render :new
    end
  end

  def edit
    @event = Event.find(params[:id])
  end

  def update
    @event = Event.find(params[:id])
  
    if @event.update(event_params)
      users_notifications = Set.new

      if @event.saved_change_to_data_inizio? || @event.saved_change_to_data_fine?
        @event.attendees.each do |user|
          current_event_subscription = user.subscriptions.find_by(event: @event)

          overlapping_subscription_to_remove = user.subscriptions
                                                   .joins(:event)
                                                   .where.not(subscriptions: { id: current_event_subscription&.id })
                                                   .where(
                                                     "events.data_fine >= ? AND ? >= events.data_inizio",
                                                     @event.data_inizio,
                                                     @event.data_fine
                                                   )
                                                   .order(created_at: :desc)
                                                   .first

          if current_event_subscription && (current_event_subscription.created_at > overlapping_subscription_to_remove.created_at)
            subscription_to_destroy = current_event_subscription
            event_notification = @event
            message = "L'iscrizione all'evento '#{@event.nome}' è stata rimossa perché si sovrappone con l'evento '#{overlapping_subscription_to_remove.event.nome}' ed era la più recente."
          else
            subscription_to_destroy = overlapping_subscription_to_remove
            event_notification = overlapping_subscription_to_remove.event
            message = "L'iscrizione all'evento '#{overlapping_subscription_to_remove.event.nome}' è stata rimossa perché l'evento '#{@event.nome}' è stato spostato e si sovrappone."
          end

          if subscription_to_destroy && subscription_to_destroy.destroy
            users_notifications.add(user.id)
            Notification.create!(
              user: user,
              event: event_notification,
              messaggio: message
            )
          end
        end
      end

      redirect_to my_events_events_path, notice: "Evento modificato con successo!"
    else
      render :edit
    end
  end

  

  def destroy
    @event = Event.find(params[:id])

    @event.subscriptions.each do |subscription|
      Notification.create(
        user: subscription.user,
        event: @event,
        messaggio: "L'evento '#{@event.nome}' è stato cancellato dall'organizzatore."
      )
    end
    
    @event.destroy
    redirect_to my_events_events_path, notice: "Evento eliminato con successo!"
  end

  def participants 
    @event = Event.find(params[:id])
    @participants  = @event.attendees
  end

  def remove_participant
    @event = Event.find(params[:id])
    @participant = User.find(params[:participant_id])
    @user = User.find(params[:participant_id])
    
    if @event.attendees.delete(@participant)
      flash[:notice] = "#{@user.nome} #{@user.cognome} è stato rimosso dall'evento."
      Notification.create(
        user: @user,
        event: @event,
        messaggio: "Sei stato rimosso dall'evento '#{@event.nome}'."
      )
    end

    redirect_to participants_event_path(@event)
  end 

  private

  def require_login
    unless session[:user_id]
      redirect_to root_path
    end
  end

  def event_params
    params.require(:event).permit(:nome, :data_inizio, :orario_inizio, :data_fine, :orario_fine, :paese, :indirizzo, :max_partecipanti)
  end
end