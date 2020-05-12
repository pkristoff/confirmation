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

      respond_with_navigational(resource.errors, resource) do
        redirect_to after_confirmation_path_for(resource, resource_name, resource.errors)
      end
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
