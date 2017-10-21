class ChristianMinistry < ActiveRecord::Base

  attr_accessor :christian_ministry_picture

  # event_complete

  def validate_event_complete(options={})
    EventCompleteValidator.new(self).validate(ChristianMinistry.get_permitted_params)
  end

  def self.get_permitted_params
    [:what_service, :where_service, :when_service, :helped_me, :id]
  end

  def self.event_name
    I18n.t('events.christian_ministry')
  end

  def self.validate_event_complete(candidate)
    christian_ministry = candidate.christian_ministry
    christian_ministry.validate_event_complete
    christian_ministry
  end

  # image interface - end

  def verifiable_info(candidate)
    {}
  end

end