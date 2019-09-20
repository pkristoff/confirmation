# frozen_string_literal: true

require 'constants'

#
# Person being confirmed
#
class Candidate < ApplicationRecord
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

  # turn off sending verify instructions until admin sends it.
  #
  def send_on_create_confirmation_instructions() end

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
          ce1.name <=> ce2.name
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
            ce1.name <=> ce2.name
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
          ce1.name <=> ce2.name
        else
          due_date
        end
      end
    end
  end

  # ???
  #
  # === Returns:
  #
  # * <tt>Array</tt> of conditions
  #
  def self.find_first_by_auth_conditions(tainted_conditions, options = {})
    login = tainted_conditions.delete(:account_name)
    if login
      conditions = devise_parameter_filter.filter(value: login.downcase)
      where(['lower(account_name) = :value', conditions]).first
    else
      super
    end
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
    params = attribute_names.collect(&:to_sym) & %i[account_name password]
    # params = params << :password
    params
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
    pick_confirmation_name || build_pick_confirmation_name
    christian_ministry || build_christian_ministry
    retreat_verification || build_retreat_verification
    true
  end

  # Editable attributes
  #
  # === Returns:
  #
  # * <tt>Array</tt> of attributes
  #
  def self.permitted_params
    [:account_name, :password, :password_confirmation,
     :signed_agreement, :candidate_note,
     candidate_sheet_attributes: CandidateSheet.permitted_params,
     baptismal_certificate_attributes: BaptismalCertificate.permitted_params,
     sponsor_covenant_attributes: SponsorCovenant.permitted_params,
     pick_confirmation_name_attributes: PickConfirmationName.permitted_params,
     christian_ministry_attributes: ChristianMinistry.permitted_params,
     candidate_events_attributes: CandidateEvent.permitted_params,
     retreat_verification_attributes: RetreatVerification.permitted_params]
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
    complete = true
    association = association_class.validate_event_complete(self)
    association.errors.full_messages.each do |msg|
      errors[:base] << msg
      complete = false
    end
    complete
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
    complete = true
    association = association_class.validate_creation_complete(self)
    association.errors.full_messages.each do |msg|
      errors[:base] << msg
      complete = false
    end
    complete
  end

  # If bcc is called use this email  address
  #
  # === Returns:
  #
  # * <tt>String</tt>
  #
  def bcc_email
    'stmm.confirmation@kristoffs.com'
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

  # whether the password has been changed - allows admin to know whether the candidate has signed in.
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def password_changed?
    !valid_password?(Event::Other::INITIAL_PASSWORD)
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

  # keep only first, middle, and last names error messages
  #
  def keep_bc_errors
    bc_errors = %w[First Middle Last]
    errors.messages[:base].clone.each do |msg|
      errors.messages[:base].delete(msg) if bc_errors.detect { |xxx| msg.include? xxx }.nil?
    end
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

  # returns candidate_event whose name is event_name
  #
  # === Parameters:
  #
  # * <tt>:event_name</tt> owner of association
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def get_candidate_event(event_name)
    event = candidate_events.find { |candidate_event| candidate_event.name == event_name }
    if event.nil?
      Rails.logger.info("Could not find event: #{event_name}")
      candidate_events.find { |candidate_event| Rails.logger.info candidate_event.name }
      raise "Unknown candidate_event named: #{event_name}"
    end
    event
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
    when Event::Route::RETREAT_VERIFICATION
      retreat_verification
    when Event::Other::CANDIDATE_INFORMATION_SHEET
      candidate_sheet
    when Event::Other::PARENT_INFORMATION_MEETING, Event::Other::ATTEND_RETREAT, Event::Other::CANDIDATE_COVENANT_AGREEMENT, Event::Other::SPONSOR_AND_CANDIDATE_CONVERSATION
      self
    else
      raise "Unknown event association: #{event_route_name}"
    end
  end

  # information to be verified by admin
  #
  # === Parameters:
  #
  # * <tt>:candidate</tt> owner of this association
  #
  # === Returns:
  #
  # * <tt>Hash</tt> of information to be verified
  #
  def verifiable_info(_candidate)
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
  # === Parameters:
  #
  # * <tt>:candidate</tt> owner of this association
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def self.baptismal_external_verification
    external_verification(I18n.t('events.baptismal_certificate'), ->(candidate) { candidate.baptismal_certificate.baptized_at_home_parish })
  end

  # retreat needs admin verification
  #
  # === Parameters:
  #
  # * <tt>:candidate</tt> owner of this association
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def self.retreat_external_verification
    external_verification(I18n.t('events.retreat_verification'), ->(candidate) { candidate.retreat_verification.retreat_held_at_home_parish })
  end

  # confirmation name needs admin verification
  #
  # === Parameters:
  #
  # * <tt>:candidate</tt> owner of this association
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def self.confirmation_name_external_verification
    external_verification(I18n.t('events.confirmation_name'))
  end

  def self.external_verification(candidate_event_name, external_verification = ->(_candidate) { false })
    external = []
    to_be_verified = []
    verified = []
    not_complete = []
    Candidate.order(:account_name).each do |candidate|
      candidate_event = candidate.get_candidate_event(candidate_event_name)
      if candidate_event.verified
        # puts "#{candidate.account_name} verified"
        verified.push(candidate)
      elsif candidate_event.completed_date
        if external_verification.call(candidate)
          # puts "#{candidate.account_name} external"
          external.push(candidate)
        else
          # puts "#{candidate.account_name} to be verified"
          to_be_verified.push(candidate)
        end
      else
        # puts "#{candidate.account_name} not complete"
        not_complete.push(candidate)
      end
    end
    [external, to_be_verified, verified, not_complete]
  end

  # sponsor needs admin verification
  #
  # === Parameters:
  #
  # * <tt>:candidate</tt> owner of this association
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def self.sponsor_external_verification
    external_verification(I18n.t('events.sponsor_covenant'), ->(candidate) { candidate.sponsor_covenant.sponsor_attends_home_parish })
  end

  # candidate events needs admin verification
  #
  # === Parameters:
  #
  # * <tt>:candidate</tt> owner of this association
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>Boolean
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
  def send_reset_password_instructions(admin)
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
end
