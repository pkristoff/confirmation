class AdminsController < ApplicationController
  helper_method :sort_column, :sort_direction

  attr_accessor :admins, :confirmation_events, :candidates # for testing

  before_action :authenticate_admin!

  def edit_multiple_confirmation_events
    set_confirmation_events
  end

  # def email_candidate
  #   @candidate = Candidate.find(params[:id])
  #   setup_email_candidate
  # end
  #
  # # matches Candidate_mailer#monthly_reminder
  # def setup_email_candidate
  #   @late_events = @candidate.get_late_events
  #   @coming_due_events = @candidate.get_coming_due_events
  #   @completed_events = @candidate.get_completed
  # end
  #
  # def email_candidate_update
  #   candidate = Candidate.find(params[:id])
  #   deliver_mail_to_candidate(candidate)
  #
  #   flash[:notify] = t('messages.email_delivered', first_name: candidate.candidate_sheet.first_name, last_name: candidate.candidate_sheet.last_name)
  #   set_candidates
  #   render 'candidates/index'
  # end

  def deliver_mail_to_candidate(candidate)
    mailer = CandidatesMailer.monthly_reminder(candidate, params[:pre_late_input], params[:pre_coming_due_input], params[:completed_input])
    mailer.deliver_now
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
        flash[:notice] = t('messages.update_candidate_event', account_name: candidate.account_name)
      else
        flash[:notice] = t('messages.not_all_confirmation_events_updated', account_name: candidate.account_name)
      end
    end

    set_candidates
    render :mass_edit_candidates_event
  end

  def monthly_mass_mailing
    set_candidates
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
      set_candidates
      render 'candidates/index'
    elsif params[:commit] === 'email'
      if candidate_ids.empty?
        redirect_to :back, alert: t('messages.no_candidate_selected')
      else
        set_candidates(candidate_ids)
        render :monthly_mass_mailing
      end
    else
      redirect_to :back, alert: t('messages.unknown_parameter_commit', commit: params[:commit], params: params)
    end

  end

  def monthly_mass_mailing_update

    candidate_ids = params[:candidate][:candidate_ids]
    candidates = []
    candidate_ids.each { |id| candidates << Candidate.find(id) unless id.empty? }

    candidates.each do |candidate|
      @candidate = candidate
      deliver_mail_to_candidate(candidate)
    end

    flash[:notice] = t('messages.monthly_mailing_progress')
    # set_candidates
    # render :monthly_mass_mailing
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
      @confirmation_event = ConfirmationEvent.find(params[:update].keys[0])

      set_candidates
      render :mass_edit_candidates_event
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
