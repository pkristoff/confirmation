# frozen_string_literal: true

#
# Basic information about candidate.
#
class CandidateSheet < ApplicationRecord
  belongs_to(:address, class_name: 'Address', validate: true, dependent: :destroy)
  accepts_nested_attributes_for :address, allow_destroy: true

  after_initialize :build_associations, if: :new_record?

  validates_presence_of(:first_name, :last_name)

  # Validate if event is complete by adding validation errors to active record
  #
  # === Parameters:
  #
  # * <tt>:options</tt> If true then nothing else needs to be added
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def validate_event_complete(_options = {})
    event_complete_validator = EventCompleteValidator.new(self)
    event_complete_validator.validate(CandidateSheet.basic_validation_params)
    validate_emails
    event_complete = errors.none?
    address.validate_event_complete
    address.errors.full_messages.each do |msg|
      errors[:base] << msg
      event_complete = false
    end
    event_complete
  end

  # Editable attributes
  #
  # === Returns:
  #
  # * <tt>Array</tt> of attributes
  #
  def self.permitted_params
    CandidateSheet.basic_permitted_params.concat([address_attributes: Address.basic_permitted_params])
  end

  # Editable attributes
  #
  # === Returns:
  #
  # * <tt>Array</tt> of attributes
  #
  def self.basic_permitted_params
    %i[first_name middle_name last_name candidate_email parent_email_1 parent_email_2 grade attending id]
  end

  # Required attributes
  #
  # === Returns:
  #
  # * <tt>Array</tt> of attributes
  #
  def self.basic_validation_params
    params = CandidateSheet.basic_permitted_params
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
  # === Returns:
  #
  # * <tt>CandidateSheet</tt>candidate_sheet with validation errors
  #
  def self.validate_event_complete(candidate)
    candidate_sheet = candidate.candidate_sheet
    candidate_sheet.validate_event_complete
    candidate_sheet
  end

  # associated confirmation event name
  #
  # === Returns:
  #
  # * <tt>String</tt>
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
  # === Returns:
  #
  # * <tt>String</tt>email address
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
    self.parent_email_1 = value
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

  # Validate if email addrresses are either nil or a valid email syntax.
  #
  def validate_emails
    errors.add(:candidate_email, "is an invalid email: #{candidate_email}") unless validate_email(candidate_email)
    errors.add(:parent_email_1, "is an invalid email: #{parent_email_1}") unless validate_email(parent_email_1)
    errors.add(:parent_email_2, "is an invalid email: #{parent_email_2}") unless validate_email(parent_email_2)
  end

  # Validate if email is a valid email addrress.
  #
  # === Parameters:
  #
  # * <tt>:email</tt> String
  #
  def validate_email(email)
    return true if email.blank?
    email =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
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
    # TODO: come up with prettier names
    { name: "#{first_name} #{last_name}",
      grade: grade,
      street_1: address.street_1,
      street_2: address.street_2,
      city: address.city,
      state: address.state,
      zipcode: address.zip_code }
  end

  # Attempts to guarentee that there is always a 'to' email
  #   1. if candidate_email is not nil then return it.
  #   2. if parent_1 email is not nil then return it.
  #   3. if parent_2 email is not nil then return it.
  #   4. Otherwise return ''.
  #
  # === Returns:
  #
  # * <tt>String</tt> email address or nil
  #
  def to_email
    return candidate_email if candidate_email.present?
    return parent_email_1 if parent_email_1.present?
    parent_email_2
  end

  # Attempts to guarentee that there is always a 'to' email
  #   1. if parent_1 email is not nil and not used in to_email then return it.
  #   2. if parent_2 email is not nil then return it.
  #   3. Otherwise return ''.
  #
  # === Returns:
  #
  # * <tt>String</tt> email address or nil
  #
  def cc_email
    if candidate_email.blank?
      return parent_email_2 if parent_email_1.present?
      ''
    else
      return parent_email_1 if parent_email_1.present?
      parent_email_2
    end
  end

  # Attempts to guarentee that there is always a 'to' email
  #   1. if parent_2 email is not nil and not used in to_email or in cc_mail then return it.
  #   2. Otherwise return ''.
  #
  # === Returns:
  #
  # * <tt>String</tt> email address or nil
  #
  def cc_email_2
    return parent_email_2 unless candidate_email.blank? || parent_email_1.blank?
    ''
  end
end
