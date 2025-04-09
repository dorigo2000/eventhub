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
      removed_users = []
  
      if @event.saved_change_to_data_inizio?
        @event.attendees.each do |user|
          overlapping_event = user.subscribed_events.where(data_inizio: @event.data_inizio).where.not(id: @event.id).order(created_at: :desc).first
  
          if overlapping_event
            subscription = Subscription.find_by(event: overlapping_event, user: user)
            if subscription
              subscription.destroy
              removed_users << user.id
  
              Notification.create!(
                user: user,
                event: @event,
                messaggio: "L'scrizione all'evento '#{overlapping_event.nome}' è stata rimossa perché è stato spostato a una data in cui hai già un altro evento."
              )
            end
          end
        end
      end
  
      @event.subscriptions.each do |subscription|
        unless removed_users.include?(subscription.user.id)
          Notification.create!(
            user: subscription.user,
            event: @event,
            messaggio: "L'evento '#{@event.nome}' è stato modificato."
          )
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