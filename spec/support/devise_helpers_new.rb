module DeviseHelpersNew
  def resource_name
    :candidate
  end

  def resource
    @resource ||= Candidate.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:candidate]
  end
end