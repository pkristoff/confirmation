module Dev
  class PasswordsController < Devise::PasswordsController

    def edit
      original_token = params[:reset_password_token]
      candidate = candidate_from_token(original_token)
      if candidate
        super
      else
        flash[:alert] = ActionView::Base.full_sanitizer.sanitize(t('messages.password.token_expired'))
        redirect_to new_session_path(resource_name)
      end
    end

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

    def respond_with(*args)
      if args.size > 0
        candidate = args[0]
        parms = resource_params
        if candidate.account_confirmed? && !parms['was_confirmed']
          flash[:notice] = t('messages.password.reset_and_confirmed', name: candidate.account_name)
        end
      else
        raise('PasswordsController.respond_with called with no args')
      end
      super
    end

    def candidate_from_token(original_token)
      reset_password_token = Devise.token_generator.digest(self, :reset_password_token, original_token)
      candidate = Candidate.find_by_reset_password_token(reset_password_token)
    end

  end
end