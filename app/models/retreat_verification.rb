class RetreatVerification < ActiveRecord::Base

  attr_accessor :retreat_verification_picture

  # event_complete

  def validate_event_complete(options={})
    # convert empty picture attributes to something the user can understand
    unless retreat_held_at_stmm
      EventCompleteValidator.new(self).validate(RetreatVerification.get_non_st_mm_required_params)
      found = false
      found |= (! errors.delete(:retreat_filename).nil?)
      found |= (! errors.delete(:retreat_content_type).nil?)
      found |= (! errors.delete(:retreat_file_content).nil?)
      if found
        errors[:base] << 'Retreat verification picture can\'t be blank'
      end
    end
  end

  def self.get_non_picture_params
    [:retreat_held_at_stmm, :start_date, :end_date, :who_held_retreat, :where_held_retreat]
  end

  def self.get_picture_params
    [:retreat_filename, :retreat_content_type, :retreat_file_content]
  end

  def self.get_permitted_params
    RetreatVerification.get_non_picture_params.concat(RetreatVerification.get_picture_params)
  end

  def self.get_non_st_mm_required_params
    xxx = RetreatVerification.get_permitted_params
    xxx.delete(:retreat_held_at_stmm)
    Rails.logger.info("xxx=#{xxx}")
    xxx
  end

  def self.event_name
    I18n.t('events.retreat_verification')
  end

  def self.validate_event_complete(candidate)
    retreat_verification = candidate.retreat_verification
    retreat_verification.validate_event_complete
    retreat_verification
  end

  # event_complete - end

  # image interface

  def filename_param
    :retreat_filename
  end

  def content_type_param
    :retreat_content_type
  end

  def file_contents_param
    :retreat_file_content
  end

  def filename
    retreat_filename
  end

  def filename=(name)
    retreat_filename=name
  end

  def content_type
    retreat_content_type
  end

  def content_type=(type)
    retreat_content_type=type
  end

  def file_contents
    retreat_file_content
  end

  def file_contents=(contents)
    retreat_file_content=contents
  end

  # image interface - end

  def verifiable_info
    {}
  end
end
