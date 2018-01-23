#
# Basic information about candidate.
#
class CandidateSheet < ActiveRecord::Base
  belongs_to(:address, class_name: 'Address', validate: true, dependent: :destroy)
  accepts_nested_attributes_for :address, allow_destroy: true

  after_initialize :build_associations, :if => :new_record?

  validates_presence_of(:first_name, :last_name)

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
    event_complete_validator = EventCompleteValidator.new(self)
    event_complete_validator.validate(CandidateSheet.get_basic_validation_params)
    validate_emails
    event_complete = !errors.any?
    address.validate_event_complete
    address.errors.full_messages.each do |msg|
      errors[:base] << msg
      event_complete = false
    end
    event_complete
  end

  # Editable attributes
  #
  # === Return:
  #
  # Array of attributes
  #
  def self.get_permitted_params
    CandidateSheet.get_basic_permitted_params.concat([address_attributes: Address.get_basic_permitted_params])
  end

  # Editable attributes
  #
  # === Return:
  #
  # Array of attributes
  #
  def self.get_basic_permitted_params
    [:first_name, :middle_name, :last_name, :candidate_email, :parent_email_1, :parent_email_2, :grade, :attending, :id]
  end

  # Required attributes
  #
  # === Return:
  #
  # Array of attributes
  #
  def self.get_basic_validation_params
    params = CandidateSheet.get_basic_permitted_params
    params.delete(:middle_name)
    params.delete(:candidate_email)
    params.delete(:parent_email_1)
    params.delete(:parent_email_2)
    params
  end

  # Validate if event is complete by adding validation errors to active record
  #
  # === Parameters:
  #
  # * <tt>:candidate</tt> owner of association
  #
  # === Return:
  #
  # candidate_sheet with validation errors
  #
  def self.validate_event_complete(candidate)
    candidate_sheet = candidate.candidate_sheet
    candidate_sheet.validate_event_complete
    candidate_sheet
  end

  # associated confirmation event name
  #
  # === Return:
  #
  # String
  #
  def self.event_name
    I18n.t('events.candidate_information_sheet')
  end

  # build address
  #
  def build_associations
    address || build_address
  end

  # returns the parent_1's email - used by Factory Girl
  #
  # === Return:
  #
  # email address String
  #
  def email
    parent_email_1
  end

  # sets canidates email to value - used by Factory Girl
  #
  # === Parameters:
  #
  # * <tt>:value</tt> String: nil or email address
  #
  def email=(value)
    parent_email_1= value
  end

  # returns false - used by Factory Girl
  #
  # === Return:
  #
  # boolean
  #
  def email_required?
    false
  end

  # returns false - used by Factory Girl
  #
  # === Return:
  #
  # boolean
  #
  def email_changed?
    false
  end

  # Validate if email addrresses are either nil or a valid email syntax.
  #
  def validate_emails
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

  # Validate if value is a valid email addrress.
  #
  def validate_email(value)
    value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
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

  # Attempts to guarentee that there is always a 'to' email
  #   1. if candidate_email is not nil then return it.
  #   2. if parent_1 email is not nil then return it.
  #   3. if parent_2 email is not nil then return it.
  #   4. Otherwise return ''.
  #
  # === Return:
  #
  # String: email address or nil
  #
  def to_email
    return candidate_email unless (candidate_email.nil? || candidate_email.empty?)
    return parent_email_1 unless (parent_email_1.nil? || parent_email_1.empty?)
    parent_email_2
  end

  # Attempts to guarentee that there is always a 'to' email
  #   1. if parent_1 email is not nil and not used in to_email then return it.
  #   2. if parent_2 email is not nil then return it.
  #   3. Otherwise return ''.
  #
  # === Return:
  #
  # String: email address or nil
  #
  def cc_email
    if candidate_email.nil? || candidate_email.empty?
      return parent_email_2 unless (parent_email_1.nil? || parent_email_1.empty?)
      ''
    else
      return parent_email_1 unless (parent_email_1.nil? || parent_email_1.empty?)
      parent_email_2
    end
  end

  # Attempts to guarentee that there is always a 'to' email
  #   1. if parent_2 email is not nil and not used in to_email or in cc_mail then return it.
  #   2. Otherwise return ''.
  #
  # === Return:
  #
  # String: email address or nil
  #
  def cc_email_2
    return parent_email_2 unless (candidate_email.nil? || candidate_email.empty?) || (parent_email_1.nil? || parent_email_1.empty?)
    ''
  end

end
