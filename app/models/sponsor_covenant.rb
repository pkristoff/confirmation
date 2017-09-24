class SponsorCovenant < ActiveRecord::Base

  belongs_to(:scanned_eligibility, class_name: 'ScannedImage', validate: false)
  accepts_nested_attributes_for(:scanned_eligibility, allow_destroy: true)

  belongs_to(:scanned_covenant, class_name: 'ScannedImage', validate: false)
  accepts_nested_attributes_for(:scanned_covenant, allow_destroy: true)

  attr_accessor :sponsor_eligibility_picture

  # event_complete

  def validate_event_complete(options={})
    EventCompleteValidator.new(self, !sponsor_attends_stmm)
        .validate(SponsorCovenant.get_attends_stmm_validation_params, SponsorCovenant.get_not_attends_stmm_params)
    # convert empty picture attributes to something the user can understand
    found = false
    found |= (! errors.delete(:scanned_covenant).nil?)
    if found
      errors[:base] << 'Scanned sponsor covenant form can\'t be blank'
    end
    found = false
    found |= (! errors.delete(:scanned_eligibility).nil?)
    if found
      errors[:base] << 'Scanned sponsor eligibility form can\'t be blank'
    end

  end

  def self.get_basic_permitted_params
    [:sponsor_name, :sponsor_attends_stmm, :sponsor_church, :scanned_covenant, :scanned_eligibility]
  end

  def self.get_permitted_params
    SponsorCovenant.get_attends_stmm_params.concat(SponsorCovenant.get_not_attends_stmm_params.concat(
        [scanned_eligibility_attributes: ScannedImage.get_permitted_params,
         scanned_covenant_attributes: ScannedImage.get_permitted_params])) << :sponsor_eligibility_picture
  end

  def self.get_attends_stmm_params
    params = self.get_basic_permitted_params
    params.delete(:sponsor_church)
    params.delete(:scanned_eligibility)
    params
  end

  def self.get_attends_stmm_validation_params
    params = SponsorCovenant.get_attends_stmm_params
    params.delete(:sponsor_attends_stmm)
    params
  end

  def self.get_not_attends_stmm_params
    params = self.get_basic_permitted_params
    params.delete(:sponsor_name)
    params.delete(:scanned_covenant)
    params.delete(:sponsor_attends_stmm)
    params
  end




  def self.event_name
    I18n.t('events.sponsor_covenant')
  end

  def self.validate_event_complete(candidate)
    sponsor_covenant = candidate.sponsor_covenant
    sponsor_covenant.validate_event_complete
    sponsor_covenant
  end

  # event_complete - end

  # image interface

  def filename_param
    :scanned_covenant.filename
  end

  def content_type_param
    :scanned_covenant.content_type
  end

  def file_contents_param
    :scanned_covenant.contents
  end

  def filename
    scanned_covenant.filename
  end

  def filename=(name)
    scanned_covenant.filename=name
  end

  def content_type
    scanned_covenant.content_type
  end

  def content_type=(type)
    scanned_covenant.content_type=type
  end

  def file_contents
    scanned_covenant.content
  end

  def file_contents=(contents)
    scanned_covenant.contents=content
  end

  # image interface - end

  def verifiable_info(candidate)
    info = {'Sponsor name': sponsor_name,
            'Sponsor attends': (sponsor_attends_stmm ? 'St. Mary Magdalene' : sponsor_church)
    }
  end

end