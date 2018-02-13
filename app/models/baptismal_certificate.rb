# frozen_string_literal: true

#
# Active Record
#
class BaptismalCertificate < ActiveRecord::Base
  belongs_to(:church_address, class_name: 'Address', validate: true, dependent: :destroy)
  accepts_nested_attributes_for :church_address, allow_destroy: true

  belongs_to(:scanned_certificate, class_name: 'ScannedImage', validate: false, dependent: :destroy)
  accepts_nested_attributes_for(:scanned_certificate, allow_destroy: true)

  after_initialize :build_associations, if: :new_record?

  attr_accessor :certificate_picture

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
  def validate_event_complete(_options = {})
    # 0: user has never saved this thus when baptized_at_stmm will not show yes or no as selected
    # 1: user has saved a selection for baptized_at_stmm but not for first_comm_at_stmm
    # 2: user has made changes to to both
    case show_empty_radio
    when 0
      errors[:base] << 'I was Baptized at Saint Mary Magdalene should be checked.' # TODO: I18n
      false
    when 1
      return true if baptized_at_stmm
      errors[:base] << 'I received First Communion at Saint Mary Magdalene should be checked.' # TODO: I18n
      false
    when 2
      return true if first_comm_at_stmm
      validate_other_info
    else
      raise("Unknown show_empty_radio value: #{show_empty_radio}")
    end
  end

  # This validates all the information needed when St. MM does not have the baptismal certificate
  #
  # === Return:
  #
  # Boolean - whether the event can be marked complete.
  #
  def validate_other_info
    event_complete = true
    event_complete_validator = EventCompleteValidator.new(self, !first_comm_at_stmm)
    event_complete_validator.validate([], BaptismalCertificate.basic_validation_params)
    unless baptized_at_stmm
      church_address.validate_event_complete
      church_address.errors.full_messages.each do |msg|
        errors[:base] << msg
        event_complete = false
      end
      found = false
      found |= !errors.delete(:scanned_certificate).nil?
      if found
        errors[:base] << 'Scanned baptismal certificate can\'t be blank' # TODO: I18n
        event_complete = false
      end
    end
    event_complete
  end

  # Editable attributes
  #
  # === Return:
  #
  # Array of attributes
  #
  def self.permitted_params
    BaptismalCertificate.basic_permitted_params.concat(
      [church_address_attributes: Address.basic_permitted_params,
       scanned_certificate_attributes: ScannedImage.permitted_params]
    )
  end

  # Editable attributes
  #
  # === Return:
  #
  # Array of attributes
  #
  def self.basic_permitted_params
    %I[birth_date baptismal_date church_name father_first father_middle father_last
       mother_first mother_middle mother_maiden mother_last certificate_picture
       scanned_certificate id baptized_at_stmm first_comm_at_stmm show_empty_radio]
  end

  # Required attributes
  #
  # === Return:
  #
  # Array of attributes
  #
  def self.basic_validation_params
    params = BaptismalCertificate.basic_permitted_params
    params.delete(:certificate_picture)
    params.delete(:baptized_at_stmm)
    params.delete(:first_comm_at_stmm)
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
  # baptismal_certificate with validation errors
  #
  def self.validate_event_complete(candidate)
    baptismal_certificate = candidate.baptismal_certificate
    baptismal_certificate.validate_event_complete
    baptismal_certificate
  end

  # associated confirmation event name
  #
  # === Return:
  #
  # String
  #
  def self.event_name
    I18n.t('events.baptismal_certificate')
  end

  # build church address
  #
  def build_associations
    church_address || build_church_address
    # scanned_certificate is built on the fly.
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
    if candidate.baptized_at_stmm
      {
        Church: I18n.t('home_parish.name')
      }
    else
      {
        Birthday: birth_date,
        'Baptismal date': baptismal_date,
        'Father\'s name': "#{father_first} #{father_middle} #{father_last}",
        'Mother\'s name': "#{mother_first} #{mother_middle} #{mother_maiden} #{mother_last}",
        Church: church_name,
        Street: church_address.street_1,
        'Street 2': church_address.street_2,
        City: church_address.city,
        State: church_address.state,
        'Zip Code': church_address.zip_code
      }
    end
  end

  # UI stuff

  def baptized_at_stmm_show_yes
    chosen_baptized_at_stmm? && baptized_at_stmm
  end

  def baptized_at_stmm_show_no
    chosen_baptized_at_stmm? && !baptized_at_stmm
  end

  def first_comm_at_stmm_show_yes
    first_comm_show && first_comm_at_stmm
  end

  def first_comm_at_stmm_show_no
    first_comm_show && !first_comm_at_stmm
  end

  def first_comm_show
    chosen_baptized_at_stmm? && !baptized_at_stmm
  end

  def chosen_baptized_at_stmm?
    show_empty_radio.positive?
  end

  def chosen_first_comm_at_stmm?
    show_empty_radio > 1
  end

  def info_show
    chosen_first_comm_at_stmm? && !first_comm_at_stmm
  end
end
