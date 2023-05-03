# frozen_string_literal: true

#
# Active Record
#
class SponsorEligibility < ApplicationRecord
  belongs_to(:scanned_eligibility, class_name: 'ScannedImage', validate: false, dependent: :destroy)
  accepts_nested_attributes_for(:scanned_eligibility, allow_destroy: true)

  attr_accessor :sponsor_eligibility_picture,
                :remove_sponsor_eligibility_picture

  # A common method for retrieving the scanned image for this
  # event.
  #
  # === Returns:
  #
  # * <tt>ScannedImage</tt>
  #
  def scanned_image
    scanned_eligibility
  end

  # A common method for retrieving the scanned image id for this
  # event.
  #
  # === Returns:
  #
  # * <tt>Integer</tt> scanned_eligibility_id
  #
  def scanned_image_id
    scanned_eligibility_id
  end

  # Returns the event_key for this event
  #
  # === Returns:
  #
  # * <tt>String</tt>
  #
  def self.event_key
    'sponsor_eligibility'
  end

  # Validate whether event is complete by adding validation errors to active record
  #
  # === Parameters:
  #
  # * <tt>:candidate</tt> owner of association
  #
  # === Returns:
  #
  # * <tt>SponsorCovenant</tt> with validation errors
  #
  def self.validate_event_complete(candidate)
    sponsor_eligibility = candidate.sponsor_eligibility
    sponsor_eligibility.validate_event_complete
    sponsor_eligibility
  end

  # Validate if event is complete by adding validation errors to active record
  #
  # === Parameters:
  #
  # * <tt>:options</tt>
  #
  def validate_event_complete(_options = {})
    event_complete_validator = EventCompleteValidator.new(self, validate_others: !sponsor_attends_home_parish)
    event_complete_validator.validate(SponsorEligibility.attends_home_parish_validation_params,
                                      SponsorEligibility.not_attends_home_parish_params)

    found = false
    found |= !errors.delete(:scanned_eligibility).nil?
    return unless found

    errors.add(:base, :blank, message: "Scanned sponsor eligibility form #{I18n.t('errors.messages.blank')}")
  end

  # Editable attributes
  #
  # === Returns:
  #
  # * <tt>Array</tt> of attributes
  #
  def self.permitted_params
    SponsorEligibility.attends_home_parish_params.concat(
      SponsorEligibility.not_attends_home_parish_params.push(
        { scanned_eligibility_attributes: ScannedImage.permitted_params }
      )
    ) <<
      :sponsor_eligibility_picture <<
      :remove_sponsor_eligibility_picture
  end

  # Editable attributes
  #
  # === Returns:
  #
  # * <tt>Array</tt> of attributes
  #
  def self.basic_permitted_params
    %i[sponsor_attends_home_parish sponsor_church scanned_eligibility id]
  end

  # Editable attributes when sponsor belongs to home_parish
  #
  # === Returns:
  #
  # * <tt>Array</tt> of attributes
  #
  def self.attends_home_parish_params
    params = basic_permitted_params
    params.delete(:sponsor_church)
    params.delete(:scanned_eligibility)
    params
  end

  # Required attributes when sponsor belongs to home_parish
  #
  # === Returns:
  #
  # * <tt>Array</tt> of attributes
  #
  def self.attends_home_parish_validation_params
    params = SponsorEligibility.attends_home_parish_params
    params.delete(:sponsor_attends_home_parish)
    params.delete(:remove_sponsor_eligibility_picture)
    params.delete(:id)
    params
  end

  # Editable attributes when sponsor does NOT belongs to home_parish
  #
  # === Returns:
  #
  # * <tt>Array</tt> of attributes
  #
  def self.not_attends_home_parish_params
    params = basic_permitted_params
    params.delete(:sponsor_attends_home_parish)
    params.delete(:remove_sponsor_eligibility_picture)
    params.delete(:id)
    params
  end

  # information to be verified by admin
  #
  # === Returns:
  #
  # * <tt>Hash</tt> of information to be verified
  #
  def verifiable_info
    { 'Sponsor attends': (sponsor_attends_home_parish ? Visitor.home_parish : sponsor_church) }
  end
end
