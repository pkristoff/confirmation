# frozen_string_literal: true

#
# This was created in an attempt to keep DB objects from being created to generate
# the sorting_candidate_selection pane.
#
# Each instance represents a row in _sorting_candidate_selection.html.erb
#
# === Parameters:
#
# * <tt>:cand_info</tt> Candidate information shown in the sorting table.
# * <tt>:cand_event_info</tt> A hash that has the information necessary to generate the status of each candidate event for a candidate.
# * <tt>:candidate_event</tt> The candiate event information (verified, completion_date) being editied in mass_edit_candidates_event.html.erb
#
class PluckCan
  def initialize(cand_info, cand_event_info, candidate_event = nil)
    @cand_info = cand_info
    @cand_event_info = cand_event_info
    @candidate_event = candidate_event
  end

  # Calcuate status of candidate_event
  #
  # === Parameters:
  #
  # * <tt>_:confirmation_event_id_</tt> The event being edited in mass_edit_candidates_event.html.erb
  #
  # === Return:
  #
  # Array of PluckCan
  #
  def self.pluck_candidates(confirmation_event_id = nil)
    candidate_events = pluck_cand_events
    Candidate.joins(:candidate_sheet).pluck(:id, :account_name, :confirmed_at, :encrypted_password, :last_name, :first_name, :grade, :attending).map do |cand_info|
      candidate_id = cand_info[0]
      event = candidate_events[candidate_id].find do |cand_event_for_cand|
        cand_event_for_cand[1] == confirmation_event_id
      end
      PluckCan.new(cand_info, candidate_events, event)
    end
  end

  # Gather candidate_events information
  #
  # === Parameters:
  #
  # === Return:
  #
  # Array of candidate_event information
  #
  def self.pluck_cand_events
    cand_event_info = {}
    ToDo.joins(:confirmation_event, :candidate_event).pluck(:candidate_id, :confirmation_event_id, :candidate_event_id, :name, :verified, :completed_date, :the_way_due_date, :chs_due_date).each do |info|
      cand_info = cand_event_info[info[0]]
      if cand_info.nil?
        cand_info = []
        cand_event_info[info[0]] = cand_info
      end
      cand_info << info
    end
    cand_event_info
  end

  # Calcuate status of candidate_event
  #
  # === Parameters:
  #
  # * <tt>:cand_id</tt> Candidate id.
  # * <tt>:event_name</tt> Name of caandidate event.
  # * <tt>:attending</tt> The way or catholic hs.
  #
  def status(cand_id, event_name, _attending)
    event_info = @cand_event_info[cand_id].find do |cand_event_for_cand|
      cand_event_for_cand[3] == event_name
    end
    CandidateEvent.status(event_info[6],
                          event_info[5],
                          event_info[4])
  end

  # Get Confirmation event id.
  #
  # === Parameters:
  #
  # * <tt>:cand_id</tt> Candidate id.
  # * <tt>:event_name</tt> Name of caandidate event.
  #
  def conf_event_id(cand_id, event_name)
    event_info = @cand_event_info[cand_id].find do |cand_event_for_cand|
      cand_event_for_cand[3] == event_name
    end
    event_info[1]
  end

  # candidate_event_id
  #
  # === Parameters:
  #
  # === Return:
  #
  # candidate_event_id
  #
  def candidate_event_id
    @candidate_event[3]
  end

  # verified
  #
  # === Parameters:
  #
  # === Return:
  #
  # verified
  #
  def verified
    @candidate_event[4]
  end

  # completed_date
  #
  # === Parameters:
  #
  # === Return:
  #
  # completed_date
  #
  def completed_date
    @candidate_event[5]
  end

  # id
  #
  # === Parameters:
  #
  # === Return:
  #
  # id
  #
  def id
    @cand_info[0]
  end

  # account_name
  #
  # === Parameters:
  #
  # === Return:
  #
  # account_name
  #
  def account_name
    @cand_info[1]
  end

  # confirmed?
  #
  # === Parameters:
  #
  # === Return:
  #
  # confirmed?
  #
  def confirmed?
    @cand_info[2] ? true : false
  end

  # password_changed
  #
  # === Parameters:
  #
  # === Return:
  #
  # password_changed
  #
  def password_changed
    encrypted_password = @cand_info[3]
    # Copied from database_authenticatable.rb - valid_Password?
    !Devise::Encryptor.compare(Candidate, encrypted_password, Event::Other::INITIAL_PASSWORD)
  end

  # last_name
  #
  # === Parameters:
  #
  # === Return:
  #
  # last_name
  #
  def last_name
    @cand_info[4]
  end

  # first_name
  #
  # === Parameters:
  #
  # === Return:
  #
  # first_name
  #
  def first_name
    @cand_info[5]
  end

  # grade
  #
  # === Parameters:
  #
  # === Return:
  #
  # grade
  #
  def grade
    @cand_info[6]
  end

  # attending
  #
  # === Parameters:
  #
  # === Return:
  #
  # attending
  #
  def attending
    @cand_info[7]
  end
end
