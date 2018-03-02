# frozen_string_literal: true

module DeviseHelpers
  def resource_name
    @resource_class.to_s.downcase.to_sym
  end

  def resource
    @resource ||= ::AppFactory.create(@resource_class)
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[@resource_class.to_s.downcase.to_sym]
  end

  def confirmation_path(name)
    "#{name}_confirmation_path"
  end
end
