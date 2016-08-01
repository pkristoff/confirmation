class BaptismalCertificateValidator < ActiveModel::Validator
  def initialize(baptismal_cert, options)
    @options = options
    @baptismal_certificate = baptismal_cert
  end

  def validate
    if @options[:fields].any? do |field|
      value = @baptismal_certificate.send(field)
      !value.nil?
    end
      @baptismal_certificate.validates_presence_of @options[:fields]
      church_address = @baptismal_certificate.church_address
      church_address.validates_presence_of @options[:address]
      if church_address.errors.any?
        @baptismal_certificate.errors.add(:church_address, :invalid)
      end
    end
    if @options[:pictures_fields].any? do |field|
      value = @baptismal_certificate.send(field)
      !value.nil?
    end
      @baptismal_certificate.validates_presence_of @options[:pictures_fields]
    end
  end

  def validate_for_completion
      @baptismal_certificate.validates_presence_of @options[:fields]
  end
end

class BaptismalCertificate < ActiveRecord::Base
  belongs_to(:church_address, class_name: 'Address', validate: true)
  accepts_nested_attributes_for :church_address, allow_destroy: true

  validate :validate_self

  attr_accessor :certificate_picture

  def validate_self
    BaptismalCertificateValidator.new(self, fields: [:birth_date, :baptismal_date, :church_name, :father_first, :father_middle, :father_last,
                                                     :mother_first, :mother_middle, :mother_maiden, :mother_last],
                                      address: [:street_1, :city, :state, :zip_code],
                                      pictures_fields: [:certificate_filename, :certificate_content_type, :certificate_file_contents])
        .validate
  end

  def validate_for_completion
    BaptismalCertificateValidator.new(self, fields: [:birth_date, :baptismal_date, :church_name, :father_first, :father_middle, :father_last,
                                                     :mother_first, :mother_middle, :mother_maiden, :mother_last, :certificate_filename, :certificate_content_type, :certificate_file_contents])
        .validate_for_completion
  end

end