# frozen_string_literal: true

#
# Active Record
#
class PickConfirmationName < ApplicationRecord
  # Validate if event is complete by adding validation errors to active record
  #
  # === Parameters:
  #
  # * <tt>:options</tt>
  #
  def validate_event_complete(_options = {})
    EventCompleteValidator.new(self).validate(PickConfirmationName.permitted_params)
  end

  # Editable attributes
  #
  # === Returns:
  #
  # * <tt>Array</tt> of attributes
  #
  def self.permitted_params
    %i[saint_name id]
  end

  # associated confirmation event name
  #
  # === Returns:
  #
  # * <tt>String</tt>
  #
  def self.event_key
    'Confirmation Name'
  end

  # Validate whether event is complete by adding validation errors to active record
  #
  # === Parameters:
  #
  # * <tt>:candidate</tt> owner of association
  #
  # === Returns:
  #
  # * <tt>PickConfirmationName</tt> pick_confirmation_name with validation errors
  #
  def self.validate_event_complete(candidate)
    pick_confirmation_name = candidate.pick_confirmation_name
    pick_confirmation_name.validate_event_complete
    pick_confirmation_name
  end

  # information to be verified by admin
  #
  # === Parameters:
  #
  # * <tt>:candidate</tt> owner of this association
  #
  # === Returns:
  #
  # * <tt>Hash</tt> of information to be verified
  #
  def verifiable_info(_candidate)
    { 'Confirmation name': saint_name }
  end
end
