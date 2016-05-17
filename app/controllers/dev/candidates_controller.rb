module Dev
  class CandidatesController < ApplicationController

    # CANDIDATE ONLY

    helper DeviseHelper

    helpers = %w(resource scope_name resource_name signed_in_resource
               resource_class resource_params devise_mapping)
    helper_method(*helpers)

    attr_accessor :candidates # for testing
    attr_accessor :candidate # for testing
    before_action :authenticate_candidate!

    def index
      unless admin_signed_in?
        return redirect_to :back, :alert => "Please login as admin to see list of candidates."
      end
    end

    def destroy
      puts "I am here"
    end

    def edit
      @candidate = Candidate.find(params[:id])
    end

    def show
      @candidate = Candidate.find(params[:id])
      unless @candidate == current_candidate
        redirect_to :back, :alert => "Access denied."
      end

      # set_flash_message(:notice, :confirmed) if is_flashing_format?
      # respond_with_navigational(resource) { redirect_to after_confirmation_path_for(resource_name, resource) }
    end

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_in) do |user_params|
        user_params.permit(:candidate_id, :parent_email_1)
      end
      devise_parameter_sanitizer.permit(:sign_in) do |user_params|
        user_params.permit(:candidate_id, :parent_email_1)
      end
      devise_parameter_sanitizer.permit(:account_update) do |user_params|
        user_params.permit(:candidate_id, :parent_email_1)
      end
    end

  end
end