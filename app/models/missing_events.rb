# frozen_string_literal: true

#
# A helper class used for missing events.
#
class MissingEvents
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :missing_confirmation_events
  attr_accessor :found_confirmation_events
  attr_accessor :unknown_confirmation_events

  # initialize new instance
  #
  # === Returns:
  #
  # * <tt>Hash</tt> of information to be verified
  #
  def initialize
    # check_missing_events
    @found_confirmation_events = []
    @missing_confirmation_events = []
    @unknown_confirmation_events = []
  end

  # Add events expected to be missing
  #
  # === Parameters:
  #
  # * <tt>:missing_events</tt> Array: of expected missing ConfirmationEvents
  #
  # === Returns:
  #
  # * <tt>MissingEvents</tt> self
  #
  def add_missing(missing_events)
    missing_events.each do |event_key|
      confirmation_event = ConfirmationEvent.find_by(event_key: event_key)
      AppFactory.add_confirmation_event(event_key) if confirmation_event.nil?
      raise "Attempting to candidate_event named: #{event_key} that already exists.s" unless confirmation_event.nil?
    end
    check_missing_events
  end

  # Check to seif any ConfirmaEvents are missing.  It stores missing events in unknown_confirmation_events
  #
  # === Returns:
  #
  # * <tt>MissingEvents</tt> self
  #
  def check_missing_events
    all_in_confirmation_event_keys = AppFactory.all_i18n_confirmation_event_keys
    unknowns = ConfirmationEvent.all.map(&:event_key)
    all_in_confirmation_event_keys.each do |event_key|
      unknowns_index = unknowns.index(event_key)
      unknowns.slice!(unknowns_index) unless unknowns_index.nil?
      confirmation_event = ConfirmationEvent.find_by(event_key: event_key)
      if confirmation_event.nil?
        missing_confirmation_events.push(event_key)
      else
        found_confirmation_events.push(event_key)
      end
    end
    unknowns.each do |confirmation_event_name|
      unknown_confirmation_events.push(confirmation_event_name)
    end
    self
  end
end
