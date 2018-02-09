# frozen_string_literal: true

#
# Active Record
#
class RetreatVerification < ActiveRecord::Base
  belongs_to(:scanned_retreat, class_name: 'ScannedImage', validate: false, dependent: :destroy)
  accepts_nested_attributes_for(:scanned_retreat, allow_destroy: true)

  attr_accessor :retreat_verification_picture

  # Validate if event is complete by adding validation errors to active record
  #
  # === Parameters:
  #
  # * <tt>:_options_</tt>
  #
  def validate_event_complete(_options = {})
    event_complete_validator = EventCompleteValidator.new(self, !retreat_held_at_stmm)
    event_complete_validator.validate([], RetreatVerification.basic_validation_params)
    # event_complete_validator = EventCompleteValidator.new(self).validate(RetreatVerification.basic_validation_params)
    # convert empty picture attributes to something the user can understand
    found = false
    found |= !errors.delete(:scanned_retreat).nil?

    errors[:base] << 'Scanned retreat verification can\'t be blank' if found
  end

  # Editable attributes
  #
  # === Return:
  #
  # Array of attributes
  #
  def self.permitted_params
    RetreatVerification.basic_permitted_params.concat([scanned_retreat_attributes: ScannedImage.permitted_params])
  end

  # Editable attributes
  #
  # === Return:
  #
  # Array of attributes
  #
  def self.basic_permitted_params
    %i[retreat_held_at_stmm start_date end_date who_held_retreat where_held_retreat retreat_verification_picture scanned_retreat id]
  end

  # Required attributes
  #
  # === Return:
  #
  # Array of attributes
  #
  def self.basic_validation_params
    params = basic_permitted_params
    params.delete(:retreat_held_at_stmm)
    params.delete(:retreat_verification_picture)
    params
  end

  # associated confirmation event name
  #
  # === Return:
  #
  # String
  #
  def self.event_name
    I18n.t('events.retreat_verification')
  end

  # Validate if event is complete by adding validation errors to active record
  #
  # === Parameters:
  #
  # * <tt>:candidate</tt> owner of association
  #
  # === Return:
  #
  # retreat_verification with validation errors
  #
  def self.validate_event_complete(candidate)
    retreat_verification = candidate.retreat_verification
    retreat_verification.validate_event_complete
    retreat_verification
  end

  # information to be verified by admin
  #
  # === Parameters:
  #
  # * <tt>:candidate</tt> owner of this association
  #
  # === Return:
  #
  # Hash of information to be verified
  #
  def verifiable_info(_candidate)
    {}
  end
end
