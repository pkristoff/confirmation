class ChristianMinistry < ActiveRecord::Base

  attr_accessor :christian_ministry_picture

  # event_complete

  def validate_event_complete(options={})
    EventCompleteValidator.new(self).validate_either(ChristianMinistry.get_non_picture_params, ChristianMinistry.get_picture_params)
  end

  def self.get_non_picture_params
    [:what_service, :where_service, :when_service, :helped_me, :signed]
  end

  def self.get_picture_params
    [:christian_ministry_filename, :christian_ministry_content_type, :christian_ministry_file_contents]
  end

  def self.get_permitted_params
    ChristianMinistry.get_non_picture_params.concat(ChristianMinistry.get_picture_params)
  end

  def self.event_name
    I18n.t('events.christian_ministry')
  end

  def self.validate_event_complete(candidate)
    christian_ministry = candidate.christian_ministry
    christian_ministry.validate_event_complete
    christian_ministry
  end

  # event_complete - end

  # image interface

  def filename_param
    :christian_ministry_filename
  end

  def content_type_param
    :christian_ministry_content_type
  end

  def file_contents_param
    :christian_ministry_file_contents
  end

  def filename
    christian_ministry_filename
  end

  def filename=(name)
    christian_ministry_filename=name
  end

  def content_type
    christian_ministry_content_type
  end

  def content_type=(type)
    christian_ministry_content_type=type
  end

  def file_contents
    christian_ministry_file_contents
  end

  def file_contents=(contents)
    christian_ministry_file_contents=contents
  end

  # image interface - end

end