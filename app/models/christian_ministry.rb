#
# Actve Record
#
class ChristianMinistry < ActiveRecord::Base

  attr_accessor :christian_ministry_picture

  # Validate if event is complete by adding validation errors to active record
  #
  # === Parameters:
  #
  # * <tt>:baptized_at_stmm</tt> If true then nothing else needs to be added
  #
  # === Return:
  #
  # Boolean
  #
  def validate_event_complete(options={})
    EventCompleteValidator.new(self).validate(ChristianMinistry.get_permitted_params)
  end

  # Editable attributes
  #
  # === Return:
  #
  # Array of attributes
  #
  def self.get_permitted_params
    [:what_service, :where_service, :when_service, :helped_me, :id]
  end

  # associated confirmation event name
  #
  # === Return:
  #
  # String
  #
  def self.event_name
    I18n.t('events.christian_ministry')
  end

  # Validate if event is complete by adding validation errors to active record
  #
  # === Parameters:
  #
  # * <tt>:candidate</tt> owner of association
  #
  # === Return:
  #
  # christian_ministry with validation errors
  #
  def self.validate_event_complete(candidate)
    christian_ministry = candidate.christian_ministry
    christian_ministry.validate_event_complete
    christian_ministry
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
    {}
  end

end