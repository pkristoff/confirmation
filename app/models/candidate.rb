# frozen_string_literal: true

require 'constants'

#
# Person being confirmed
#
class Candidate < ApplicationRecord
  include Attending
  # TODO: Remove address - this should be gone.
  belongs_to(:address, validate: false, dependent: :destroy)
  accepts_nested_attributes_for(:address, allow_destroy: true)

  has_many(:candidate_events, dependent: :destroy)
  accepts_nested_attributes_for(:candidate_events, allow_destroy: true)

  belongs_to(:candidate_sheet, validate: true, dependent: :destroy)
  accepts_nested_attributes_for(:candidate_sheet, allow_destroy: true)

  belongs_to(:baptismal_certificate, validate: false, dependent: :destroy)
  accepts_nested_attributes_for(:baptismal_certificate, allow_destroy: true)

  belongs_to(:sponsor_covenant, validate: false, dependent: :destroy)
  accepts_nested_attributes_for(:sponsor_covenant, allow_destroy: true)

  belongs_to(:sponsor_eligibility, validate: false, dependent: :destroy)
  accepts_nested_attributes_for(:sponsor_eligibility, allow_destroy: true)

  belongs_to(:pick_confirmation_name, validate: false, dependent: :destroy)
  accepts_nested_attributes_for(:pick_confirmation_name, allow_destroy: true)

  belongs_to(:christian_ministry, validate: false, dependent: :destroy)
  accepts_nested_attributes_for(:christian_ministry, allow_destroy: true)

  belongs_to(:retreat_verification, validate: false, dependent: :destroy)
  accepts_nested_attributes_for(:retreat_verification, allow_destroy: true)

  after_initialize :build_associations, if: :new_record?

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable, :timeoutable,
         :recoverable, :rememberable, :trackable, :validatable,
         authentication_keys: [:account_name],
         reset_password_keys: [:account_name]

  validates :account_name,
            presence: true,
            uniqueness: {
              case_sensitive: false
            }

  validate :validate_show_empty_radio

  # validates whether show_empty_radio is either 0 or 1
  # if this fails this is a coding error no user.
  #
  def validate_show_empty_radio
    show_empty_radio = baptismal_certificate.show_empty_radio
    return if show_empty_radio.zero? || show_empty_radio == 1 || show_empty_radio == 2

    errors.add(:show_empty_radio, "can only be 0 or 1 or 2 not #{baptismal_certificate.show_empty_radio}")
  end

  # turn off sending verify instructions until admin sends it.
  #
  def send_on_create_confirmation_instructions; end

  # Sorts candidate events in priorty order (to be cmpleted first)
  #
  # === Returns:
  #
  # * <tt>Array</tt> candidate events
  #
  def candidate_events_sorted
    # TODO: rewrite using event states
    candidate_events.sort do |ce1, ce2|
      # in order for this to work due_dates should not be nil.
      # if they are move them to the top so admin can give them
      # one.
      if ce1.due_date.nil?
        if ce2.due_date.nil?
          ce1.event_key <=> ce2.event_key
        else
          -1
        end
      elsif ce2.due_date.nil?
        1
      elsif ce1.completed_date.nil?
        # due_dates filled in.
        if ce2.completed_date.nil?
          # if neither completed then the first to come
          # due is first
          due_date = ce1.due_date <=> ce2.due_date
          if due_date.zero?
            ce1.event_key <=> ce2.event_key
          else
            due_date
          end
        else
          # non completed goes on top.
          -1
        end
      elsif ce2.completed_date.nil?
        # non completed goes on top.
        1
      else
        # if both are completed then the first to come
        # due is on top
        due_date = ce1.due_date <=> ce2.due_date
        if due_date.zero?
          ce1.event_key <=> ce2.event_key
        else
          due_date
        end
      end
    end
  end

  # returns candidate's account_name
  #
  # === Parameters:
  #
  # * <tt>:last_name</tt>
  # * <tt>:first_name</tt>
  #
  # === Returns:
  #
  # * <tt>CandidateEvent</tt>
  #
  def self.genertate_account_name(last_name, first_name)
    "#{last_name}#{first_name}".downcase
  end

  # Adds a candidate event as part of the creation process
  #
  # === Parameters:
  #
  # * <tt>:confirmation_event</tt> common event
  #
  # === Returns:
  #
  # * <tt>CandidateEvent</tt>
  #
  def add_candidate_event(confirmation_event)
    candidate_event = AppFactory.create_candidate_event(confirmation_event)
    candidate_events << candidate_event
    candidate_event.candidate = self
    candidate_event
  end

  # Editable attributes
  #
  # === Returns:
  #
  # * <tt>Array</tt> of attributes
  #
  def self.candidate_params
    attribute_names.collect(&:to_sym) & %i[account_name password]
  end

  # builds candidate's associations
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def build_associations
    candidate_sheet || build_candidate_sheet
    baptismal_certificate || build_baptismal_certificate
    sponsor_covenant || build_sponsor_covenant
    sponsor_eligibility || build_sponsor_eligibility
    pick_confirmation_name || build_pick_confirmation_name
    christian_ministry || build_christian_ministry
    retreat_verification || build_retreat_verification
    true
  end

  # returns event_key for covenant agreement. implemented here because no Object for event.
  #
  # === Returns:
  #
  # * <tt>String</tt> representing the event_key
  #
  def self.covenant_agreement_event_key
    'candidate_covenant_agreement'
  end

  # returns event_key for parent meeting. implemented here because no Object for event.
  #
  # === Returns:
  #
  # * <tt>String</tt> representing the event_key
  #
  def self.parent_meeting_event_key
    'parent_information_meeting'
  end

  # Editable attributes
  #
  # === Returns:
  #
  # * <tt>Array</tt> of attributes
  #
  def self.permitted_params
    [:id, :account_name, :password, :password_confirmation,
     :signed_agreement, :candidate_note,
     { candidate_sheet_attributes: CandidateSheet.permitted_params,
       baptismal_certificate_attributes: BaptismalCertificate.permitted_params,
       sponsor_covenant_attributes: SponsorCovenant.permitted_params,
       sponsor_eligibility_attributes: SponsorEligibility.permitted_params,
       pick_confirmation_name_attributes: PickConfirmationName.permitted_params,
       christian_ministry_attributes: ChristianMinistry.permitted_params,
       candidate_events_attributes: CandidateEvent.permitted_params,
       retreat_verification_attributes: RetreatVerification.permitted_params }]
  end

  # Validate if association_class event is complete by adding validation errors to active record
  #
  # === Parameters:
  #
  # * <tt>:association_class</tt> association for self related to event
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def validate_event_complete(association_class)
    association = association_class.validate_event_complete(self)
    propagate_errors_up(association, true)
  end

  # Validate if association_class event is complete by adding validation errors to active record
  #
  # === Parameters:
  #
  # * <tt>:association_class</tt> association for self related to event
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def validate_creation_complete(association_class)
    association = association_class.validate_creation_complete(self)
    propagate_errors_up(association, true)
  end

  # Array of email addresses ignoring the fact they could be nil - devise
  #
  # === Returns:
  #
  # * <tt>Array</tt> of Stings
  #
  def emails
    "#{candidate_sheet.candidate_email}, #{candidate_sheet.parent_email_1},#{candidate_sheet.parent_email_2}"
  end

  # returns the canidates email - used by Factory Girl
  #
  # === Returns:
  #
  # * <tt>String</tt> email address
  #
  def email
    candidate_sheet.candidate_email.to_s
  end

  # sets canidates email to value - used by Factory Girl
  #
  # === Parameters:
  #
  # * <tt>:value</tt> String: nil or email address
  #
  def email=(value)
    candidate_sheet.candidate_email = value
  end

  # returns false - used by Factory Girl
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def email_required?
    false
  end

  # returns false - used by Factory Girl
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def email_changed?
    false
  end

  # gets the first and last names of the candidate
  #
  # === Returns:
  #
  # * <tt>String</tt>
  #
  delegate :first_last_name, to: :candidate_sheet

  # whether the password has been changed - allows admin to know whether the candidate has signed in.
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def password_changed?
    Candidate.password_changed?(password)
    # !valid_password?(Event::Other::INITIAL_PASSWORD)
  end

  # whether the password has been changed - allows admin to know whether the candidate has
  # changed original password.
  #
  # === Parameters:
  #
  # * <tt>:encrypted_password</tt>
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def self.password_changed?(encrypted_password)
    !Devise::Encryptor.compare(Candidate, encrypted_password, Event::Other::INITIAL_PASSWORD)
  end

  # returns whether the User account has been confirmed
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def account_confirmed?
    confirmed?
  end

  # confirm the user account
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def confirm_account
    confirm
  end

  # keep only sponsor_name error messages
  #
  def keep_sponsor_name_error
    keep_interesting_errors(
      [I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.sponsor_covenant.sponsor_name'))]
    )
  end

  # keep only first, middle, and last names error messages
  #
  def keep_bc_errors
    # rubocop:disable Layout/LineLength
    keep_interesting_errors([I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.candidate_sheet.first_name')),
                             I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.candidate_sheet.middle_name')),
                             I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.candidate_sheet.last_name'))])
    # rubocop:enable Layout/LineLength
  end

  # Confirm user account when changing password
  #
  # === Parameters:
  #
  # * <tt>:resource_params</tt> parms necessary to change password
  #
  # === Returns:
  #
  # * <tt>Candidate</tt> whose password was changed
  #
  def self.reset_password_by_token(resource_params)
    candidate = super(resource_params)

    candidate.skip_confirmation! if candidate.errors.empty? && !candidate.account_confirmed?

    candidate
  end

  # returns candidate_event whose event_key is event_key
  #
  # === Parameters:
  #
  # * <tt>:event_key</tt> owner of association
  #
  # === Returns:
  #
  # * <tt>CandidateEvent</tt>
  #
  def get_candidate_event(event_key)
    event = candidate_events.find { |candidate_event| candidate_event.event_key == event_key }
    if event.nil?
      Rails.logger.info("Could not find event: #{event_key}")
      candidate_events.find { |candidate_event| Rails.logger.info candidate_event.event_key }
      raise "Unknown candidate_event named: #{event_key}"
    end
    event
  end

  # returns the I18n name for the event_key
  #
  # === Parameters:
  #
  # * <tt>:event_key</tt>
  #
  # === Returns:
  #
  # * <tt>String</tt> representing the I18n
  #
  def self.i18n_event_name(event_key)
    event_key_entry = event_keys[event_key]
    raise "unknown_event_key: #{event_key}" if event_key_entry.nil?

    I18n.t(event_key_entry[1])
  end

  @event_keys = nil

  # What does this do?
  #
  # === Parameters:
  #
  # * <tt>:new_entries</tt> owner of association
  #
  # === Returns:
  #
  # * <tt>Number</tt> number of entries
  #
  def self.add_new_event_key_entry(new_entries)
    ek = event_keys
    # make sure every entry is has same number
    num_entries = nil
    new_entries.each_pair do |key, value|
      entries = ek[key]
      raise("unknown key #{key}") if entries.nil?

      num_entries = entries.size if num_entries.nil?
      raise "Number of entries is wrong for #{key}" unless num_entries == entries.size

      entries << value
    end
    num_entries
  end

  # returns hash of event_keys
  #
  # === Returns:
  #
  # * <tt>Hash</tt> {event_key=[event_route, I18n]}
  #
  def self.event_keys
    return @event_keys if @event_keys

    @event_keys = {}
    @event_keys[BaptismalCertificate.event_key] = [
      Event::Route::BAPTISMAL_CERTIFICATE,
      'events.baptismal_certificate'
    ]
    @event_keys[CandidateSheet.event_key] = [
      Event::Other::CANDIDATE_INFORMATION_SHEET,
      'events.candidate_information_sheet'
    ]
    @event_keys[ChristianMinistry.event_key] = [
      Event::Route::CHRISTIAN_MINISTRY,
      'events.christian_ministry'
    ]
    @event_keys[covenant_agreement_event_key] = [
      Event::Other::CANDIDATE_COVENANT_AGREEMENT,
      'events.candidate_covenant_agreement'
    ]
    @event_keys[PickConfirmationName.event_key] = [
      Event::Route::CONFIRMATION_NAME,
      'events.confirmation_name'
    ]
    @event_keys[Candidate.parent_meeting_event_key] = [
      Event::Other::PARENT_INFORMATION_MEETING,
      'events.parent_meeting'
    ]
    @event_keys[RetreatVerification.event_key] = [
      Event::Route::RETREAT_VERIFICATION,
      'events.retreat_verification'
    ]
    @event_keys[SponsorCovenant.event_key] = [
      Event::Route::SPONSOR_COVENANT,
      'events.sponsor_covenant'
    ]
    @event_keys[SponsorEligibility.event_key] = [
      Event::Route::SPONSOR_ELIGIBILITY,
      'events.sponsor_eligibility'
    ]
    @event_keys
  end

  # returns the event_key given the event_route
  #
  # === Parameters:
  #
  # * <tt>:event_route</tt>
  #
  # === Returns:
  #
  # * <tt>String</tt> event_key
  #
  def self.event_key_from_route(event_route)
    case event_route.to_sym
    when Event::Route::BAPTISMAL_CERTIFICATE
      BaptismalCertificate.event_key
    when Event::Route::CHRISTIAN_MINISTRY
      ChristianMinistry.event_key
    when Event::Route::CONFIRMATION_NAME
      PickConfirmationName.event_key
    when Event::Route::SPONSOR_COVENANT
      SponsorCovenant.event_key
    when Event::Route::SPONSOR_ELIGIBILITY
      SponsorEligibility.event_key
    when Event::Route::RETREAT_VERIFICATION
      RetreatVerification.event_key
    when Event::Other::CANDIDATE_INFORMATION_SHEET
      CandidateSheet.event_key
    when Event::Other::PARENT_INFORMATION_MEETING
      Candidate.parent_meeting_event_key
    when Event::Other::CANDIDATE_COVENANT_AGREEMENT
      Candidate.covenant_agreement_event_key
    else
      raise "Unknown event_route: #{event_route}"
    end
  end

  # returns event route for given event key
  #
  # === Parameters:
  #
  # * <tt>:event_key</tt> event route
  #
  # === Returns:
  #
  # * <tt>String</tt> representing event route
  #
  def self.event_route(event_key)
    event_key_entry = event_keys[event_key]
    raise "unknown_event_key: #{event_key}" if event_key_entry.nil?

    event_key_entry[0]
  end

  # returns the association based on event name
  #
  # === Parameters:
  #
  # * <tt>:event_route_name</tt> event name
  #
  # === Returns:
  #
  # * <tt>ChristianMinistry</tt>christian_ministry with validation errors
  #
  def get_event_association(event_route_name)
    case event_route_name.to_sym
    when Event::Route::BAPTISMAL_CERTIFICATE
      baptismal_certificate
    when Event::Route::CHRISTIAN_MINISTRY
      christian_ministry
    when Event::Route::CONFIRMATION_NAME
      pick_confirmation_name
    when Event::Route::SPONSOR_COVENANT
      sponsor_covenant
    when Event::Route::SPONSOR_ELIGIBILITY
      sponsor_eligibility
    when Event::Route::RETREAT_VERIFICATION
      retreat_verification
    when Event::Other::CANDIDATE_INFORMATION_SHEET
      candidate_sheet
    when Event::Other::PARENT_INFORMATION_MEETING,
      Event::Other::ATTEND_RETREAT,
      Event::Other::CANDIDATE_COVENANT_AGREEMENT,
      Event::Other::SPONSOR_AND_CANDIDATE_CONVERSATION
      self
    else
      raise "Unknown event association: #{event_route_name}"
    end
  end

  # information to be verified by admin
  #
  # === Returns:
  #
  # * <tt>Hash</tt> of information to be verified
  #
  def verifiable_info
    {}
  end

  # returns array of completed events
  #
  # === Returns:
  #
  # * <tt>Array</tt> of completed candidate events
  #
  def completed
    candidate_events.select(&:completed?)
  end

  # returns array of coming due events
  #
  # === Returns:
  #
  # * <tt>Array</tt> of coming due candidate events
  #
  def coming_due_events
    candidate_events.select(&:coming_due?)
  end

  # returns array of 'awaiting candidate' events
  #
  # === Returns:
  #
  # * <tt>Array</tt> of 'awaiting candidate' candidate events
  #
  def awaiting_candidate_events
    candidate_events.select(&:awaiting_candidate?)
  end

  # returns array of awaiting admin events
  #
  # === Returns:
  #
  # * <tt>Array</tt> of awaiting admin candidate events
  #
  def awaiting_admin_events
    candidate_events.select(&:awaiting_admin?)
  end

  # returns array of late events
  #
  # === Returns:
  #
  # * <tt>Array</tt> of late candidate events
  #
  def late_events
    candidate_events.select(&:late?)
  end

  # external verification

  # baptismal certificate needs admin verification
  #
  # === Returns:
  #
  # * <tt>Array</tt> of external baptismal certificate verifications
  #
  def self.baptismal_external_verification
    external_verification(BaptismalCertificate.event_key,
                          ->(candidate) { candidate.baptismal_certificate.baptized_at_home_parish })
  end

  # retreat needs admin verification
  #
  # === Returns:
  #
  # * <tt>Array</tt> of external retreat verifications
  #
  def self.retreat_external_verification
    external_verification(RetreatVerification.event_key,
                          ->(candidate) { candidate.retreat_verification.retreat_held_at_home_parish })
  end

  # confirmation name needs admin verification
  #
  # === Returns:
  #
  # * <tt>Array</tt> of external confirmation name verifications
  #
  def self.confirmation_name_external_verification
    external_verification(PickConfirmationName.event_key, ->(_candidate) { false })
  end

  # return external verifications for candidate
  #
  # === Parameters:
  #
  # * <tt>:candidate_event_key</tt> event_key
  # * <tt>:external_verification</tt> Lambda
  #
  # === Returns:
  #
  # * <tt>CandidateEvent</tt>
  #
  def self.external_verification(candidate_event_key, external_verification = ->(_candidate) { false })
    external = []
    to_be_verified = []
    verified = []
    not_complete = []
    Candidate.order(:account_name).each do |candidate|
      candidate_event = candidate.get_candidate_event(candidate_event_key)
      if candidate_event.verified
        verified.push(candidate)
      elsif candidate_event.completed_date
        if external_verification.call(candidate)
          external.push(candidate)
        else
          to_be_verified.push(candidate)
        end
      else
        not_complete.push(candidate)
      end
    end
    [external, to_be_verified, verified, not_complete]
  end

  # sponsor needs admin verification
  #
  # === Returns:
  #
  # * <tt>Array</tt> of external sponsor covenant verifications
  #
  def self.sponsor_covenant_external_verification
    external_verification(SponsorCovenant.event_key, ->(_candidate) { false })
  end

  # sponsor needs admin verification
  #
  # === Returns:
  #
  # * <tt>Array</tt> of external sponsor eligibility verifications
  #
  def self.sponsor_eligibility_external_verification
    external_verification(SponsorEligibility.event_key,
                          ->(candidate) { candidate.sponsor_eligibility.sponsor_attends_home_parish })
  end

  # candidate events needs admin verification
  #
  # === Returns:
  #
  # * <tt>Array</tt>of arrays
  #
  def self.events_external_verification
    [[], Candidate.order(:account_name), [], []]
  end

  # This comes via devise/password_controller
  # The user has clicked on the Forgot Password link
  # on the sign in pane
  #
  # === Parameters:
  #
  # * <tt>:admin</tt> used for attributes
  #
  # === Returns:
  #
  # * <tt>password</tt> reset token
  #
  def send_reset_password_instructions(admin = Admin.first)
    send_grid_mail = SendGridMail.new(admin, [self])
    _response, token = send_grid_mail.reset_password
    token
  end

  # get expanded password reset instructions
  #
  # === Parameters:
  #
  # * <tt>:admin</tt> used for attributes
  # * <tt>:candidate_mailer_text</tt> expands instructions
  #
  # === Returns:
  #
  # * <tt>String</tt>
  #
  def password_reset_message(admin, candidate_mailer_text)
    token = set_reset_password_token
    candidate_mailer_text.token = token
    devise_mailer.reset_password_instructions(self, token, admin: admin)
  end

  # get expanded account confirmation instructions
  #
  # === Parameters:
  #
  # * <tt>:admin</tt> used for attributes
  # * <tt>:candidate_mailer_text</tt> expands instructions
  #
  # === Returns:
  #
  # * <tt>String</tt>
  #
  def confirmation_instructions(admin, candidate_mailer_text)
    token = generate_confirmation_token
    candidate_mailer_text.token = token
    devise_mailer.confirmation_instructions(self, token, admin: admin)
  end

  # 5.0 hack with devise
  #
  def will_save_change_to_email?
    false
  end

  private

  def keep_interesting_errors(covenant_errors)
    errors.clone.each do |error|
      errors.delete(error.attribute, error.type) if covenant_errors.detect { |xxx| error.type == xxx }.nil?
    end
  end
end
