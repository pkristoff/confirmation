# frozen_string_literal: true

#
# Active Record
#
class PickConfirmationName < ActiveRecord::Base
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
  # Array of attributes
  #
  def self.permitted_params
    %i[saint_name id]
  end

  # associated confirmation event name
  #
  # === Returns:
  #
  # String
  #
  def self.event_name
    I18n.t('events.confirmation_name')
  end

  # Validate whether event is complete by adding validation errors to active record
  #
  # === Parameters:
  #
  # * <tt>:candidate</tt> owner of association
  #
  # === Returns:
  #
  # pick_confirmation_name with validation errors
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
  # Hash of information to be verified
  #
  def verifiable_info(_candidate)
    { 'Confirmation name': saint_name }
  end
end
