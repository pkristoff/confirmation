class CandidateSheet < ActiveRecord::Base
  belongs_to(:address, class_name: 'Address', validate: true)
  accepts_nested_attributes_for :address, allow_destroy: true

  # before_create :build_associations
  after_initialize :build_associations, :if => :new_record?
  validate :validate_emails
  validates_presence_of(:first_name, :last_name)

  # event_complete

  def validate_event_complete
    event_complete_validator = EventCompleteValidator.new(self)
    event_complete_validator.validate(CandidateSheet.get_basic_validation_params)
    event_complete = ! errors.any?
    address.validate_event_complete
    address.errors.full_messages.each do |msg|
      errors[:base] << msg
      event_complete = false
    end
    event_complete
  end

  def self.get_permitted_params
    CandidateSheet.get_basic_permitted_params.concat([address_attributes: Address.get_basic_permitted_params])
  end

  def self.get_basic_permitted_params
    [:first_name, :middle_name, :last_name, :candidate_email, :parent_email_1, :parent_email_2, :grade, :attending]
  end

  def self.get_basic_validation_params
    params = CandidateSheet.get_basic_permitted_params
    params.delete(:middle_name)
    params.delete(:candidate_email)
    params.delete(:parent_email_1)
    params.delete(:parent_email_2)
    params
  end

  def self.validate_event_complete(candidate)
    candidate_sheet = candidate.candidate_sheet
    candidate_sheet.validate_event_complete()
    candidate_sheet
  end

  def self.event_name
    I18n.t('events.candidate_information_sheet')
  end

  # event_complete - end

  def build_associations
    address || create_address
  end

  def email
    parent_email_1
  end

  def email=(value)
    parent_email_1= value
  end

  def email_required?
    false
  end

  def email_changed?
    false
  end

  def validate_emails()
    unless candidate_email.nil? or candidate_email.empty?
      errors.add(:candidate_email, "is an invalid email: #{candidate_email}") unless validate_email(candidate_email)
    end
    unless parent_email_1.nil? or parent_email_1.empty?
      errors.add(:parent_email_1, "is an invalid email: #{parent_email_1}") unless validate_email(parent_email_1)
    end
    unless parent_email_2.nil? or parent_email_2.empty?
      errors.add(:parent_email_2, "is an invalid email: #{parent_email_2}") unless validate_email(parent_email_2)
    end
  end

  def validate_email(value)
    value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  end

  def verifiable_info
    # TODO: come up with prettier names
    {name: "#{first_name} #{last_name}",
    grade: grade,
    street_1: address.street_1,
    street_2: address.street_2,
    city: address.city,
    state: address.state,
    zipcode: address.zip_code
    }
  end

end
