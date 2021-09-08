# frozen_string_literal: true

# DeviseHelpers
#
module DeviseHelpers
  # get resource_name
  #
  def resource_name
    @resource_class.to_s.downcase.to_sym
  end

  # get resource
  #
  def resource
    @resource ||= ::AppFactory.create(@resource_class)
  end

  # get devise mapping for resource
  #
  def devise_mapping
    @devise_mapping ||= Devise.mappings[@resource_class.to_s.downcase.to_sym]
  end

  # Confirmation_path
  #
  # === Parameters:
  #
  # * <tt>:name</tt>
  #
  # === Returns:
  #
  # * <tt>:String</tt>
  #
  def confirmation_path(name)
    "#{name}_confirmation_path"
  end
end
