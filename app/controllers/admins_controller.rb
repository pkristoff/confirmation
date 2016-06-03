class AdminsController < ApplicationController

  attr_accessor :admins # for testing

  before_action :authenticate_admin!

  def index
    @admins = Admin.all
  end

  def show
    @admin = Admin.find(params[:id])
    unless @admin == current_admin
      redirect_to :back, :alert => 'Access denied.'
    end
  end

  def events
    @confirmation_events = ConfirmationEvent.all
  end

  def events_update
    @confirmation_event = ConfirmationEvent.find(params[:id])
    if @confirmation_event.update_attributes(confirmation_event_params)
      flash[:notice] = "Candidate #{@confirmation_event.name} updated successfully"
      @confirmation_events = ConfirmationEvent.all
      render :events
    else
      render edit
    end
  end

  private

  def confirmation_event_params
    params.require(:confirmation_event).permit([:name, :due_date])
  end

end
