module Dev
class CandidatesController < ApplicationController

  helper DeviseHelper

  helpers = %w(resource scope_name resource_name signed_in_resource
               resource_class resource_params devise_mapping)
  helper_method(*helpers)

  attr_accessor :candidates # for testing
  attr_accessor :candidate # for testing

  before_action :puts_controller
  before_action :authenticate_candidate!

  def index
    @candidates = Candidate.all
  end

  def show
    @candidate = Candidate.find(params[:id])
  end

  def edit
    @candidate = Candidate.find(params[:id])
  end

  def update

    if params[:candidate][:password].blank?
      params[:candidate].delete(:password)
      params[:candidate].delete(:password_confirmation)
    end

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

  def puts_controller
    puts 'dev/CandidatesController before'
  end

end
end