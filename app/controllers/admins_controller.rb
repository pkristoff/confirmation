class AdminsController < ApplicationController
  helper_method :sort_column, :sort_direction

  attr_accessor :admins, :confirmation_events, :candidates # for testing

  before_action :authenticate_admin!

  # ROUTES

  def edit_multiple_confirmation_events
    set_confirmation_events
  end

  def index
    @admins = Admin.all
  end

  def mass_edit_candidates_event
    params[:verified] = "0" unless params[:verified]
    params[:completed_date] = "" unless params[:completed_date]
    set_candidates(params[:sort], confirmation_event: ConfirmationEvent.find(params[:id]))

  end

  def mass_edit_candidates_event_update
    confirmation_event = ConfirmationEvent.find(params[:id])
    params.delete(:id)

    candidate_ids = params[:candidate][:candidate_ids]
    candidates = []
    candidate_ids.each { |id| candidates << Candidate.find(id) unless id.empty? }
    if candidates.empty?
      set_candidates(params[:sort], confirmation_event: confirmation_event)
      flash[:notice] = t('messages.no_candidate_selected')
      return render :mass_edit_candidates_event
    end
    params[:confirmation_event_attributes] = {id: confirmation_event.id}
    candidates.each do |candidate|
      candidate_event = candidate.get_candidate_event(confirmation_event.name)

      if candidate_event.update_attributes(params.permit(CandidateEvent.get_permitted_params))
        flash[:notice] = t('messages.update_candidate_event', account_name: candidate.account_name)
      else
        flash[:notice] = t('messages.not_all_confirmation_events_updated', account_name: candidate.account_name)
      end
    end

    set_candidates(params[:sort], confirmation_event: confirmation_event)
    params.delete(:verified)
    params.delete(:completed_date)
    render :mass_edit_candidates_event
  end

  def mass_edit_candidates_update

    candidate_ids = params[:candidate][:candidate_ids]
    candidate_ids.delete('')
    candidates = []
    candidate_ids.each { |id| candidates << Candidate.find(id) unless id.empty? }

    if params[:commit] === 'delete'
      candidates.each do |candidate|
        candidate.destroy
      end
      if candidate_ids.empty?
        flash[:alert] = t('messages.no_candidate_selected')
      else
        flash[:notice] = t('messages.candidates_deleted')
      end
      set_candidates(params[:sort])
      render 'candidates/index'
    elsif params[:commit] === 'email'
      if candidate_ids.empty?
        redirect_to :back, alert: t('messages.no_candidate_selected')
      else
        set_candidates(params[:sort], selected_candidate_ids: candidate_ids)
        render :monthly_mass_mailing
      end
    else
      redirect_to :back, alert: t('messages.unknown_parameter_commit', commit: params[:commit], params: params)
    end

  end

  def monthly_mass_mailing
    set_candidates(params[:sort])
  end

  def monthly_mass_mailing_update

    candidate_ids = params[:candidate][:candidate_ids]
    candidates = []
    candidate_ids.each { |id| candidates << Candidate.find(id) unless id.empty? }

    candidates.each do |candidate|
      @candidate = candidate
      deliver_mail_to_candidate(candidate, params[:pre_late_input], params[:pre_coming_due_input], params[:completed_input])
    end

    flash[:notice] = t('messages.monthly_mailing_progress')
    set_confirmation_events
    render :edit_multiple_confirmation_events

  end

  def show
    @admin = Admin.find(params[:id])
  end

  def update_multiple_confirmation_events
    if params[:commit] === t('views.common.update')
      confirmation_events = ConfirmationEvent.update(params[:confirmation_events].keys, params[:confirmation_events].values).reject { |p| p.errors.empty? }
      if confirmation_events.empty?
        flash[:notice] = t('messages.confirmation_events_updated')
      else
        flash[:alert] = t('messages.not_all_confirmation_events_updated')
      end
      set_confirmation_events
      render :edit_multiple_confirmation_events
    else
      confirmation_event = ConfirmationEvent.find(params[:update].keys[0])

      set_candidates(params[:sort], confirmation_event: confirmation_event)
      render :mass_edit_candidates_event
    end

  end

  # helper methods

  def deliver_mail_to_candidate(candidate, pre_late_input, pre_coming_due_input, completed_input)
    mailer = CandidatesMailer.monthly_reminder(candidate, pre_late_input, pre_coming_due_input, completed_input)
    mailer.deliver_now
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
