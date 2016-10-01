class AdminsController < ApplicationController
  helper_method :sort_column, :sort_direction

  attr_accessor :admins, :confirmation_events, :candidates # for testing

  before_action :authenticate_admin!

  def edit_multiple_confirmation_events
    set_confirmation_events
  end

  def email_candidate
    @candidate = Candidate.find(params[:id])
    setup_email_candidate
  end

  # matches Candidate_mailer#monthly_reminder
  def setup_email_candidate
    @late_events = @candidate.get_late_events
    @coming_due_events = @candidate.get_coming_due_events
    @completed_events = @candidate.get_completed
  end

  def email_candidate_update
    @candidate = Candidate.find(params[:id])
    mailer = CandidatesMailer.monthly_reminder(@candidate, params[:pre_late_input], params[:pre_verify_input], params[:pre_coming_due_input], params[:completed_input])
    mailer.deliver_now

    setup_email_candidate
    flash[:notify] = "Delivered to #{@candidate.candidate_sheet.first_name} #{@candidate.candidate_sheet.last_name}"
    render :email_candidate
  end

  def index
    @admins = Admin.all
  end

  def mass_edit_candidates_event
    @confirmation_event = ConfirmationEvent.find(params[:id])

    set_candidates

  end

  def mass_edit_candidates_event_update
    @confirmation_event = ConfirmationEvent.find(params[:id])
    params.delete(:id)

    candidate_ids = params[:candidate][:candidate_ids]
    candidates = []
    candidate_ids.each { |id| candidates << Candidate.find(id) unless id.empty? }
    params[:confirmation_event_attributes] = {id: @confirmation_event.id}
    candidates.each do |candidate|
      candidate_event = candidate.get_candidate_event(@confirmation_event.name)

      if candidate_event.update_attributes(params.permit(CandidateEvent.get_permitted_params))
        flash[:notice] = "Updated CandidateEvent! #{candidate.account_name}"
      else
        flash[:notice] = "NOT Updated CandidateEvent! #{candidate.account_name}"
      end
    end

    set_candidates
    render :mass_edit_candidates_event
  end

  def show
    @admin = Admin.find(params[:id])
  end

  def update_multiple_confirmation_events
    if params[:commit] === t('views.common.update')
      confirmation_events = ConfirmationEvent.update(params[:confirmation_events].keys, params[:confirmation_events].values).reject { |p| p.errors.empty? }
      if confirmation_events.empty?
        flash[:notice] = "Updated ConfirmationEvents!"
      else
        flash[:alert] = "Not all ConfirmationEvents updated"
      end
      set_confirmation_events
      render :edit_multiple_confirmation_events
    else
      @confirmation_event = ConfirmationEvent.find(params[:update].keys[0])

      set_candidates
      render :mass_edit_candidates_event
    end

  end

  def set_candidates
    sc = sort_column(params[:sort])
    sc_split = sc.split('.')
    if sc_split.size === 2
      if sc_split[0] === 'candidate_sheet'
        @candidates = Candidate.joins(:candidate_sheet).order("candidate_sheets.#{sc_split[1]} #{sort_direction(params[:direction])}").all
      else
        flash[:alert] = "Unknown sort_column: #{sc}"
      end
    else
      if sc_split[0] === 'completed_date'
        @candidates = Candidate.joins(candidate_events: :confirmation_event)
                          .where(confirmation_events: {name: @confirmation_event.name})
                          .order("candidate_events.completed_date #{sort_direction(params[:direction])}")
      else
        @candidates = Candidate.order("#{sc} #{sort_direction(params[:direction])}").all
      end
    end
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
