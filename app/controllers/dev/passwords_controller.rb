# frozen_string_literal: true

module Dev
  #
  # Handles Password tasks
  #
  class PasswordsController < Devise::PasswordsController
    # flashes alert if token has expires
    #
    def edit
      original_token = params[:reset_password_token]
      candidate = candidate_from_token(original_token)
      if candidate
        super
      else
        admin = current_admin || Admin.first
        flash[:alert] = ActionView::Base.full_sanitizer.sanitize(
          t('messages.password.token_expired', email: admin.email)
        )
        redirect_to new_session_path(resource_name)
      end
    end

    # setup account_confirmed for super call
    #
    def update
      parms = resource_params
      original_token = parms[:reset_password_token]
      candidate = candidate_from_token(original_token)
      if candidate
        # pass this info to respond_with
        params['candidate']['was_confirmed'] = candidate.account_confirmed?
      end
      super
    end

    # creates flash
    #
    # === Parameters:
    #
    # * <tt>:args</tt> args[0] is a Candidate
    #
    def respond_with(*args)
      raise('PasswordsController.respond_with called with no args') if args.empty?

      candidate = args[0]
      parms = resource_params
      if candidate.respond_to?(:account_confirmed?) && candidate.account_confirmed? && !parms['was_confirmed']
        flash[:notice] = t('messages.password.reset_and_confirmed', name: candidate.account_name)
      else
        Rails.logger.info(
          "respond_with either candidate=#{candidate} is not a candidate or !parms['was_confirmed']=#{!parms[
            'was_confirmed']}"
        )
      end

      if params[:commit] == I18n.t('views.common.reset_password') && resource.errors.any?
        flash[:alert] =
          I18n.t('alert.reset_password_with_help', account_name: parms[:account_name], contact_name: 'Vicki Kristoff',
                                                   contact_email: 'stmm.confirmation@kristoffs.com')
        resource.errors.delete(:account_name) if resource.errors[:account_name]
        resource.errors.add(:account_name, :not_found,
                            message: I18n.t('errors.messages.account_name_not_found', attribute: parms[:account_name]))
      end
      super
    end

    # Lookup candidate based on original-token
    #
    # === Parameters:
    #
    # * <tt>:original_token</tt>
    #
    def candidate_from_token(original_token)
      reset_password_token = Devise.token_generator.digest(self, :reset_password_token, original_token)
      Candidate.find_by(reset_password_token: reset_password_token)
    end
  end
end
