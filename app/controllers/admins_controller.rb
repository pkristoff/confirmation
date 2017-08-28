class AdminsController < ApplicationController
  helper_method :sort_column, :sort_direction

  attr_accessor :admins, :confirmation_events, :candidates # for testing

  before_action :authenticate_admin!


  # These should only be looked up once
  DELETE = I18n.t('views.common.delete')
  AdminsController::EMAIL = I18n.t('views.nav.email')
  AdminsController::RESET_PASSWORD = I18n.t('views.common.reset_password')
  AdminsController::INITIAL_EMAIL = I18n.t('views.common.initial_email')

  # ROUTES

  def adhoc_mailing
    set_candidates(params[:sort])
  end

  def adhoc_mailing_update

    expected_params = {mail: [:subject, :body_input],
                       candidate: [:candidate_ids]
    }
    missing_params = expected_params.select {|expected_param, sub_params| params[expected_param].nil?}
    unless missing_params.empty?
      return redirect_to :back, alert: "The following required parameters are missing: #{missing_params}"
    end

    missing_params = []
    expected_params.each do |expected_param, sub_params|
      xxx = params[expected_param]
      missing = sub_params.select {|sub_param| xxx[sub_param].nil?}
      missing_params.push("#{expected_param}: #{missing}") unless missing.empty?
    end
    unless missing_params.empty?
      return redirect_to :back, alert: "The following required parameters are missing: #{missing_params}"
    end

    candidate_ids = params[:candidate][:candidate_ids]
    candidates = []
    candidate_ids.each {|id| candidates << Candidate.find(id) unless id.empty?}

    if candidates.empty?
      return redirect_to :back, alert: t('messages.no_candidate_selected')
    end

    case params[:commit]
      when t('email.mail')

        is_test_mail = false

        flash_message = t('messages.mailing_progress')

      when t('email.test_mail')

        is_test_mail = true

        flash_message = t('messages.mailing_test_sent')

      else

        return redirect_to :back, alert: "Unknown submit button: #{params[:commit]}"

    end

    mail_param = params[:mail]

    begin
      candidates.each_with_index do |candidate, index|
        text = CandidatesMailerText.new(candidate: candidate, subject: mail_param[:subject], body_text: mail_param[:body_input])

        SendEmailJob.perform_in(index*2, candidate, text,
                                current_admin,
                                is_test_mail
        )
      end
    rescue Exception => e
      flash_message = e.message
    end

    flash[:notice] = flash_message

    set_confirmation_events
    render :edit_multiple_confirmation_events

  end

  def edit_multiple_confirmation_events
    set_confirmation_events
  end

  def index
    @admins = Admin.all
  end

  def mass_edit_candidates_event
    # TODO: called via sorting - messed up
    # params[:verified] = "0" unless params[:verified]
    # params[:completed_date] = "" unless params[:completed_date]
    set_candidates(params[:sort], confirmation_event: ConfirmationEvent.find(params[:id]))
  end

  def mass_edit_candidates_event_update
    confirmation_event = ConfirmationEvent.find(params[:id])
    params.delete(:id)

    candidate_ids = params[:candidate][:candidate_ids]
    candidates = []
    candidate_ids.each {|id| candidates << Candidate.find(id) unless id.empty?}
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

    candidate_param = params[:candidate]
    candidate_ids = candidate_param ? candidate_param[:candidate_ids] : []
    params.delete(:candidate) if candidate_param
    candidates = []
    candidate_ids.each {|id| candidates << Candidate.find(id) unless id.empty?}

    if candidates.empty?
      redirect_to :back, alert: t('messages.no_candidate_selected')
    else
      case params[:commit]
        when AdminsController::DELETE
          candidates.each(&:destroy)
          flash[:notice] = t('messages.candidates_deleted')
          set_candidates(params[:sort])
          render 'candidates/index'
        when AdminsController::EMAIL
          set_candidates(params[:sort], selected_candidate_ids: candidate_ids)
          render :monthly_mass_mailing
        when AdminsController::RESET_PASSWORD
          # This only sends the password reset instructions, the
          # password is not changed. (Recipient has to click link
          # in email and follow instructions to actually change
          # the password).
          candidates.each_with_index do | candidate, index |
            SendResetEmailJob.perform_in( index*2, candidate, AdminsController::RESET_PASSWORD)
          end
          redirect_to :back, notice: t('messages.reset_password_message_sent')
        when AdminsController::INITIAL_EMAIL
          # This only sends the password reset instructions, the
          # password is not changed. (Recipient has to click link
          # in email and follow instructions to actually change
          # the password).
          candidates.each_with_index do | candidate, index |
            SendResetEmailJob.perform_in( index*2, candidate, AdminsController::INITIAL_EMAIL)
          end
          redirect_to :back, notice: t('messages.initial_email_sent')
        else
          redirect_to :back, alert: t('messages.unknown_parameter_commit', commit: params[:commit], params: params)
      end
    end
  end

  def monthly_mass_mailing
    set_candidates(params[:sort])
  end

  def monthly_mass_mailing_update

    expected_params = {mail: [:subject, :pre_late_input, :pre_coming_due_input, :completed_input, :salutation_text, :closing_text, :from_text],
                       candidate: [:candidate_ids]
    }
    missing_params = expected_params.select {|expected_param, sub_params| params[expected_param].nil?}
    unless missing_params.empty?
      return redirect_to :back, alert: "The following required parameters are missing: #{missing_params}"
    end

    missing_params = []
    expected_params.each do |expected_param, sub_params|
      xxx = params[expected_param]
      missing = sub_params.select {|sub_param| xxx[sub_param].nil?}
      missing_params.push("#{expected_param}: #{missing}") unless missing.empty?
    end
    unless missing_params.empty?
      return redirect_to :back, alert: "The following required parameters are missing: #{missing_params}"
    end

    candidate_ids = params[:candidate][:candidate_ids]
    candidates = []
    candidate_ids.each {|id| candidates << Candidate.find(id) unless id.empty?}

    if candidates.empty?
      return redirect_to :back, alert: t('messages.no_candidate_selected')
    end

    case params[:commit]
      when t('email.mail')

        is_test_mail = false

        flash_message = t('messages.monthly_mailing_progress')

      when t('email.test_mail')

        is_test_mail = true

        flash_message = t('messages.monthly_mailing_test_sent')

      else

        return redirect_to :back, alert: "Unknown submit button: #{params[:commit]}"

    end

    mail_param = params[:mail]

    begin
      candidates.each_with_index do |candidate, index|
        text = CandidatesMailerText.new(candidate: candidate, subject: mail_param[:subject], pre_late_text: mail_param[:pre_late_input],
                                        pre_coming_due_text: mail_param[:pre_coming_due_input],
                                        completed_text: mail_param[:completed_input], closing_text: mail_param[:closing_text],
                                        salutation_text: mail_param[:salutation_text], from_text: mail_param[:from_text])

        SendEmailJob.perform_in(index*2, candidate, text,
                                current_admin,
                                is_test_mail
        )
      end
    rescue Exception => e
      flash_message = e.message
    end

    flash[:notice] = flash_message

    set_confirmation_events
    render :edit_multiple_confirmation_events

  end

  def show
    @admin = Admin.find(params[:id])
  end

  def update_multiple_confirmation_events
    if params[:commit] === t('views.common.update')
      confirmation_events = ConfirmationEvent.update(params[:confirmation_events].keys, params[:confirmation_events].values).reject {|p| p.errors.empty?}
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
