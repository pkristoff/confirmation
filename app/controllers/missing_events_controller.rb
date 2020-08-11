# frozen_string_literal: true

#
# MissingEventsController
#
class MissingEventsController < ApplicationController
  # Checks for missing ConfirmationEvents if :missing is supplied then update system with missing
  # ConfirmationEvents.
  #
  # === Attributes:
  #
  # * <tt>:commit</tt> legal values
  # ** <code>views.missing_events.check_events</code>  Check to see if all ConfirmationEvents are present
  # ** <code>views.missing_events.add_missing</code> legal values
  # *** <code>:missing</code> list of missing events
  #
  def check
    case params[:commit]
    when t('views.missing_events.check')
      check_for_missing
    when t('views.missing_events.add_missing')
      add_missing
    else
      # initial call to check.html.erb
      check_for_missing
    end
  end

  private

  def check_for_missing
    @missing_events = MissingEvents.new.check_missing_events
  end

  def add_missing
    if params[:missing_events][:missing] == ''
      flash[:alert] = t('views.missing_events.check_events_first')
      @missing_events = MissingEvents.new
    else
      flash[:notice] = t('views.missing_events.added_missing')
      @missing_events = MissingEvents.new.add_missing(params[:missing_events][:missing].split(':'))
    end
    render missing_events_check_path
  end
end
