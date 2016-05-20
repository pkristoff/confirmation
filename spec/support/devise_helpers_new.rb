module DeviseHelpersNew
  def resource_name
    :candidate
  end

  def resource
    @resource ||= Candidate.new_with_address
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:candidate]
  end
end