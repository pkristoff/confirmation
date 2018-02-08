# frozen_string_literal: true

#
# Active Record
#
class Address < ActiveRecord::Base
  # Editable attributes
  #
  # === Return:
  #
  # Array of attributes
  #
  def self.get_basic_permitted_params
    %i[street_1 street_2 city state zip_code id]
  end

  # Required attributes
  #
  # === Return:
  #
  # Array of attributes
  #
  def self.get_basic_validatiion_params
    params = Address.get_basic_permitted_params
    params.delete(:street_2)
    params
  end

  # Validate if event is complete by adding validation errors to active record
  #
  # === Parameters:
  #
  # * <tt>:_options_</tt>
  #
  # === Return:
  #
  # Boolean
  #
  def validate_event_complete(options = {})
    EventCompleteValidator.new(self).validate(Address.get_basic_validatiion_params)
  end
end
