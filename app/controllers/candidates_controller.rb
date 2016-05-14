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
    unless @candidate == current_candidate
      redirect_to :back, :alert => "Access denied."
    end
  end

  def edit
    @candidate = Candidate.find(params[:id])
  end

  def update
    if params[:candidate][:password].blank?
      params[:candidate].delete(:password)
      params[:candidate].delete(:password_confirmation)
    end
    @candidate = Candidate.find(params[:id])
    if @candidate.update_attributes(candidate_params)
      flash[:notice] = "Candidate #{@candidate.candidate_id} updated successfully"
      @candidates = Candidate.all
      render :index
    else
      render edit
    end
  end

  private

  def puts_controller
    puts 'NOdev/CandidatesController before'
  end

  def candidate_params
    params.require(:candidate).permit(:candidate_id, :first_name, :last_name,
                                 :candidate_email, :parent_email_1, :parent_email_2,
                                 :grade, :attending, :password,
                                 :password_confirmation)
  end


  def check_candidate_or_admin_logged_in!
    authenticate_candidate! unless admin_signed_in?
  end

  protected
  def resource_class
    devise_mapping.to
  end

  # Since going around devise mechanisms - add some helpers back in.
  def resource
    instance_variable_get(:"@#{resource_name}")
  end

  # Since going around devise mechanisms - add some helpers back in.
  def resource_name
    devise_mapping.name
  end

  # Since going around devise mechanisms - add some helpers back in.
  def devise_mapping
    Devise.mappings[:candidate]
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
