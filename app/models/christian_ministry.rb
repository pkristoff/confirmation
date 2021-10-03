# frozen_string_literal: true

#
# Active Record
#
class ChristianMinistry < ApplicationRecord
  # Validate if event is complete by adding validation errors to active record
  #
  # === Parameters:
  #
  # * <tt>:options</tt> If true then nothing else needs to be added
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def validate_event_complete(_options = {})
    event_complete_validator = EventCompleteValidator.new(self)
    event_complete_validator.validate(ChristianMinistry.permitted_params)
  end

  # Editable attributes
  #
  # === Returns:
  #
  # * <tt>Array</tt> of attributes
  #
  def self.permitted_params
    %i[what_service where_service when_service helped_me id]
  end

  # associated confirmation event name
  #
  # === Returns:
  #
  # * <tt>String</tt>
  #
  def self.event_key
    'christian_ministry_awareness'
  end

  # Validate if event is complete by adding validation errors to active record
  #
  # === Parameters:
  #
  # * <tt>:candidate</tt> owner of association
  #
  # === Returns:
  #
  # * <tt>christian_ministry</tt> with validation errors
  #
  def self.validate_event_complete(candidate)
    christian_ministry = candidate.christian_ministry
    christian_ministry.validate_event_complete
    christian_ministry
  end

  # information to be verified by admin
  #
  # === Returns:
  #
  # * <tt>Hash</tt> of information to be verified
  #
  def verifiable_info
    {}
  end
end
