# frozen_string_literal: true

module Dev
  #
  # Handles Registration tasks
  #
  class RegistrationsController < Devise::RegistrationsController
    before_action :authenticate_candidate!

    def create
      redirect_to :back, alert: I18n.t('messages.admin_login_needed', message: I18n.t('messages.another_admin'))
    end

    def destroy
      redirect_to :back, alert: I18n.t('messages.admin_login_needed', message: I18n.t('messages.remove_candidate'))
    end

    def new
      redirect_to :back, alert: I18n.t('messages.admin_login_needed', message: I18n.t('messages.another_candidate'))
    end

    def after_update_path_for(_resource_or_scope)
      dev_candidate_path(current_candidate.id)
    end

    def devise_mapping
      Devise.mappings[:candidate]
    end

    def build_resource(hash = nil)
      candidate = super(hash)
      AppFactory.add_candidate_events(candidate)
    end

    def event
      redirect_to root_path, alert: I18n.t('devise.failure.timeout') unless candidate_signed_in?
    end
  end
end
