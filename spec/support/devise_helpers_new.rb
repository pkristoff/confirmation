# frozen_string_literal: true

module DeviseHelpersNew
  def resource_name
    :candidate
  end

  def resource
    @resource ||= AppFactory.create_candidate
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:candidate]
  end
end
