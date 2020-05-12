# frozen_string_literal: true

#
# Active Record
#
class SponsorCovenant < ApplicationRecord
  belongs_to(:scanned_eligibility, class_name: 'ScannedImage', validate: false, dependent: :destroy)
  accepts_nested_attributes_for(:scanned_eligibility, allow_destroy: true)

  belongs_to(:scanned_covenant, class_name: 'ScannedImage', validate: false, dependent: :destroy)
  accepts_nested_attributes_for(:scanned_covenant, allow_destroy: true)

  attr_accessor :sponsor_eligibility_picture,
                :remove_sponsor_eligibility_picture,
                :sponsor_covenant_picture,
                :remove_sponsor_covenant_picture

  # Validate if event is complete by adding validation errors to active record
  #
  # === Parameters:
  #
  # * <tt>:options</tt>
  #
  def validate_event_complete(_options = {})
    event_complete_validator = EventCompleteValidator.new(self, !sponsor_attends_home_parish)
    event_complete_validator.validate(SponsorCovenant.attends_home_parish_validation_params,
                                      SponsorCovenant.not_attends_home_parish_params)

    # convert empty picture attributes to something the user can understand
    found = false
    found |= !errors.delete(:scanned_covenant).nil?

    errors[:base] << "Scanned sponsor covenant form #{I18n.t('errors.messages.blank')}" if found

    found = false
    found |= !errors.delete(:scanned_eligibility).nil?
    errors[:base] << "Scanned sponsor eligibility form #{I18n.t('errors.messages.blank')}" if found
  end

  # Editable attributes
  #
  # === Returns:
  #
  # * <tt>Array</tt> of attributes
  #
  def self.permitted_params
    SponsorCovenant.attends_home_parish_params.concat(
      SponsorCovenant.not_attends_home_parish_params.concat(
        [scanned_eligibility_attributes: ScannedImage.permitted_params,
         scanned_covenant_attributes: ScannedImage.permitted_params]
      )
    ) <<
      :sponsor_eligibility_picture <<
      :remove_sponsor_eligibility_picture <<
      :remove_sponsor_covenant_picture <<
      :sponsor_covenant_picture
  end

  # Editable attributes
  #
  # === Returns:
  #
  # * <tt>Array</tt> of attributes
  #
  def self.basic_permitted_params
    %i[sponsor_name sponsor_attends_home_parish sponsor_church scanned_covenant scanned_eligibility id]
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
    params = SponsorCovenant.attends_home_parish_params
    params.delete(:sponsor_attends_home_parish)
    params.delete(:remove_sponsor_eligibility_picture)
    params.delete(:remove_sponsor_covenant_picture)
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
    params.delete(:sponsor_name)
    params.delete(:scanned_covenant)
    params.delete(:sponsor_attends_home_parish)
    params.delete(:remove_sponsor_eligibility_picture)
    params.delete(:remove_sponsor_covenant_picture)
    params
  end

  # associated confirmation event name
  #
  # === Returns:
  #
  # * <tt>String</tt>
  #
  def self.event_key
    'sponsor_covenant_and_sponsor_eligibility'
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
  # === Parameters:
  #
  # * <tt>:candidate</tt> owner of this association
  #
  # === Returns:
  #
  # * <tt>Hash</tt> of information to be verified
  #
  def verifiable_info(_candidate)
    { 'Sponsor name': sponsor_name,
      'Sponsor attends': (sponsor_attends_home_parish ? Visitor.home_parish : sponsor_church) }
  end
end
