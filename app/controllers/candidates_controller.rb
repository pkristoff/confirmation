class CandidatesController < CommonCandidatesController

  # ADMIN ONLY

  helper DeviseHelper

  helpers = %w(resource scope_name resource_name signed_in_resource
               resource_class resource_params devise_mapping)
  helper_method(*helpers)

  attr_accessor :candidates # for testing
  attr_accessor :candidate # for testing

  before_action :authenticate_admin!

  def destroy
    @candidate = Candidate.find(params[:id])
    @candidate.destroy
    flash[:notice] = I18n.t('messages.candidate_removed', name: candidate.account_name)
    @candidates = Candidate.all
    render :index
  end

  def edit
    @candidate = Candidate.find(params[:id])
    @resource = @candidate
  end

  def event
    @resource = Candidate.find(params[:id])
  end

  def index
    @candidates = Candidate.sorting_table(params, :account_name).all
  end
  def is_admin?
    false
  end

  def new
    @resource = AppFactory.create_candidate
  end

  def show
    @candidate = Candidate.find(params[:id])
  end

  def update
    if params[:candidate][:password].blank?
      params[:candidate].delete(:password)
      params[:candidate].delete(:password_confirmation)
    end
    @resource = Candidate.find(params[:id])
    # puts candidate_params
    if @resource.update_attributes(candidate_params)
      flash[:notice] = I18n.t('messages.candidate_updated', name: @resource.account_name)
      render :event, id: @resource.id
    else
      render edit
    end
  end

  protected

  def resource_class
    devise_mapping.to
  end

  # Since going around devise mechanisms - add some helpers back in.
  def resource
    @resource
  end

  # Since going around devise mechanisms - add some helpers back in.
  def resource_name
    devise_mapping.name
  end

  # Since going around devise mechanisms - add some helpers back in.
  def devise_mapping
    Devise.mappings[:candidate]
  end

end
