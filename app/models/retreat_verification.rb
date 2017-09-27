class RetreatVerification < ActiveRecord::Base

  belongs_to(:scanned_retreat, class_name: 'ScannedImage', validate: false, dependent: :destroy)
  accepts_nested_attributes_for(:scanned_retreat, allow_destroy: true)

  attr_accessor :retreat_verification_picture

  # event_complete

  def validate_event_complete(options={})
      event_complete_validator = EventCompleteValidator.new(self, !retreat_held_at_stmm)
      event_complete_validator.validate([], RetreatVerification.get_basic_validation_params)
      # event_complete_validator = EventCompleteValidator.new(self).validate(RetreatVerification.get_basic_validation_params)
          # convert empty picture attributes to something the user can understand
      found = false
      found |= (!errors.delete(:scanned_retreat).nil?)
      if found
        errors[:base] << 'Scanned retreat verification can\'t be blank'
      end
  end

  def RetreatVerification.get_permitted_params
    RetreatVerification.get_basic_permitted_params.concat([scanned_retreat_attributes: ScannedImage.get_permitted_params])
  end

  def RetreatVerification.get_basic_permitted_params
    [:retreat_held_at_stmm, :start_date, :end_date, :who_held_retreat, :where_held_retreat, :retreat_verification_picture, :scanned_retreat]
  end

  def RetreatVerification.get_basic_validation_params
    params = self.get_basic_permitted_params
    params.delete(:retreat_held_at_stmm)
    params.delete(:retreat_verification_picture)
    params
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
    :scanned_retreat.filename
  end

  def content_type_param
    :scanned_retreat.content_type
  end

  def file_contents_param
    :scanned_retreat.content
  end

  def filename
    scanned_retreat.filename
  end

  def filename=(name)
    scanned_retreat.filename=name
  end

  def content_type
    scanned_retreat.content_type
  end

  def content_type=(type)
    scanned_retreat.content_type=type
  end

  def file_contents
    scanned_retreat.content
  end

  def file_contents=(contents)
    scanned_retreat.content=contents
  end

  # image interface - end

  def verifiable_info(candidate)
    {}
  end
end
