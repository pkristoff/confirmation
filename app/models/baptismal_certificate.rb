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
    # 1: user has saved a selection for baptized_at_home_parish but not for first_comm_at_home_parish
    # 2: user has made changes to to both
    case show_empty_radio
    when 0
      errors[:base] << I18n.t('messages.error.baptized_should_be_checked', home_parish: Visitor.home_parish)
      false
    when 1
      return true if baptized_at_home_parish

      errors[:base] << I18n.t('messages.error.first_communion_should_be_checked', home_parish: Visitor.home_parish)
      false
    when 2
      return true if first_comm_at_home_parish

      validate_other_info
    else
      raise(I18n.t('messages.error.unknown_show_empty_radio', show_empty_radio: show_empty_radio))
    end
  end

  # This validates all the information needed when home parish does not have the baptismal certificate
  #
  # === Returns:
  #
  # * <tt>Boolean</tt> - whether the event can be marked complete.
  #
  def validate_other_info
    event_complete = true
    event_complete_validator = EventCompleteValidator.new(self, !first_comm_at_home_parish)
    event_complete_validator.validate([], BaptismalCertificate.basic_validation_params)
    unless baptized_at_home_parish
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
  # === Returns:
  #
  # * <tt>Array</tt> of attributes
  #
  def self.permitted_params
    BaptismalCertificate.basic_permitted_params.concat(
      [church_address_attributes: Address.basic_permitted_params,
       scanned_certificate_attributes: ScannedImage.permitted_params]
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

  # Required attributes
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
  def self.event_name
    'Baptismal Certificate'
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

  # Whether to show first communion as yes
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def first_comm_at_home_parish_show_yes
    chosen_first_comm_at_home_parish? && first_comm_at_home_parish
  end

  # Whether to show first communion as no
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def first_comm_at_home_parish_show_no
    chosen_first_comm_at_home_parish? && !first_comm_at_home_parish
  end

  # Whether to show first communion info
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def first_comm_show
    chosen_baptized_at_home_parish? && !baptized_at_home_parish
  end

  # Whether candidate has chosen that they were baptised at home parish
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def chosen_baptized_at_home_parish?
    show_empty_radio.positive?
  end

  # Whether candidate has chosen that they received first communion at home parish
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def chosen_first_comm_at_home_parish?
    show_empty_radio > 1
  end

  # Whether to show info
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def info_show
    chosen_first_comm_at_home_parish? && !baptized_at_home_parish
  end
end
