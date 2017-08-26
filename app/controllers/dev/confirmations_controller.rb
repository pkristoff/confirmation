module Dev
  class ConfirmationsController < Devise::ConfirmationsController

    # copied from parent class
    def show
      self.resource = resource_class.confirm_by_token(params[:confirmation_token])
      yield resource if block_given?

      # if resource.errors.empty?
        # set_flash_message!(:notice, :confirmed, account: resource.account_name)
        respond_with_navigational(resource.errors, resource) {redirect_to after_confirmation_path_for(resource, resource_name, resource.errors)}
      #   return
      # else
      #   respond_with_navigational(resource) {redirect_to after_confirmation_path_for(resource_name, resource)}
      #   return
      # end
    end

    protected

    def after_confirmation_path_for(resource, resource_name, errors)
      msgs = ''
      errors.full_messages.each {|msg| msgs += "#{msg}"}
      # msgs cannot be empty
      msgs += 'noerrors' if msgs.empty?
      # resource.id cannot be nil
      my_candidate_confirmation_path(resource.id ? resource.id : -1, msgs)
    end

  end
end