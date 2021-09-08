# frozen_string_literal: true

# DeviseHelperAdmin
#
module DeviseHelpersAdmin
  # Returns resource name
  #
  def resource_name
    :admin
  end

  # Sets and returns resource for admin
  #
  def resource
    @resource ||= AppFactory.create_admin
  end

  # Sets and returns devise mapping
  #
  def devise_mapping
    @devise_mapping ||= Devise.mappings[:admin]
  end
end
