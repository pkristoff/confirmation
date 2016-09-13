class AdminsController < ApplicationController

  attr_accessor :admins, :confirmation_events # for testing

  before_action :authenticate_admin!

  def index
    @admins = Admin.all
  end

  def show
    @admin = Admin.find(params[:id])
    end

  def edit_multiple_confirmation_events
    set_confirmation_events
  end

  def update_multiple_confirmation_events
    confirmation_events = ConfirmationEvent.update(params[:confirmation_events].keys, params[:confirmation_events].values).reject { |p| p.errors.empty? }
    if confirmation_events.empty?
      flash[:notice] = "Updated ConfirmationEvents!"
    else
      flash[:alert] = "Not all ConfirmationEvents updated"
    end
    set_confirmation_events
    render :edit_multiple_confirmation_events
  end

  def set_confirmation_events
    @confirmation_events = ConfirmationEvent.all.sort do |ce1, ce2|
      # sort based on the_way_due_date and then by name ignoring chs_due_date
      if ce1.the_way_due_date.nil?
        if ce2.the_way_due_date.nil?
          ce1.name <=> ce2.name
        else
          -1
        end
      else
        if ce2.the_way_due_date.nil?
          1
        else
          due_date = ce1.the_way_due_date <=> ce2.the_way_due_date
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
