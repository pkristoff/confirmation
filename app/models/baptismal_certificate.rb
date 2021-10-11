# frozen_string_literal: true

#
# Active Record
#
class BaptismalCertificate < ApplicationRecord
  belongs_to(:church_address, class_name: 'Address', validate: true, dependent: :destroy)
  accepts_nested_attributes_for :church_address, allow_destroy: true

  belongs_to(:prof_church_address, class_name: 'Address', validate: true, dependent: :destroy)
  accepts_nested_attributes_for :prof_church_address, allow_destroy: true

  belongs_to(:scanned_certificate, class_name: 'ScannedImage', validate: false, dependent: :destroy)
  accepts_nested_attributes_for(:scanned_certificate, allow_destroy: true)

  belongs_to(:scanned_prof, class_name: 'ScannedImage', validate: false, dependent: :destroy)
  accepts_nested_attributes_for(:scanned_prof, allow_destroy: true)

  after_initialize :build_associations, if: :new_record?

  attr_accessor :certificate_picture, :remove_certificate_picture, :prof_picture, :remove_prof_picture

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
    return if show_empty_radio.zero? || show_empty_radio == 1 || show_empty_radio == 2

    errors.add(:show_empty_radio, "can only be 0 or 1 or 2 not #{show_empty_radio}")
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
    #     if baptized_at_home_parish == true then done
    #     if baptized_at_home_parish == false then baptized_catholic will not show yes or no as selected
    # 2: User has chosen baptized_catholic(true or false)
    case show_empty_radio
    when 0
      errors[:base] << I18n.t('messages.error.baptized_should_be_checked', home_parish: Visitor.home_parish)
      validate_basic_info
      false
    when 1
      basic_valid = validate_basic_info
      return basic_valid if baptized_at_home_parish

      errors[:base] << I18n.t('messages.error.baptized_catholic_should_be_checked')
      validate_other_church_info

      false
    when 2
      basic_valid = validate_basic_info

      other_valid = validate_other_church_info
      return other_valid && basic_valid if baptized_catholic

      validate_profession_of_faith && other_valid && basic_valid
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
    event_complete_validator.validate(basic_validation_params)
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
    event_complete_validator.validate(baptized_catholic_validation_params)
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

  # This validates all the information needed when home parish does not have the baptismal certificate
  #
  # === Returns:
  #
  # * <tt>Boolean</tt> - whether the event can be marked complete.
  #
  def validate_profession_of_faith
    event_complete = true
    event_complete_validator = EventCompleteValidator.new(self)
    event_complete = event_complete_validator.validate(prof_of_faith_validation_params)
    prof_church_address.validate_event_complete
    prof_church_address.errors.full_messages.each do |msg|
      errors[:base] << msg
      event_complete = false
    end
    found = false
    found |= !errors.delete(:scanned_prof).nil?
    if found
      errors[:base] << "Scanned Profession 0f faith #{I18n.t('errors.messages.blank')}" # TODO: I18n
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
         prof_church_address_attributes: Address.basic_permitted_params,
         scanned_certificate_attributes: ScannedImage.permitted_params,
         scanned_prof_attributes: ScannedImage.permitted_params }]
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
       baptized_catholic
       prof_picture remove_prof_picture
       scanned_certificate scanned_prof id baptized_at_home_parish show_empty_radio prof_church_name prof_date]
  end

  # Returns array of params to be validated once baptized_in_home_parish
  #
  # === Returns:
  #
  # * <tt>Array</tt> of symbols
  #
  def self.home_parish_validate_params
    %I[birth_date baptismal_date
       father_first father_middle father_last
       mother_first mother_middle mother_maiden mother_last]
  end

  # Returns array of params when baptized_catholic=true
  #
  # === Returns:
  #
  # * <tt>Array</tt> of symbols
  #
  def self.baptized_catholic_validate_params
    %i[scanned_certificate church_name]
  end

  # Returns array of params when baptized_catholic=false
  #
  # === Returns:
  #
  # * <tt>Array</tt> of symbols
  #
  def self.prof_of_faith_validate_params
    %i[scanned_prof prof_date prof_church_name]
  end

  # Returns array of params to never validate
  #
  # === Returns:
  #
  # * <tt>Array</tt> of symbols
  #
  def self.do_not_validate_params
    %i[certificate_picture remove_certificate_picture baptized_catholic baptized_at_home_parish prof_picture remove_prof_picture]
  end

  # Returns array of params when baptized_catholic=true
  #
  # === Returns:
  #
  # * <tt>Array</tt> of symbols
  #
  def baptized_catholic_validation_params
    params = BaptismalCertificate.basic_permitted_params
    BaptismalCertificate.do_not_validate_params.each { |xxx| params.delete xxx }
    BaptismalCertificate.home_parish_validate_params.each { |xxx| params.delete xxx }
    BaptismalCertificate.prof_of_faith_validate_params.each { |xxx| params.delete xxx }
    params
  end

  # Returns array of params when baptized_catholic=false
  #
  # === Returns:
  #
  # * <tt>Array</tt> of symbols
  #
  def prof_of_faith_validation_params
    params = BaptismalCertificate.basic_permitted_params
    BaptismalCertificate.do_not_validate_params.each { |xxx| params.delete xxx }
    BaptismalCertificate.home_parish_validate_params.each { |xxx| params.delete xxx }
    BaptismalCertificate.baptized_catholic_validate_params.each { |xxx| params.delete xxx }
    params
  end

  # Validation params whether baptized at home parish or not
  #
  # === Returns:
  #
  # * <tt>Array</tt> of attributes
  #
  def basic_validation_params
    params = BaptismalCertificate.basic_permitted_params
    BaptismalCertificate.do_not_validate_params.each { |xxx| params.delete xxx }
    BaptismalCertificate.baptized_catholic_validate_params.each { |xxx| params.delete xxx }
    BaptismalCertificate.prof_of_faith_validate_params.each { |xxx| params.delete xxx }
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
  def self.event_key
    'baptismal_certificate'
  end

  # build church address
  #
  def build_associations
    church_address || build_church_address
    prof_church_address || build_prof_church_address
    # scanned_certificate is built on the fly.
  end

  # information to be verified by admin
  #
  # === Returns:
  #
  # * <tt>Hash</tt> of information to be verified
  #
  def verifiable_info
    if baptized_at_home_parish
      verifiables_baptized_at_home_parish
    elsif !baptized_at_home_parish && baptized_catholic
      verifiables_baptized_at_home_parish.merge(verifiables_baptized_catholic)
    else
      verifiables_baptized_at_home_parish.merge(verifiables_baptized_catholic)
                                         .merge(verifiables_profession_of_faith)
    end
  end

  # UI stuff

  # Whether to show baptized catholic as yes
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def baptized_catholic_yes_checked
    chosen_baptized_catholic? && baptized_catholic
  end

  # UI stuff

  # Whether to show baptized catholic as no
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def baptized_catholic_no_checked
    chosen_baptized_catholic? && !baptized_catholic?
  end

  # UI stuff

  # Whether to show baptized at home parish as yes
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def baptized_at_home_parish_yes_checked
    chosen_baptized_at_home_parish? && baptized_at_home_parish
  end

  # Whether to show baptized at home parish as no
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def baptized_at_home_parish_no_checked
    chosen_baptized_at_home_parish? && !baptized_at_home_parish
  end

  # Whether candidate has chosen that they were baptised at home parish
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def chosen_baptized_catholic?
    show_empty_radio == 2
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
    chosen_baptized_at_home_parish?
  end

  # Whether to show info
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def show_baptized_catholic_radio
    chosen_baptized_at_home_parish? && !baptized_at_home_parish
  end

  # Whether to show info baptized catholic
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def info_show_baptized_catholic
    chosen_baptized_catholic? && !baptized_at_home_parish
  end

  # Whether to show info profession of faith
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def info_show_profession_of_faith
    chosen_baptized_catholic? && !baptized_catholic
  end

  private

  def verifiables_baptized_at_home_parish
    {
      Birthday: birth_date,
      'Baptismal date': baptismal_date,
      'Father\'s name': "#{father_first} #{father_middle} #{father_last}",
      'Mother\'s name': "#{mother_first} #{mother_middle} #{mother_maiden} #{mother_last}"
    }
  end

  def verifiables_baptized_catholic
    {
      Church: church_name,
      Street: church_address.street_1,
      'Street 2': church_address.street_2,
      City: church_address.city,
      State: church_address.state,
      'Zip Code': church_address.zip_code
    }
  end

  def verifiables_profession_of_faith
    {
      'Prof date': prof_date,
      'Prof church': prof_church_name,
      'Prof street': prof_church_address.street_1,
      'Prof street 2': prof_church_address.street_2,
      'Prof city': prof_church_address.city,
      'Prof state': prof_church_address.state,
      'Prof zip code': prof_church_address.zip_code
    }
  end
end
