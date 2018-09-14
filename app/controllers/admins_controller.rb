# frozen_string_literal: true

require 'prawn'
require 'sendgrid-ruby'

#
# Handles Admin tasks
#
class AdminsController < ApplicationController
  helper_method :sort_column, :sort_direction

  attr_accessor :admins, :confirmation_events, :candidate_info # for testing

  before_action :authenticate_admin!

  # These should only be looked up once
  DELETE = I18n.t('views.common.delete')
  AdminsController::EMAIL = I18n.t('views.nav.email')
  AdminsController::RESET_PASSWORD = I18n.t('views.common.reset_password')
  AdminsController::INITIAL_EMAIL = I18n.t('views.common.initial_email')
  AdminsController::GENERATE_PDF = I18n.t('views.common.generate_pdf')
  AdminsController::CONFIRM_ACCOUNT = I18n.t('views.common.confirm_account')

  # ROUTES

  # edit adhoc email
  #
  # === Attributes:
  #
  # * <tt>:candidate</tt> holder of
  # ** <code>:candidate_ids</code>  candidate ids to update
  # * <tt>:mail</tt> holder of
  # * <tt>:body_input_text</tt> body of text
  # * <tt>:subject_text</tt>  subject of message
  #
  def adhoc_mailing
    subject = t('email.subject_initial_text')
    body = ''
    if params[:mail]
      subject = params[:mail][:subject] || subject
      body = params[:mail][:body_input] || body
    end

    setup_adhoc_render(body, subject)
  end

  # update adhoc email - send email
  #
  # === Attributes:
  #
  # * <tt>:candidate</tt> holder of
  # ** <code>:candidate_ids</code>  candidate ids to update
  # * <tt>:mail</tt> holder of
  # * <tt>:body_input_text</tt> body of text
  # * <tt>:subject_text</tt>  subject of message
  #
  def adhoc_mailing_update
    expected_params = { mail: %i[subject body_input],
                        candidate: [:candidate_ids] }
    missing_params = expected_params.select { |expected_param, _sub_params| params[expected_param].nil? }
    unless missing_params.empty?
      return redirect_to :back, alert: "The following required parameters are missing: #{missing_params}"
    end

    commit = params.require(:commit)

    mail_param = params.require(:mail).permit(:subject, :body_input, :attach_file)

    # mail_param = parm[:mail]
    subject_text = mail_param[:subject]
    body_input_text = mail_param[:body_input]
    attach_file = mail_param[:attach_file]

    candidate_ids = params[:candidate][:candidate_ids]
    candidates = []
    candidate_ids.each { |id| candidates << Candidate.find(id) unless id.empty? }

    if candidates.empty?
      setup_adhoc_render(body_input_text, subject_text)
      flash.now[:alert] = t('messages.no_candidate_selected')
      return render :adhoc_mailing, mail: mail_param
    end

    begin
      send_grid_mail = SendGridMail.new(current_admin, candidates)
      case commit
      when t('email.adhoc_mail')

        flash_message = t('messages.adhoc_mailing_progress')
        response = send_grid_mail.adhoc(subject_text, attach_file, body_input_text)

      when t('email.test_adhoc_mail')

        flash_message = t('messages.adhoc_mailing_test_sent')
        response = send_grid_mail.adhoc_test(subject_text, attach_file, body_input_text)

      else

        return redirect_to :back, alert: "Unknown submit button: #{parm[:commit]}"

      end

      if response.status_code[0] == '2'
        flash.now[:notice] = flash_message
      else
        flash[:alert] = "Status=#{response.status_code} body=#{response.body}"
      end
    rescue StandardError => e
      # puts "adhoc_mailing_update message=#{e.message} backtrace=#{e.backtrace[0...5]}"
      flash[:alert] = "message=#{e.message} backtrace=#{e.backtrace[0...5]}"
      Rails.logger.error("message=#{e.message} backtrace=#{e.backtrace[0...5]}")
    end

    setup_adhoc_render(body_input_text, subject_text)
    render :adhoc_mailing, mail: mail_param
  end

  # edit ConfirmationEvents
  #
  # === Attributes:
  #
  # * <tt>:id</tt> ConfirmationEvent id
  #
  def edit_multiple_confirmation_events
    set_confirmation_events
  end

  # list all admins
  #
  def index
    @admins = Admin.all
  end

  # edit mass candidate events
  #
  # === Attributes:
  #
  # * <tt>:id</tt> ConfirmationEvent id
  #
  def mass_edit_candidates_event
    candidates_info(confirmation_event: ConfirmationEvent.find(params[:id]))
  end

  # updating mass candidate events
  #
  # === Attributes:
  #
  # * <tt>:id</tt> ConfirmationEvent id
  # * <tt>:candidate</tt> holder of
  # ** <code>:candidate_ids</code>  candidate ids to update
  # * <tt>:confirmation_event_attributes</tt> is set
  #
  def mass_edit_candidates_event_update
    confirmation_event = ConfirmationEvent.find(params[:id])
    params.delete(:id)

    candidate_ids = params[:candidate].nil? ? [] : params[:candidate][:candidate_ids]
    candidates = []
    # with upgrade to 5.0 params will remove
    # candidate from params if candidate_ids is empty
    # so we force it to have something.  This is a test only
    # hack - productions does not seem to be a problem.
    candidate_ids.each { |id| candidates << Candidate.find(id) unless id.empty? || id == '-1' }
    if candidates.empty?
      candidates_info(confirmation_event: confirmation_event)
      flash[:notice] = t('messages.no_candidate_selected')
      return render :mass_edit_candidates_event
    end
    params[:confirmation_event_attributes] = { id: confirmation_event.id }
    candidates.each do |candidate|
      candidate_event = candidate.get_candidate_event(confirmation_event.name)

      flash[:notice] = if candidate_event.update(params.permit(CandidateEvent.permitted_params))
                         t('messages.update_candidate_event', account_name: candidate.account_name)
                       else
                         t('messages.not_all_confirmation_events_updated', account_name: candidate.account_name)
                       end
    end

    candidates_info(confirmation_event: confirmation_event)
    params.delete(:verified)
    params.delete(:completed_date)
    render :mass_edit_candidates_event
  end

  # updating mass edit candidates
  #
  # === Attributes:
  #
  # * <tt>:candidate</tt> holder of
  # ** <code>:candidate_ids</code>  candidate ids to update
  # * <tt>:commit</tt> legal values
  # ** <code>AdminsController::DELETE</code>  deletes candidates
  # ** <code>AdminsController::GENERATE_PDF</code>  generates pdf of all info for A candidate
  # ** <code>AdminsController::EMAIL</code> render monthly mass mailing passing candidate_ids as selected_ids
  # ** <code>AdminsController::RESET_PASSWORD</code>  send reset password email to each candidate
  # ** <code>AdminsController::INITIAL_EMAIL</code> send initial email to candidate asking them to confirm their account
  # ** <code>AdminsController::CONFIRM_ACCOUNT</code>  send confirm account email.
  #
  def mass_edit_candidates_update
    candidate_param = params[:candidate]
    candidate_ids = candidate_param ? candidate_param[:candidate_ids] : []
    params.delete(:candidate) if candidate_param
    candidates = []
    candidate_ids.each { |id| candidates << Candidate.find(id) unless id.empty? }

    if candidates.empty?
      redirect_back fallback_location: ref_url, alert: t('messages.no_candidate_selected')
    else
      case params[:commit]
      when AdminsController::DELETE
        candidates.each(&:destroy)
        flash[:notice] = t('messages.candidates_deleted')
        candidates_info
        render 'candidates/index'
      when AdminsController::GENERATE_PDF
        if candidates.size > 1
          redirect_to :back, notice: t('messages.generate_pdf_error')
        else
          pdf = CandidatePDFDocument.new(candidates.first)
          send_data pdf.render,
                    filename: pdf.document_name,
                    type: 'application/pdf'
        end
      when AdminsController::EMAIL
        setup_monthly_mailing_render_default(candidate_ids)
        render :monthly_mass_mailing
      when AdminsController::RESET_PASSWORD
        # This only sends the password reset instructions, the
        # password is not changed. (Recipient has to click link
        # in email and follow instructions to actually change
        # the password).
        send_grid_mail = SendGridMail.new(current_admin, candidates)
        response, _token = send_grid_mail.reset_password
        if response.nil? && Rails.env.test?
          # not connected to the internet
          flash[:notice] = I18n.t('messages.reset_password_message_sent')
        elsif response.status_code[0] == '2'
          flash[:notice] = I18n.t('messages.reset_password_message_sent')
        else
          flash[:alert] = "Status=#{response.status_code} body=#{response.body}"
        end
        redirect_back fallback_location: ref_url
      when AdminsController::INITIAL_EMAIL
        # This only sends the password reset instructions, the
        # password is not changed. (Recipient has to click link
        # in email and follow instructions to actually change
        # the password).
        send_grid_mail = SendGridMail.new(current_admin, candidates)
        response, _token = send_grid_mail.confirmation_instructions
        if response.nil? && Rails.env.test?
          # not connected to the internet
          flash[:notice] = t('messages.initial_email_sent')
        elsif response.status_code[0] == '2'
          flash[:notice] = t('messages.initial_email_sent')
        else
          flash[:alert] = "Status=#{response.status_code} body=#{response.body}"
        end
        redirect_back fallback_location: ref_url, notice: t('messages.initial_email_sent')
      when AdminsController::CONFIRM_ACCOUNT
        confirmed = 0
        candidates.each do |candidate|
          if candidate.account_confirmed?
            Rails.logger.info("Candidate account already confirmed: #{candidate.account_name}")
          else
            candidate.confirm_account
            candidate.save
            confirmed += 1
            Rails.logger.info("Candidate account confirmed: #{candidate.account_name}")
          end
        end
        redirect_back fallback_location: ref_url, notice: t('messages.account_confirmed', number_confirmed: confirmed, number_not_confirmed: candidates.size - confirmed)
      else
        redirect_back fallback_location: ref_url, alert: t('messages.unknown_parameter_commit', commit: params[:commit], params: params)
      end
    end
  end

  # updating and sending monthly mass mailing
  #
  # === Attributes:
  #
  # * <tt>:mail</tt> holder of
  # ** <code>:subject</code>  subject of message
  # ** <code>:pre_late_input</code>
  # ** <code>:pre_coming_due_input</code>
  # ** <code>:completed_awaiting_input</code>
  # ** <code>:completed_input</code>
  # ** <code>:closing_text</code>
  # ** <code>:salutation_text</code>
  # ** <code>:from_text</code>
  # ** <code>:selected_ids</code> Optional
  #
  def monthly_mass_mailing
    subject = t('email.subject_initial_text')
    pre_late_input = t('email.late_initial_text')
    pre_coming_due_input = t('email.coming_due_initial_text')
    completed_awaiting_input = t('email.completed_awaiting_initial_text')
    completed_input = t('email.completed_initial_text')
    closing_text = t('email.closing_initial_text')
    salutation_text = t('email.salutation_initial_text')
    from_text = t('email.from_initial_text_html')
    if params[:mail]
      subject = params[:mail][:subject] || subject
      pre_late_input = params[:mail][:pre_late_input] || pre_late_input
      pre_coming_due_input = params[:mail][:pre_coming_due_input] || pre_coming_due_input
      completed_awaiting_input = params[:mail][:completed_awaiting_input] || completed_awaiting_input
      completed_input = params[:mail][:completed_input] || completed_input
      closing_text = params[:mail][:closing_awaiting_text] || closing_text
      closing_text = params[:mail][:closing_text] || closing_text
      salutation_text = params[:mail][:salutation_text] || salutation_text
      from_text = params[:mail][:from_text] || from_text
    end

    setup_monthly_mailing_render(subject, pre_late_input, pre_coming_due_input, completed_awaiting_input, completed_input, closing_text, salutation_text, from_text)
  end

  # setup default values for monthly mass mailing
  #
  # === Parameters:
  #
  # * <tt>:selected_ids</tt>  Optional
  #
  def setup_monthly_mailing_render_default(selected_ids = [])
    subject = t('email.subject_initial_text')
    pre_late_input = t('email.late_initial_text')
    pre_coming_due_input = t('email.coming_due_initial_text')
    completed_awaiting_input = t('email.completed_awaiting_initial_text')
    completed_input = t('email.completed_initial_text')
    closing_text = t('email.closing_initial_text')
    salutation_text = t('email.salutation_initial_text')
    from_text = t('email.from_initial_text_html')

    setup_monthly_mailing_render(subject, pre_late_input, pre_coming_due_input, completed_awaiting_input, completed_input, closing_text, salutation_text, from_text, selected_ids)
  end

  # prepare for monthly mass mailing
  #
  # === Attributes:
  #
  # * <tt>:subject</tt>  subject of message
  # * <tt>:pre_late_input</tt>
  # * <tt>:pre_coming_due_input</tt>
  # * <tt>:completed_awaiting_input</tt>
  # * <tt>:completed_input</tt>
  # * <tt>:closing_text</tt>
  # * <tt>:salutation_text</tt>
  # * <tt>:from_text</tt>
  # * <tt>:selected_ids</tt> Optional
  #
  def monthly_mass_mailing_update
    expected_params = { mail: %i[subject pre_late_input pre_coming_due_input completed_input salutation_text closing_text from_text],
                        candidate: [:candidate_ids] }
    missing_params = expected_params.select { |expected_param, _sub_params| params[expected_param].nil? }
    unless missing_params.empty?
      return redirect_to :back, alert: "The following required parameters are missing: #{missing_params}"
    end

    commit = params.require(:commit)

    mail_param = params.require(:mail).permit(:subject, :pre_late_input, :pre_coming_due_input, :completed_awaiting_input, :completed_input, :salutation_text, :closing_text, :from_text, :attach_file)

    # mail_param = params[:mail]
    subject_text = mail_param[:subject]
    pre_late_input = mail_param[:pre_late_input]
    pre_coming_due_input = mail_param[:pre_coming_due_input]
    completed_awaiting_input = mail_param[:completed_awaiting_input]
    completed_input = mail_param[:completed_input]
    salutation_text = mail_param[:salutation_text]
    closing_text = mail_param[:closing_text]
    from_text = mail_param[:from_text]
    attach_file = mail_param[:attach_file]

    candidate_ids = params[:candidate][:candidate_ids]
    candidates = []
    candidate_ids.each { |id| candidates << Candidate.find(id) unless id.empty? }

    if candidates.empty?
      setup_monthly_mailing_render(subject_text, pre_late_input, pre_coming_due_input, completed_awaiting_input,
                                   completed_input, closing_text, salutation_text, from_text)
      flash.now[:alert] = t('messages.no_candidate_selected')
      return render :monthly_mass_mailing
    end

    case commit
    when t('email.monthly_mail')

      is_test_mail = false

      flash_message = t('messages.monthly_mailing_progress')

    when t('email.test_monthly_mail')

      is_test_mail = true

      flash_message = t('messages.monthly_mailing_test_sent')

    else

      return redirect_to :back, alert: "Unknown submit button: #{params[:commit]}"

    end

    mail_param = params[:mail]
    send_grid_mail = SendGridMail.new(current_admin, candidates)

    send_mail_response = if is_test_mail
                           send_grid_mail.monthly_mass_mailing_test(mail_param[:subject],
                                                                    attach_file,
                                                                    pre_late_text: mail_param[:pre_late_input],
                                                                    pre_coming_due_text: mail_param[:pre_coming_due_input],
                                                                    completed_awaiting_text: mail_param[:completed_awaiting_input],
                                                                    completed_text: mail_param[:completed_input],
                                                                    closing_text: mail_param[:closing_text],
                                                                    salutation_text: mail_param[:salutation_text],
                                                                    from_text: mail_param[:from_text])
                         else
                           send_grid_mail.monthly_mass_mailing(mail_param[:subject],
                                                               attach_file,
                                                               pre_late_text: mail_param[:pre_late_input],
                                                               pre_coming_due_text: mail_param[:pre_coming_due_input],
                                                               completed_awaiting_text: mail_param[:completed_awaiting_input],
                                                               completed_text: mail_param[:completed_input],
                                                               closing_text: mail_param[:closing_text],
                                                               salutation_text: mail_param[:salutation_text],
                                                               from_text: mail_param[:from_text])
                         end

    flash.now[:notice] = if send_mail_response.status_code[0] == '2'
                           flash_message
                         else
                           "Send emai failed - see logs for more info - last failed response: Status=#{send_mail_response.status_code} body=#{send_mail_response.body}"
                         end

    set_confirmation_events

    setup_monthly_mailing_render(subject_text, pre_late_input, pre_coming_due_input, completed_awaiting_input,
                                 completed_input, closing_text, salutation_text, from_text)
    render :monthly_mass_mailing
  end

  # show visitor editable pages for visitor.
  #
  def show_visitor
    @visitor = visitor_db_or_new
    @visitor = Visitor.create if Visitor.all.empty?
  end

  # update visitor editable pages for visitor.
  #
  # === Attributes:
  #
  # * <tt>:commit</tt>  subject of message
  # * <tt>:visitor</tt>
  # ** <code>views.common.update_home</code>
  # ** <code>views.common.update_about</code>
  # ** <code>views.common.update_contact_information</code>
  #
  def update_visitor
    Rails.logger.info "params=#{params}"
    commit = params.require(:commit)
    case commit
    when t('views.common.update_home')
      visitor = visitor_db_or_new
      if visitor.update(params.require(:visitor).permit(Visitor.basic_permitted_params))
        flash[:notice] = t('messages.home_updated')
      end
    when t('views.common.update_about')
      visitor = visitor_db_or_new
      Rails.logger.info("params.permit(Visitor.basic_permitted_params=#{params.permit(Visitor.basic_permitted_params)}")
      if visitor.update(params.require(:visitor).permit(Visitor.basic_permitted_params))
        flash[:notice] = t('messages.about_updated')
        Rails.logger.info "visitor.about=#{visitor.about}"
      end
    when t('views.common.update_information_contact')
      visitor = visitor_db_or_new
      Rails.logger.info("params.permit(Visitor.basic_permitted_params=#{params.permit(Visitor.basic_permitted_params)}")
      if visitor.update(params.require(:visitor).permit(Visitor.basic_permitted_params))
        flash[:notice] = t('messages.contact_information_updated')
        Rails.logger.info "visitor.contact=#{visitor.contact}"
      end
    else
      flash[:alert] = "Unkown commit param: #{commit}"
    end
    @visitor = visitor_db_or_new
    render :show_visitor
  end

  # show admin
  #
  # === Attributes:
  #
  # * <tt>:id</tt> admin id
  #
  def show
    @admin = Admin.find(params[:id])
  end

  # updates ConfirmationEvents
  #
  # === Attributes:
  #
  # * <tt>:commit</tt> "Update" using <tt>:confirmation_events</tt>
  # * <tt>:confirmation_events</tt>
  # * <tt>:update</tt> should be another value for commit
  #
  def update_multiple_confirmation_events
    if params[:commit] == t('views.common.update')
      confirmation_events = ConfirmationEvent.update(params[:confirmation_events].keys, params[:confirmation_events].values).reject { |p| p.errors.empty? }
      if confirmation_events.empty?
        flash[:notice] = t('messages.confirmation_events_updated')
      else
        flash[:alert] = t('messages.not_all_confirmation_events_updated')
      end
      set_confirmation_events
      render :edit_multiple_confirmation_events
    elsif !params[:update].nil? && params[:update].keys.size == 1 && (params[:update][params[:update].keys[0]] == t('views.common.update_candidates_event'))

      confirmation_event = ConfirmationEvent.find(params[:update].keys[0])

      candidates_info(confirmation_event: confirmation_event)
      render :mass_edit_candidates_event
    else
      flash[:alert] = "Unkown commit param: #{params[:commit]}"
      set_confirmation_events
      render :edit_multiple_confirmation_events
    end
  end

  # setup for monthly mass mailing
  #
  # === Parameters:
  #
  # * <tt>:subject</tt>  subject of message
  # * <tt>:pre_late_input</tt>
  # * <tt>:pre_coming_due_input</tt>
  # * <tt>:completed_awaiting_input</tt>
  # * <tt>:completed_input</tt>
  # * <tt>:closing_text</tt>
  # * <tt>:salutation_text</tt>
  # * <tt>:from_text</tt>
  # * <tt>:selected_ids</tt> Optional
  #
  def setup_monthly_mailing_render(subject, pre_late_input, pre_coming_due_input, completed_awaiting_input, completed_input,
                                   closing_text, salutation_text, from_text, selected_ids = [])
    @subject = subject
    @pre_late_input = pre_late_input
    @pre_coming_due_input = pre_coming_due_input
    @completed_awaiting_input = completed_awaiting_input
    @completed_input = completed_input
    @closing_text = closing_text
    @salutation_text = salutation_text
    @from_text = from_text
    candidates_info(selected_candidate_ids: selected_ids)
  end

  # setup for adhoc email
  #
  # === Parameters:
  #
  # * <tt>:body_input_text</tt> body of text
  # * <tt>:subject_text</tt>  subject of message
  #
  def setup_adhoc_render(body_input_text, subject_text)
    @subject = subject_text
    @body = body_input_text
    candidates_info
  end

  # redirect back to request.referer
  #
  # === Parameters:
  #
  # * <tt>:flash_message</tt> alert too flash upon redirect
  # * <tt>:default_path</tt> go to this if ref_url returns nil
  # * <tt>:mail_params</tt>  mail parameters to merge in for redirect
  #
  def redirect_back_mail(flash_message, default_path, mail_params)
    referrer_url = ref_url

    referrer_url = default_path if referrer_url.nil?

    # append the query string to the  referrer url
    # referrer_url.query returns the existing query string => "f=b"
    # Rack::Utils.parse_nested_query converts query string to hash => {f: "b"}
    # merge appends or overwrites the new parameter  => {f: "b", cp: :foo'}
    referrer_url.query = Rack::Utils.parse_nested_query(referrer_url.query).merge(mail: mail_params).to_query
    # to_query converts hash back to query string => "f=b&cp=foo"

    flash[:alert] = flash_message
    # redirect to the referrer url with the modified query string
    # redirect_back fallback_location: root_path
    redirect_to referrer_url.to_s
  end

  # sorts and sets @confirmation_events
  #
  def set_confirmation_events
    @confirmation_events = ConfirmationEvent.all.sort do |ce1, ce2|
      # sort based on the_way_due_date and then by name ignoring chs_due_date
      if ce1.the_way_due_date.nil?
        if ce2.the_way_due_date.nil?
          ce1.name <=> ce2.name
        else
          -1
        end
      elsif ce2.the_way_due_date.nil?
        1
      else
        due_date = ce1.the_way_due_date <=> ce2.the_way_due_date
        if due_date.zero?
          ce1.name <=> ce2.name
        else
          due_date
        end
      end
    end
  end

  private

  def visitor_db_or_new
    Visitor.first
  end

  def ref_url
    referrer_url = nil
    begin
      # get a URI object for referring url
      referrer_url = URI.parse(request.referer)
    rescue StandardError
      referrer_url = URI.parse(some_default_url)
      # need to have a default in case referrer is not given
    end
    referrer_url
  end
end
