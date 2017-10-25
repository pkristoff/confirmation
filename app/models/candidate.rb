require 'constants'

class Candidate < ActiveRecord::Base
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

  after_initialize :build_associations, :if => :new_record?

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable, :timeoutable,
         :recoverable, :rememberable, :trackable, :validatable,
         :authentication_keys => [:account_name],
         :reset_password_keys => [:account_name]

  validates :account_name,
            :presence => true,
            :uniqueness => {
                :case_sensitive => false
            }

  def send_on_create_confirmation_instructions
    # turn off sending verify instructions until admin sends it.
  end

  def candidate_events_sorted
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
      else
        if ce2.due_date.nil?
          1
        else
          # due_dates filled in.
          if ce1.completed_date.nil?
            if ce2.completed_date.nil?
              # if neither completed then the first to come
              # due is first
              due_date = ce1.due_date <=> ce2.due_date
              if due_date == 0
                ce1.name <=> ce2.name
              else
                due_date
              end
            else
              # non completed goes on top.
              -1
            end
          else
            # non completed goes on top.
            if ce2.completed_date.nil?
              1
            else
              # if both are completed then the first to come
              # due is on top
              due_date = ce1.due_date <=> ce2.due_date
              if due_date == 0
                ce1.name <=> ce2.name
              else
                due_date
              end
            end
          end
        end
      end
    end
  end

  def self.find_first_by_auth_conditions(tainted_conditions, options = {})
    login = tainted_conditions.delete(:account_name)
    if login
      conditions = devise_parameter_filter.filter(value: login.downcase)
      where(['lower(account_name) = :value', conditions]).first
    else
      super
    end
  end

  def add_candidate_event (confirmation_event)
    candidate_event = AppFactory.create_candidate_event(confirmation_event)
    candidate_events << candidate_event
    candidate_event.candidate = self
    candidate_event
  end

  def self.candidate_params
    params = attribute_names.collect { |e| e.to_sym } & [:account_name, :password]
    params = params << :password
    params
  end

  def build_associations
    candidate_sheet || create_candidate_sheet
    baptismal_certificate || create_baptismal_certificate
    sponsor_covenant || create_sponsor_covenant
    pick_confirmation_name || create_pick_confirmation_name
    christian_ministry || create_christian_ministry
    retreat_verification || create_retreat_verification
    true
  end

  # event_complete

  def self.get_permitted_params
    [:account_name, :password, :password_confirmation,
     :signed_agreement, :baptized_at_stmm, :sponsor_agreement,
     candidate_sheet_attributes: CandidateSheet.get_permitted_params,
     baptismal_certificate_attributes: BaptismalCertificate.get_permitted_params,
     sponsor_covenant_attributes: SponsorCovenant.get_permitted_params,
     pick_confirmation_name_attributes: PickConfirmationName.get_permitted_params,
     christian_ministry_attributes: ChristianMinistry.get_permitted_params,
     candidate_events_attributes: CandidateEvent.get_permitted_params,
     retreat_verification_attributes: RetreatVerification.get_permitted_params
    ]
  end

  def validate_event_complete (association_class)
    complete = true
    association = association_class.validate_event_complete(self)
    association.errors.full_messages.each do |msg|
      errors[:base] << msg
      complete = false
    end
    complete
  end

  def bcc_email
    'stmm.confirmation@kristoffs.com'
  end

  def emails
    "#{candidate_sheet.candidate_email}, #{candidate_sheet.parent_email_1},#{candidate_sheet.parent_email_2}"
  end

  def email
    "#{candidate_sheet.candidate_email}"
  end

  def email=(value)
    candidate_sheet.candidate_email = value
  end

  def email_required?
    false
  end

  def email_changed?
    false
  end

  # event_complete - end

  def password_changed?
    !valid_password?(Event::Other::INITIAL_PASSWORD)
  end

  def account_confirmed?
    confirmed?
  end

  def confirm_account
    confirm
  end

  def self.reset_password_by_token(resource_params)

    candidate = super(resource_params)
    if candidate.errors.empty? && !candidate.account_confirmed?
      candidate.skip_confirmation!
    end
    candidate
  end

  def get_candidate_event (event_name)
    event = candidate_events.find { |candidate_event| candidate_event.name === event_name }
    if event.nil?
      puts "Could not find event: #{event_name}"
      candidate_events.find { |candidate_event| puts candidate_event.name }
      raise "Unknown candidate_event named: #{event_name}"
    end
    event
  end

  def get_event_association (event_route_name)
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

  def verifiable_info(candidate)
    {}
  end

  def get_completed
    candidate_events.select do |candidate_event|
      candidate_event.completed?
    end
  end

  def get_coming_due_events
    candidate_events.select do |candidate_event|
      candidate_event.coming_due?
    end
  end

  def get_awaiting_candidate_events
    candidate_events.select do |candidate_event|
      candidate_event.awaiting_candidate?
    end
  end

  def get_awaiting_admin_events
    candidate_events.select do |candidate_event|
      candidate_event.awaiting_admin?
    end
  end

  def get_late_events
    candidate_events.select do |candidate_event|
      candidate_event.late?
    end
  end

  def self.scoped (options)
    Candidate.order(options[:order])
  end

  # external verification
  def self.baptismal_external_verification?(candidate)
    candidate_event = candidate.get_candidate_event(I18n.t('events.baptismal_certificate'))
    candidate.baptized_at_stmm && candidate_event.completed_date && !candidate_event.verified
  end

  def self.retreat_external_verification?(candidate)
    candidate_event = candidate.get_candidate_event(I18n.t('events.retreat_verification'))
    candidate.retreat_verification.retreat_held_at_stmm && candidate_event.completed_date && !candidate_event.verified
  end

  def self.sponsor_external_verification?(candidate)
    candidate_event = candidate.get_candidate_event(I18n.t('events.sponsor_covenant'))
    candidate.sponsor_covenant.sponsor_attends_stmm && candidate_event.completed_date && !candidate_event.verified
  end

  def self.events_external_verification?(candidate)
    true
  end

  def password_reset_message
    token = set_reset_password_token
    devise_mailer.reset_password_instructions(self, token)
    # message = delivery.message
    # text = message.body.to_s
    # text
  end

  def confirmation_instructions
    token = generate_confirmation_token
    devise_mailer.confirmation_instructions(self, token)
    # message = delivery.message
    # text = message.body.to_s
    # text
  end

end
