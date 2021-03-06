# frozen_string_literal: true

#
# Active Record
#
class BaptismalCertificate < ApplicationRecord
  belongs_to(:church_address, class_name: 'Address', validate: true, dependent: :destroy)
  accepts_nested_attributes_for :church_address, allow_destroy: true

  belongs_to(:scanned_certificate, class_name: 'ScannedImage', validate: false, dependent: :destroy)
  accepts_nested_attributes_for(:scanned_certificate, allow_destroy: true)

  after_initialize :build_associations, if: :new_record?

  attr_accessor :certificate_picture, :remove_certificate_picture

  validate :validate_show_empty_radio

  # A common method for retrieving the scanned image for this
  # event.
  #
  # === Returns:
  #
  # * <tt>ScannedImage</tt>
  #
  def scanned_image
    scanned_certificate
  end

  # A common method for retrieving the scanned image id for this
  # event.
  #
  # === Returns:
  #
  # * <tt>Integer</tt> id
  #
  def scanned_image_id
    scanned_certificate_id
  end

  # Validate if show_empty_radio is either or 1
  #
  def validate_show_empty_radio
    return if show_empty_radio.zero? || show_empty_radio == 1

    errors.add(:show_empty_radio, "can only be 0 or 1 not #{show_empty_radio}")
  end

  # Validate if event is complete by adding validation errors to active record
  #
  # === Parameters:
  #
  # * <tt>:options</tt>
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def validate_event_complete(_options = {})
    # 0: user has never saved this thus when baptized_at_home_parish will not show yes or no as selected
    # 1: user has saved a selection for baptized_at_home_parish
    # 2: First communion is NOT a choice
    case show_empty_radio
    when 0
      errors[:base] << I18n.t('messages.error.baptized_should_be_checked', home_parish: Visitor.home_parish)
      validate_basic_info
      false
    when 1
      basic_valid = validate_basic_info
      return basic_valid if baptized_at_home_parish

      # errors[:base] << I18n.t('messages.error.first_communion_should_be_checked', home_parish: Visitor.home_parish)
      validate_other_church_info && basic_valid
    when 2
      raise('show_empty_radio should never be 2')
    else
      raise(I18n.t('messages.error.unknown_show_empty_radio', show_empty_radio: show_empty_radio))
    end
  end

  # This validates all the information needed whether home parish has the baptismal certificate
  #
  # === Returns:
  #
  # * <tt>Boolean</tt> - whether the event can be marked complete.
  #
  def validate_basic_info
    event_complete_validator = EventCompleteValidator.new(self)
    event_complete_validator.validate(BaptismalCertificate.basic_validation_params)
  end

  # This validates all the information needed when home parish does not have the baptismal certificate
  #
  # === Returns:
  #
  # * <tt>Boolean</tt> - whether the event can be marked complete.
  #
  def validate_other_church_info
    event_complete = true
    event_complete_validator = EventCompleteValidator.new(self)
    event_complete = event_complete_validator.validate(BaptismalCertificate.basic_validate_non_home_parish_params)
    church_address.validate_event_complete
    church_address.errors.full_messages.each do |msg|
      errors[:base] << msg
      event_complete = false
    end
    found = false
    found |= !errors.delete(:scanned_certificate).nil?
    if found
      errors[:base] << "Scanned baptismal certificate #{I18n.t('errors.messages.blank')}" # TODO: I18n
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
    BaptismalCertificate.basic_permitted_params.concat(
      [{ church_address_attributes: Address.basic_permitted_params,
         scanned_certificate_attributes: ScannedImage.permitted_params }]
    )
  end

  # Editable attributes
  #
  # === Returns:
  #
  # * <tt>Array</tt> of attributes
  #
  def self.basic_permitted_params
    %I[birth_date baptismal_date church_name father_first father_middle father_last
       mother_first mother_middle mother_maiden mother_last certificate_picture remove_certificate_picture
       scanned_certificate id baptized_at_home_parish first_comm_at_home_parish show_empty_radio]
  end

  # Validation params whether baptized at home parish or not
  #
  # === Returns:
  #
  # * <tt>Array</tt> of attributes
  #
  def self.basic_validation_params
    params = BaptismalCertificate.basic_permitted_params
    params.delete(:certificate_picture)
    params.delete(:remove_certificate_picture)
    params.delete(:baptized_at_home_parish)
    params.delete(:first_comm_at_home_parish)
    params.delete(:church_name)
    params.delete(:scanned_certificate)
    params
  end

  def self.basic_validate_non_home_parish_params
    %i[church_name scanned_certificate]
  end

  # Validate if event is complete by adding validation errors to active record
  #
  # === Parameters:
  #
  # * <tt>:candidate</tt> owner of association
  #
  # === Returns:
  #
  # * <tt>baptismal_certificate</tt> with validation errors
  #
  def self.validate_event_complete(candidate)
    baptismal_certificate = candidate.baptismal_certificate
    baptismal_certificate.validate_event_complete
    baptismal_certificate
  end

  # associated confirmation event name
  #
  # === Returns:
  #
  # * <tt>String</tt>
  #
  def self.event_key
    'baptismal_certificate'
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
  # === Returns:
  #
  # * <tt>Hash</tt> of information to be verified
  #
  def verifiable_info(candidate)
    if candidate.baptismal_certificate.baptized_at_home_parish
      {
        Church: Visitor.home_parish
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

  # Whether to show baptized as yes
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def baptized_at_home_parish_show_yes
    chosen_baptized_at_home_parish? && baptized_at_home_parish
  end

  # Whether to show baptized as no
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def baptized_at_home_parish_show_no
    chosen_baptized_at_home_parish? && !baptized_at_home_parish
  end

  # Whether candidate has chosen that they were baptised at home parish
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def chosen_baptized_at_home_parish?
    show_empty_radio == 1 || show_empty_radio == 2
  end

  # Whether to show info
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def info_show
    chosen_baptized_at_home_parish? && !baptized_at_home_parish
  end
end
