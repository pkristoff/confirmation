class Candidate < ActiveRecord::Base

  belongs_to(:address, validate: false)
  accepts_nested_attributes_for(:address, allow_destroy: true)

  has_many(:candidate_events)
  accepts_nested_attributes_for(:candidate_events, allow_destroy: true)

  belongs_to(:baptismal_certificate, validate: false)
  accepts_nested_attributes_for(:baptismal_certificate, allow_destroy: true)

  belongs_to(:sponsor_covenant, validate: false)
  accepts_nested_attributes_for(:sponsor_covenant, allow_destroy: true)

  belongs_to(:pick_confirmation_name, validate: false)
  accepts_nested_attributes_for(:pick_confirmation_name, allow_destroy: true)

  belongs_to(:christian_ministry, validate: false)
  accepts_nested_attributes_for(:christian_ministry, allow_destroy: true)

  after_initialize :build_associations, :if => :new_record?

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :authentication_keys => [:account_name],
         :reset_password_keys => [:account_name]

  validates :account_name,
            :presence => true,
            :uniqueness => {
                :case_sensitive => false
            }
  validates_presence_of :first_name, :last_name, :parent_email_1
  validate :validate_emails

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
      where(['lower(account_name) = :value OR lower(parent_email_1) = :value', conditions]).first
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

  def email
    self.parent_email_1
  end

  def email=(value)
    self.parent_email_1= value
  end

  def email_required?
    false
  end

  def email_changed?
    false
  end

  def self.candidate_params
    params = attribute_names.collect { |e| e.to_sym } & [:last_name, :first_name, :grade, :parent_email_1, :parent_email_2, :account_name, :password, :attending]
    params = params << :password
    params
  end

  def build_associations
    address || create_address
    baptismal_certificate || create_baptismal_certificate
    sponsor_covenant || create_sponsor_covenant
    pick_confirmation_name || create_pick_confirmation_name
    christian_ministry || create_christian_ministry
    true
  end

  def validate_emails()
    unless candidate_email.nil? or candidate_email.empty?
      errors.add(:candidate_email, 'is an invalid email') unless validate_email(candidate_email)
    end
    unless parent_email_1.nil? or parent_email_1.empty?
      errors.add(:parent_email_1, 'is an invalid email') unless validate_email(parent_email_1)
    end
    unless parent_email_2.nil? or parent_email_2.empty?
      errors.add(:parent_email_2, 'is an invalid email') unless validate_email(parent_email_2)
    end
  end

  def validate_email(value)
    value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  end

  # event_complete

  def self.get_permitted_params
    [:account_name, :first_name, :last_name, :candidate_email, :parent_email_1,
     :parent_email_2, :grade, :attending, :password, :password_confirmation,
     :signed_agreement, :baptized_at_stmm, :sponsor_agreement,
     address_attributes: [:street_1, :street_2, :city, :state, :zip_code],
     baptismal_certificate_attributes: BaptismalCertificate.get_permitted_params,
     sponsor_covenant_attributes: SponsorCovenant.get_permitted_params ,
     pick_confirmation_name_attributes: PickConfirmationName.get_permitted_params,
     christian_ministry_attributes: ChristianMinistry.get_permitted_params,
     candidate_events_attributes: [:id, :completed_date, :verified]
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

  # event_complete - end

  def get_candidate_event (event_name)
    candidate_events.find{|candidate_event| candidate_event.name === event_name}
  end

  def get_event_association (event_name)
    case event_name.to_sym
      when Event::Route::UPLOAD_BAPTISMAL_CERTIFICATE
        baptismal_certificate
      when Event::Route::UPLOAD_SPONSOR_COVENANT
        sponsor_covenant
      when Event::Route::PICK_CONFIRMATION_NAME
        pick_confirmation_name
      when Event::Route::CHRISTIAN_MINISTRY
        christian_ministry
      else
        raise
    end
  end

end
