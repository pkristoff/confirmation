class BaptismalCertificate < ActiveRecord::Base
  belongs_to(:church_address, class_name: 'Address', validate: true)
  accepts_nested_attributes_for :church_address, allow_destroy: true

  belongs_to(:scanned_certificate, class_name: 'ScannedImage', validate: false)
  accepts_nested_attributes_for(:scanned_certificate, allow_destroy: true)

  # before_create :build_associations
  after_initialize :build_associations, :if => :new_record?

  attr_accessor :certificate_picture

  # event_complete

  def validate_event_complete(baptized_at_stmm)
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

  def self.get_permitted_params
    BaptismalCertificate.get_basic_permitted_params.concat(
        [church_address_attributes: BaptismalCertificate.get_church_address_permitted_params,
         scanned_certificate_attributes: ScannedImage.get_permitted_params])
  end

  def self.get_church_address_permitted_params
    Address.get_basic_permitted_params
  end

  def self.get_church_address_validation_params
    Address.get_basic_validatiion_params
  end

  def self.get_basic_permitted_params
    [:birth_date, :baptismal_date, :church_name, :father_first, :father_middle, :father_last,
     :mother_first, :mother_middle, :mother_maiden, :mother_last, :certificate_picture,
     :scanned_certificate]
  end

  def self.get_basic_validation_params
    params = BaptismalCertificate.get_basic_permitted_params
    params.delete(:certificate_picture)
    params
  end

  def self.event_name
    I18n.t('events.baptismal_certificate')
  end

  def self.validate_event_complete(candidate)
    baptismal_certificate = candidate.baptismal_certificate
    baptismal_certificate.validate_event_complete(candidate.baptized_at_stmm)
    baptismal_certificate
  end

  # event_complete - end

  def build_associations
    church_address || create_church_address
  end

  # image interface  #TODO remove

  def filename_param
    :scanned_certificate.filename
  end

  def content_type_param
    :scanned_certificate.content_type
  end

  def file_contents_param
    :scanned_certificate.contents
  end

  def filename
    scanned_certificate.filename
  end

  def filename=(name)
    scanned_certificate.filename=name
  end

  def content_type
    scanned_certificate.content_type
  end

  def content_type=(type)
    scanned_certificate.content_type=type
  end

  def file_contents
    scanned_certificate.contents
  end

  def file_contents=(contents)
    scanned_certificate.contents=contents
  end

  # image interface - end

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