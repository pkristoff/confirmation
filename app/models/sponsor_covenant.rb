class SponsorCovenant < ActiveRecord::Base

  attr_accessor :sponsor_elegibility_picture

  # event_complete

  def validate_event_complete(options={})
    EventCompleteValidator.new(self, !sponsor_attends_stmm)
        .validate(SponsorCovenant.get_attends_stmm_validation_params, SponsorCovenant.get_not_attends_stmm_params)
    # convert empty picture attributes to something the user can understand
    found = false
    found |= (! errors.delete(:sponsor_elegibility_filename).nil?)
    found |= (! errors.delete(:sponsor_elegibility_content_type).nil?)
    found |= (! errors.delete(:sponsor_elegibility_file_contents).nil?)
    if found
      errors[:base] << 'Sponsor eligibility form can\'t be blank'
    end
    found = false
    found |= (! errors.delete(:sponsor_covenant_filename).nil?)
    found |= (! errors.delete(:sponsor_covenant_content_type).nil?)
    found |= (! errors.delete(:sponsor_covenant_file_contents).nil?)
    if found
      errors[:base] << 'Sponsor covenant form can\'t be blank'
    end

  end

  def self.get_permitted_params
    SponsorCovenant.get_attends_stmm_params.concat(SponsorCovenant.get_not_attends_stmm_params) << :sponsor_elegibility_picture
  end

  def self.get_attends_stmm_params
    [:sponsor_name, :sponsor_attends_stmm, :sponsor_covenant_filename, :sponsor_covenant_content_type, :sponsor_covenant_file_contents]
  end

  def self.get_attends_stmm_validation_params
    params = SponsorCovenant.get_attends_stmm_params
    params.delete(:sponsor_attends_stmm)
    params
  end

  def self.get_not_attends_stmm_params
    [:sponsor_church, :sponsor_elegibility_filename, :sponsor_elegibility_content_type, :sponsor_elegibility_file_contents]
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
    :sponsor_covenant_filename
  end

  def content_type_param
    :sponsor_covenant_content_type
  end

  def file_contents_param
    :sponsor_covenant_file_contents
  end

  def filename
    sponsor_covenant_filename
  end

  def filename=(name)
    sponsor_covenant_filename=name
  end

  def content_type
    sponsor_covenant_content_type
  end

  def content_type=(type)
    sponsor_covenant_content_type=type
  end

  def file_contents
    sponsor_covenant_file_contents
  end

  def file_contents=(contents)
    sponsor_covenant_file_contents=contents
  end

  # image interface - end

  def verifiable_info
    info = {'Sponsor name': sponsor_name,
            'Sponsor attends': (sponsor_attends_stmm ? 'St. Mary Magdalene' : sponsor_church)
    }
  end

end