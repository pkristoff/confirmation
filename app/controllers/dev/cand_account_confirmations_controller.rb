# frozen_string_literal: true

module Dev
  #
  # Handles Confirmation tasks
  #
  class CandAccountConfirmationsController < Devise::ConfirmationsController
    # Confirms user(account)
    # copied from parent class
    # ==== Attributes
    #
    # * +confirmation_token+ - Token from email link
    #
    def show
      self.resource = resource_class.confirm_by_token(params[:confirmation_token])
      yield resource if block_given?

      respond_with_navigational(resource.errors, resource) { redirect_to after_confirmation_path_for(resource, resource_name, resource.errors) }
    end

    # Looks at email provided to make sure associate with a candidate.  If so send initial message.
    #
    # ==== Attributes
    #
    # * candidate.email
    #
    def create
      email = params['candidate']['email']
      cs = CandidateSheet.find_by(candidate_email: email)
      cs = CandidateSheet.find_by(parent_email_1: email) if cs.blank?
      cs = CandidateSheet.find_by(parent_email_2: email) if cs.blank?
      flash[:alert] = "email not associated candidate: #{email}" if cs.blank?
      return redirect_to '/dev/candidates/sign_in', params if cs.blank?

      candidate = Candidate.find_by(candidate_sheet_id: cs.id)
      send_grid_mail = SendGridMail.new(current_admin, [candidate])
      response, _token = send_grid_mail.confirmation_instructions
      if response.nil? && Rails.env.test?
        # not connected to the internet
        flash[:notice] = t('messages.initial_email_sent')
      elsif response.status_code[0] == '2'
        flash[:notice] = t('messages.initial_email_sent')
      else
        flash[:alert] = "Status=#{response.status_code} body=#{response.body}"
      end
      redirect_to '/dev/candidates/sign_in', params
    end

    protected

    # Where to go after user(account) is confirmed
    # ==== Attributes
    #
    # * +resource+ - candidate
    # * +resource_name+ - candidate class name
    # * +errors+ - Errors gathered while confirming account
    #
    def after_confirmation_path_for(resource, _resource_name, errors)
      msgs = ''
      errors.full_messages.each { |msg| msgs += msg.to_s }
      # msgs cannot be empty
      msgs += 'noerrors' if msgs.empty?
      # resource.id cannot be nil
      cand_account_confirmation_path(resource.id || -1, msgs)
    end
  end
end
