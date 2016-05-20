module DeviseHelpers
  def resource_name
    @resource_class.to_s.downcase.to_sym
  end

  def resource
    @resource ||= (@resource_class == Candidate ? @resource_class.new_with_address : @resource_class.new)
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[@resource_class.to_s.downcase.to_sym]
  end

  def confirmation_path name
    "#{name.to_s}_confirmation_path"
  end
end