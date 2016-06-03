module DeviseHelpersAdmin
  def resource_name
    :admin
  end

  def resource
    @resource ||= AppFactory.create_admin
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:admin]
  end
end