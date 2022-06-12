# frozen_string_literal: true

#
# Candidate specific of a ConfirmationEvent
#
class CandidateEvent < ApplicationRecord
  # http://guides.rubyonrails.org/association_basics.html#the-has-and-belongs-to-many-association
  # has_and_belongs_to_many :confirmation_event
  # accepts_nested_attributes_for :confirmation_event, allow_destroy: false

  has_one :to_do, dependent: :destroy
  has_one :confirmation_event, through: :to_do
  accepts_nested_attributes_for :confirmation_event, allow_destroy: false
  belongs_to(:candidate)

  # Shortcut to due date of the confirmation event based on attending
  #
  # === Returns:
  #
  # * <tt>Date</tt>
  #
  def due_date
    if candidate.candidate_sheet.attending == Attending::THE_WAY
      confirmation_event.the_way_due_date
    else
      confirmation_event.chs_due_date
    end
  end

  # Shortcut to instructions of the confirmation event
  #
  # === Returns:
  #
  # * <tt>String</tt>
  #
  delegate :instructions, to: :confirmation_event

  # Shortcut to name of the confirmation event
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  delegate :event_key, to: :confirmation_event

  # Has the event been started
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def started?
    CandidateEvent.started?(due_date)
  end

  # Has the event been started
  #
  # === Parameters:
  #
  # * <tt>:due_date</tt> Date: The due_date -if nil then not started.
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def self.started?(due_date)
    !due_date.nil?
  end

  # Is the candidate event waiting for information from the candidate
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def awaiting_candidate?
    CandidateEvent.awaiting_candidate?(due_date, completed_date)
  end

  # Is the candidate event waiting for information from the candidate
  #
  # === Parameters:
  #
  # * <tt>:due_date</tt> Date: The due_date -if nil then not started.
  # * <tt>:completed_date</tt> Date: When all the information is filled in.
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def self.awaiting_candidate?(due_date, completed_date)
    CandidateEvent.started?(due_date) && completed_date.nil?
  end

  # Is the candidate event waiting verification from admin
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def awaiting_admin?
    CandidateEvent.awaiting_admin?(due_date, completed_date, verified)
  end

  # Is the candidate event waiting verification from admin
  #
  # === Parameters:
  #
  # * <tt>:due_date</tt> Date: The due_date -if nil then not started.
  # * <tt>:completed_date</tt> Date: When all the information is filled in.
  # * <tt>:verified</tt> Boolean: Has admin verified
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def self.awaiting_admin?(due_date, completed_date, verified)
    CandidateEvent.started?(due_date) && !completed_date.nil? && !verified
  end

  # Is the candidate event coming due within the next 30 days.
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def coming_due?
    CandidateEvent.coming_due?(due_date, completed_date)
  end

  # Is the candidate event coming due within the next 30 days.
  #
  # === Parameters:
  #
  # * <tt>:due_date</tt> Date: The due_date -if nil then not started.
  # * <tt>:completed_date</tt> Date: When all the information is filled in.
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def self.coming_due?(due_date, completed_date)
    today = Time.zone.today
    CandidateEvent.awaiting_candidate?(due_date, completed_date) && (due_date >= today) && (due_date < today + 30)
  end

  # Is the candidate event completed
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def completed?
    CandidateEvent.completed?(due_date, verified)
  end

  # Is the candidate event done
  #
  # === Parameters:
  #
  # * <tt>:due_date</tt> Date: The due_date -if nil then not started.
  # * <tt>:verified</tt> Boolean: Has admin verified
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def self.completed?(due_date, verified)
    CandidateEvent.started?(due_date) && verified
  end

  # Is the candidate event past due.
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def late?
    CandidateEvent.late?(due_date, completed_date)
  end

  # Is the candidate event past due.
  #
  # === Parameters:
  #
  # * <tt>:due_date</tt> Date: The due_date -if nil then not started.
  # * <tt>:completed_date</tt> Date: When all the information is filled in.
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def self.late?(due_date, completed_date)
    CandidateEvent.awaiting_candidate?(due_date, completed_date) && (due_date < Time.zone.today)
  end

  # What is the status of this event.
  #
  # === Parameters:
  #
  # * <tt>:due_date</tt> Date: The due_date -if nil then not started.
  # * <tt>:completed_date</tt> Date: When all the information is filled in.
  # * <tt>:verified</tt> Boolean: Has admin verified
  #
  # === Returns:
  #
  # * <tt>String</tt> representing the state
  #
  def self.status(due_date, completed_date, verified)
    return I18n.t('status.not_started') unless started?(due_date)
    return I18n.t('status.coming_due') if coming_due?(due_date, completed_date)
    return I18n.t('status.late') if late?(due_date, completed_date)
    return I18n.t('status.awaiting_candidate') if awaiting_candidate?(due_date, completed_date)
    return I18n.t('status.awaiting_admin') if awaiting_admin?(due_date, completed_date, verified)
    return I18n.t('status.verified') if completed?(due_date, verified)

    raise('Unknown candidate_event status')
  end

  # What is the status of this event.
  #
  # === Returns:
  #
  # * <tt>String</tt>
  #
  def status
    CandidateEvent.status(due_date, completed_date, verified)
  end

  # Editable attributes
  #
  # === Returns:
  #
  # * <tt>Array</tt> of attributes
  #
  def self.permitted_params
    [:id, :completed_date, :verified,
     { confirmation_event_attributes: ConfirmationEvent.permitted_params }]
  end

  # information to be verified by admin
  #
  # === Returns:
  #
  # * <tt>Hash</tt> of information to be verified
  #
  def verifiable_info
    candidate.get_event_association(Candidate.event_route(event_key)).verifiable_info
  end

  # Mark candidate complete by setting the completed date
  # Some associations can be automatically makred as verified.
  #
  # === Parameters:
  #
  # * <tt>:validated</tt> All the required information has be supplied
  # * <tt>:cand_assoc_class</tt> the class of the association in which is being marked complete
  #
  def mark_completed(validated, cand_assoc_class)
    if validated
      if completed_date.nil?
        self.completed_date = Time.zone.today
        # automatically mark verified when completed.
        # TODO: move to association class
        self.verified = %w[CandidateSheet ChristianMinistry SponsorCovenant].include?(cand_assoc_class.to_s)
      end
    else
      unless completed_date.nil?
        self.completed_date = nil
        self.verified = false
      end
    end
  end
end
