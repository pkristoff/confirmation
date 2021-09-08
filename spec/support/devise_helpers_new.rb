# frozen_string_literal: true

# Devise HelpersNew
#
module DeviseHelpersNew
  # get resource name
  #
  def resource_name
    :candidate
  end

  # get resource for candidate
  #
  def resource
    @resource ||= AppFactory.create_candidate
  end

  # get devise mapping for candidate
  #
  def devise_mapping
    @devise_mapping ||= Devise.mappings[:candidate]
  end
end
