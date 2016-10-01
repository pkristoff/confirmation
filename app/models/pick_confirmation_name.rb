class PickConfirmationName < ActiveRecord::Base

  attr_accessor :pick_confirmation_name_picture

  # event_complete

  def validate_event_complete(options={})
    EventCompleteValidator.new(self).validate(PickConfirmationName.get_permitted_params)
  end

  def self.get_permitted_params
    [:saint_name, :about_saint, :why_saint, :pick_confirmation_name_filename, :pick_confirmation_name_content_type, :pick_confirmation_name_file_contents]
  end

  def self.event_name
    I18n.t('events.confirmation_name')
  end

  def self.validate_event_complete(candidate)
    pick_confirmation_name = candidate.pick_confirmation_name
    pick_confirmation_name.validate_event_complete
    pick_confirmation_name
  end

  # event_complete - end

  # image interface

  def filename_param
    :pick_confirmation_name_filename
  end

  def content_type_param
    :pick_confirmation_name_content_type
  end

  def file_contents_param
    :pick_confirmation_name_file_contents
  end

  def filename
    pick_confirmation_name_filename
  end

  def filename=(name)
    pick_confirmation_name_filename=name
  end

  def content_type
    pick_confirmation_name_content_type
  end

  def content_type=(type)
    pick_confirmation_name_content_type=type
  end

  def file_contents
    pick_confirmation_name_file_contents
  end

  def file_contents=(contents)
    pick_confirmation_name_file_contents=contents
  end

  # image interface - end

  def verifiable_info
    {'Confirmation name': saint_name
    }
  end

end