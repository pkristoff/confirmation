# frozen_string_literal: true

#
# Active Record
#
class SponsorCovenant < ApplicationRecord
  # remove migration is done on production - just for migration
  belongs_to(:scanned_eligibility, class_name: 'ScannedImage', validate: false, dependent: :destroy)
  accepts_nested_attributes_for(:scanned_eligibility, allow_destroy: true)

  belongs_to(:scanned_covenant, class_name: 'ScannedImage', validate: false, dependent: :destroy)
  accepts_nested_attributes_for(:scanned_covenant, allow_destroy: true)

  attr_accessor :sponsor_covenant_picture,
                :remove_sponsor_covenant_picture

  # A common method for retrieving the scanned image for this
  # event.
  #
  # === Returns:
  #
  # * <tt>ScannedImage</tt>
  #
  def scanned_image
    scanned_covenant
  end

  # A common method for retrieving the scanned image id for this
  # event.
  #
  # === Returns:
  #
  # * <tt>Integer</tt> scanned_covenant_id
  #
  def scanned_image_id
    scanned_covenant_id
  end

  # Validate if event is complete by adding validation errors to active record
  #
  # === Parameters:
  #
  # * <tt>:options</tt>
  #
  def validate_event_complete(_options = {})
    event_complete_validator = EventCompleteValidator.new(self, validate_others: false)
    event_complete_validator.validate(SponsorCovenant.basic_permitted_params)

    # convert empty picture attributes to something the user can understand
    found = false
    found |= !errors.delete(:scanned_covenant).nil?
    return unless found

    errors.add(:base, I18n.t('errors.format_blank',
                             attribute: I18n.t('activerecord.attributes.sponsor_covenant.sponsor_covenant_picture')))
  end

  # Editable attributes
  #
  # === Returns:
  #
  # * <tt>Array</tt> of attributes
  #
  def self.permitted_params
    SponsorCovenant.basic_permitted_params.concat(
      [{ scanned_covenant_attributes: ScannedImage.permitted_params }] <<
        :remove_sponsor_covenant_picture <<
        :sponsor_covenant_picture
    )
  end

  # Editable attributes
  #
  # === Returns:
  #
  # * <tt>Array</tt> of attributes
  #
  def self.basic_permitted_params
    %i[sponsor_name scanned_covenant id]
  end

  # associated confirmation event name
  #
  # === Returns:
  #
  # * <tt>String</tt>
  #
  def self.event_key
    'sponsor_covenant'
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
    sponsor_covenant = candidate.sponsor_covenant
    sponsor_covenant.validate_event_complete
    sponsor_covenant
  end

  # information to be verified by admin
  #
  # === Returns:
  #
  # * <tt>Hash</tt> of information to be verified
  #
  def verifiable_info
    { 'Sponsor name': sponsor_name }
  end
end
