# frozen_string_literal: true

#
# Active Record
#
class SponsorCovenant < ActiveRecord::Base
  belongs_to(:scanned_eligibility, class_name: 'ScannedImage', validate: false, dependent: :destroy)
  accepts_nested_attributes_for(:scanned_eligibility, allow_destroy: true)

  belongs_to(:scanned_covenant, class_name: 'ScannedImage', validate: false, dependent: :destroy)
  accepts_nested_attributes_for(:scanned_covenant, allow_destroy: true)

  attr_accessor :sponsor_eligibility_picture

  # Validate if event is complete by adding validation errors to active record
  #
  # === Parameters:
  #
  # * <tt>:_options_</tt>
  #
  def validate_event_complete(options = {})
    event_complete_validator = EventCompleteValidator.new(self, !sponsor_attends_stmm)
    event_complete_validator.validate(SponsorCovenant.get_attends_stmm_validation_params, SponsorCovenant.get_not_attends_stmm_params)

    # convert empty picture attributes to something the user can understand
    found = false
    found |= !errors.delete(:scanned_covenant).nil?

    errors[:base] << 'Scanned sponsor covenant form can\'t be blank' if found

    found = false
    found |= !errors.delete(:scanned_eligibility).nil?
    errors[:base] << 'Scanned sponsor eligibility form can\'t be blank' if found
  end

  # Editable attributes
  #
  # === Return:
  #
  # Array of attributes
  #
  def self.get_permitted_params
    SponsorCovenant.get_attends_stmm_params.concat(
      SponsorCovenant.get_not_attends_stmm_params.concat(
        [scanned_eligibility_attributes: ScannedImage.get_permitted_params,
         scanned_covenant_attributes: ScannedImage.get_permitted_params]
      )
    ) << :sponsor_eligibility_picture
  end

  # Editable attributes
  #
  # === Return:
  #
  # Array of attributes
  #
  def self.get_basic_permitted_params
    %i[sponsor_name sponsor_attends_stmm sponsor_church scanned_covenant scanned_eligibility id]
  end

  # Editable attributes when sponsor belongs to stmm
  #
  # === Return:
  #
  # Array of attributes
  #
  def self.get_attends_stmm_params
    params = get_basic_permitted_params
    params.delete(:sponsor_church)
    params.delete(:scanned_eligibility)
    params
  end

  # Required attributes when sponsor belongs to stmm
  #
  # === Return:
  #
  # Array of attributes
  #
  def self.get_attends_stmm_validation_params
    params = SponsorCovenant.get_attends_stmm_params
    params.delete(:sponsor_attends_stmm)
    params
  end

  # Editable attributes when sponsor does NOT belongs to stmm
  #
  # === Return:
  #
  # Array of attributes
  #
  def self.get_not_attends_stmm_params
    params = get_basic_permitted_params
    params.delete(:sponsor_name)
    params.delete(:scanned_covenant)
    params.delete(:sponsor_attends_stmm)
    params
  end

  # associated confirmation event name
  #
  # === Return:
  #
  # String
  #
  def self.event_name
    I18n.t('events.sponsor_covenant')
  end

  # Validate whether event is complete by adding validation errors to active record
  #
  # === Parameters:
  #
  # * <tt>:candidate</tt> owner of association
  #
  # === Return:
  #
  # sponsor_covenant with validation errors
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
  # === Return:
  #
  # Hash of information to be verified
  #
  def verifiable_info(candidate)
    info = { 'Sponsor name': sponsor_name,
             'Sponsor attends': (sponsor_attends_stmm ? 'St. Mary Magdalene' : sponsor_church) }
  end
end
