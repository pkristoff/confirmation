#
# Actve Record
#
class BaptismalCertificate < ActiveRecord::Base
  belongs_to(:church_address, class_name: 'Address', validate: true, dependent: :destroy)
  accepts_nested_attributes_for :church_address, allow_destroy: true

  # scanned image of baptismal certificate
  belongs_to(:scanned_certificate, class_name: 'ScannedImage', validate: false, dependent: :destroy)
  accepts_nested_attributes_for(:scanned_certificate, allow_destroy: true)

  after_initialize :build_associations, :if => :new_record?

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
  def validate_event_complete(options={})
    baptized_at_stmm = options[:baptized_at_stmm]
    event_complete = true
    event_complete_validator = EventCompleteValidator.new(self, !baptized_at_stmm)
    event_complete_validator.validate([], BaptismalCertificate.get_basic_validation_params)
    unless baptized_at_stmm
      church_address.validate_event_complete
      church_address.errors.full_messages.each do |msg|
        errors[:base] << msg
        event_complete = false
      end
      found = false
      found |= (!errors.delete(:scanned_certificate).nil?)
      if found
        errors[:base] << 'Scanned baptismal certificate can\'t be blank' #TODO I18n
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
  def self.get_permitted_params
    BaptismalCertificate.get_basic_permitted_params.concat(
        [church_address_attributes: BaptismalCertificate.get_church_address_permitted_params,
         scanned_certificate_attributes: ScannedImage.get_permitted_params])
  end

  # Editable church address attributes
  #
  # === Return:
  #
  # Array of attributes
  #
  def self.get_church_address_permitted_params
    Address.get_basic_permitted_params
  end

  # Required church address attributes
  #
  # === Return:
  #
  # Array of attributes
  #
  def self.get_church_address_validation_params
    Address.get_basic_validatiion_params
  end

  # Editable attributes
  #
  # === Return:
  #
  # Array of attributes
  #
  def self.get_basic_permitted_params
    [:birth_date, :baptismal_date, :church_name, :father_first, :father_middle, :father_last,
     :mother_first, :mother_middle, :mother_maiden, :mother_last, :certificate_picture,
     :scanned_certificate, :id]
  end

  # Required attributes
  #
  # === Return:
  #
  # Array of attributes
  #
  def self.get_basic_validation_params
    params = BaptismalCertificate.get_basic_permitted_params
    params.delete(:certificate_picture)
    params
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
    baptismal_certificate.validate_event_complete(baptized_at_stmm: candidate.baptized_at_stmm)
    baptismal_certificate
  end

  # build church address
  #
  def build_associations
    church_address || create_church_address
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

end