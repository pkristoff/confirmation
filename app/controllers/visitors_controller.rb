# frozen_string_literal: true

#
# Handles Admin tasks
#
class VisitorsController < ApplicationController
  # setup for about page on the top menu bar.
  #
  def about
    @visitor = Visitor.first
  end

  # setup for about app page in help menu
  #
  def about_app
    @visitor = Visitor.first
  end

  # setup for contact in help menu
  #
  def contact
    @visitor = Visitor.first
  end

  # redirect to appropriate routing depending who is logged in.
  #
  def index
    if candidate_signed_in?
      redirect_to dev_candidate_path(current_candidate.id)
    elsif admin_signed_in?
      redirect_to admin_path(current_admin.id)
    end
    @candidate = nil
    @visitor = Visitor.first
  end

  # If id == -1 then create a new candidate otherwise find one.
  #
  # === Attributes
  #
  # * <tt>:id</tt> Candidate id
  # * <tt>:erros</tt>
  #
  def cand_account_confirmation
    @candidate = params[:id].to_i.equal?('-1'.to_i) ? Candidate.create : Candidate.find(params[:id])
    @errors = params[:errors]

    # need admin contact info even though candidate or no one is logged in
    admin = current_admin || Admin.first unless @errors && @errors != 'noerrors'
    send_grid_mail = SendGridMail.new(admin, [@candidate]) unless @errors && @errors != 'noerrors'
    response, _token = send_grid_mail.reset_password unless @errors && @errors != 'noerrors'
    if response.nil? && Rails.env.test?
      # not connected to the internet while testing
      flash[:notice] = I18n.t('messages.reset_password_message_sent') unless @errors && @errors != 'noerrors'
    elsif response.nil? && @errors && @errors != 'noerrors'
      flash[:alert] = @errors
    elsif response.status_code[0] == '2'
      flash[:notice] = I18n.t('messages.reset_password_message_sent') unless @errors && @errors != 'noerrors'
    else
      flash[:alert] = "Status=#{response.status_code} body=#{response.body}" unless @errors && @errors != 'noerrors'
    end

    sign_out current_admin if admin_signed_in?
  end

  # Validate if email is a valid email address.
  #
  # Looks at email provided to make sure associate with a candidate.  If so send initial message.
  #
  # ==== Attributes
  #
  # * email
  #
  def resend_confirmation_instructions
    email = params['email']

    unless VisitorsController.validate_email(email)
      flash[:alert] = t('views.candidates.confirm_account.resend.email.no†_found.flash.alert',
                        email: email)
    end
    return redirect_to '/dev/candidates/sign_in', params unless VisitorsController.validate_email(email)

    cs = CandidateSheet.find_by(candidate_email: email)
    cs = CandidateSheet.find_by(parent_email_1: email) if cs.blank?
    cs = CandidateSheet.find_by(parent_email_2: email) if cs.blank?
    flash[:alert] = I18n.t('views.candidates.confirm_account.resend.email.no†_found.flash.alert', email: email) if cs.blank?
    return redirect_to '/dev/candidates/sign_in', params if cs.blank?

    candidate = Candidate.find_by(candidate_sheet_id: cs.id)
    flash[:alert] = I18n.t('views.candidates.confirm_account.resend.email.not_valid.flash.alert', email: email) if candidate.nil?
    return redirect_to '/dev/candidates/sign_in', params if candidate.nil?

    admin = current_admin || Admin.all.first
    send_grid_mail = SendGridMail.new(admin, [candidate])
    response, _token = send_grid_mail.confirmation_instructions
    if response.nil? && Rails.env.test?
      # not connected to the internet
      flash[:notice] = t('views.candidates.confirm_account.resend.email.notice.confirmation_sent')
    elsif response.status_code[0] == '2'
      flash[:notice] = t('views.candidates.confirm_account.resend.email.notice.confirmation_sent')
    else
      flash[:alert] = "Status code=#{response.status_code} body=#{response.body}"
    end
    redirect_to '/dev/candidates/sign_in', params
  end

  # Validate if email is a valid email addrress.
  #
  # === Parameters:
  #
  # * <tt>:email</tt> String
  #
  def self.validate_email(email)
    return false if email.blank?

    email =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  end

  # Devise method
  #
  # === Returns:
  #
  # * <tt>Candidate</tt>
  #
  def resource
    @candidate
  end
end
