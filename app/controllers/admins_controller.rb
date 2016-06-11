class AdminsController < ApplicationController

  attr_accessor :admins # for testing

  before_action :authenticate_admin!

  def index
    @admins = Admin.all
  end

  def show
    @admin = Admin.find(params[:id])
  end

  def events
    set_confirmation_events
  end

  def events_update
    @confirmation_event = ConfirmationEvent.find(params[:id])
    if @confirmation_event.update_attributes(confirmation_event_params)
      flash[:notice] = I18n.t('messages.event_updated', name: @confirmation_event.name)
      set_confirmation_events
      render :events
    else
      render edit
    end
  end

  private

  def confirmation_event_params
    params.require(:confirmation_event).permit([:name, :due_date, :instructions])
  end

  def set_confirmation_events
    @confirmation_events = ConfirmationEvent.all.sort do |ce1, ce2|
      # sort based on due_date and then by name
      if ce1.due_date.nil?
        if ce2.due_date.nil?
          ce1.name <=> ce2.name
        else
          -1
        end
      else
        if ce2.due_date.nil?
          1
        else
          due_date = ce1.due_date <=> ce2.due_date
          if due_date == 0
            ce1.name <=> ce2.name
          else
            due_date
          end
        end
      end
    end
  end

end
