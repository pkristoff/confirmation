# frozen_string_literal: true

module Dev
  #
  # Handles Registration tasks
  #
  class RegistrationsController < Devise::RegistrationsController
    before_action :authenticate_candidate!

    # candidate cannot new a candidate
    #
    def new
      redirect_back fallback_location: root_url,
                    alert: I18n.t('messages.admin_login_needed', message: I18n.t('messages.another_candidate'))
    end

    # candidate cannot create a candidate
    #
    def create
      redirect_to :back, alert: I18n.t('messages.admin_login_needed', message: I18n.t('messages.another_admin'))
    end

    # candidate cannot destroy a candidate
    #
    def destroy
      redirect_to :back, alert: I18n.t('messages.admin_login_needed', message: I18n.t('messages.remove_candidate'))
    end

    # candidate cannot create a candidate
    #
    # === Parameters:
    #
    # * <tt>:resource_or_scope</tt> Not used
    #
    def after_update_path_for(_resource_or_scope)
      dev_candidate_path(current_candidate.id)
    end

    # get devise mapping for candidate
    #
    def devise_mapping
      Devise.mappings[:candidate]
    end

    # builds a candidate then adds candidate events
    #
    # === Parameters:
    #
    # * <tt>:hash</tt> optional
    #
    def build_resource(hash = nil)
      candidate = super(hash)
      AppFactory.add_candidate_events(candidate)
    end

    # rederict if candidate not signed_in.
    #
    def event
      redirect_to root_path, alert: I18n.t('devise.failure.timeout') unless candidate_signed_in?
    end
  end
end
