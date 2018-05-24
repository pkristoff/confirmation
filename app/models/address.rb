# frozen_string_literal: true

# Active Record
#
class Address < ActiveRecord::Base
  # Editable attributes
  #
  # === Returns:
  #
  # * <tt>Array</tt> of attributes
  #
  def self.basic_permitted_params
    %i[street_1 street_2 city state zip_code id]
  end

  # Required attributes
  #
  # === Returns:
  #
  # * <tt>Array</tt> of attributes
  #
  def self.basic_validatiion_params
    params = Address.basic_permitted_params
    params.delete(:street_2)
    params
  end

  # Validate if event is complete by adding validation errors to active record
  #
  # === Parameters:
  #
  # * <tt>:options</tt>
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def validate_event_complete(_options = {})
    EventCompleteValidator.new(self).validate(Address.basic_validatiion_params)
  end
end
