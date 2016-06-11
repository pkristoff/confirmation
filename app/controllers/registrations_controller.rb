class RegistrationsController < Devise::RegistrationsController

  before_action :authenticate_admin!
  skip_before_filter :require_no_authentication, only: [:new, :create, :destroy]

  def create
    unless admin_signed_in?
      return redirect_to :back, alert: I18n.t('messages.admin_login_needed', message: I18n.t('messages.another_admin'))
    end
    super
  end

  def destroy
    unless admin_signed_in?
      return redirect_to :back, alert: I18n.t('messages.admin_login_needed', message: I18n.t('messages.remove_candidate'))
    end
    super
  end

  def new
    unless admin_signed_in?
      return redirect_to :back, alert: I18n.t('messages.admin_login_needed', message: I18n.t('messages.another_admin'))
    end
    super
  end

  def after_update_path_for(resource_or_scope)
    current_candidate
  end

  def update_resource(resource, params)
    params.delete(:current_password)
    resource.update_without_password(params)
  end

  def devise_mapping
    mapping = super
    mapping = Devise.mappings[:candidate] if mapping.nil?
    mapping
  end

  protected

  def sign_up(resource_name, resource)
    true # don't sign_in new candidate after signup.
  end

  def build_resource (hash=nil)
    candidadate = super(hash)
    AppFactory.add_candidate_events(candidadate)
  end

end
