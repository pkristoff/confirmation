class BaptismalCertificateValidator < ActiveModel::Validator
# TODO: duplicate - get from somewhere else
  FIELDS = [:birth_date, :baptismal_date, :church_name, :father_first, :father_middle, :father_last,
            :mother_first, :mother_middle, :mother_maiden, :mother_last]
  ADDRESS = [:street_1, :city, :state, :zip_code]
  PICTURES = [:certificate_filename, :certificate_content_type, :certificate_file_contents]

  def initialize(baptismal_cert, baptized_at_stmm)
    @baptismal_certificate = baptismal_cert
    @baptized_at_stmm = baptized_at_stmm
  end

  def validate
    return true if @baptized_at_stmm

    @baptismal_certificate.validates_presence_of FIELDS
    church_address = @baptismal_certificate.church_address
    church_address.validates_presence_of ADDRESS
    church_address.errors.full_messages.each do |msg|
      @baptismal_certificate.errors[:base] << msg
    end
    @baptismal_certificate.validates_presence_of PICTURES
    !@baptismal_certificate.errors.any?
  end
end

class BaptismalCertificate < ActiveRecord::Base
  belongs_to(:church_address, class_name: 'Address', validate: true)
  accepts_nested_attributes_for :church_address, allow_destroy: true

  # before_create :build_associations
  after_initialize :build_associations, :if => :new_record?

  # validate :validate_self

  attr_accessor :certificate_picture

  def build_associations
    church_address || create_church_address
  end

  def validate_self(baptized_at_stmm)
    BaptismalCertificateValidator.new(self, baptized_at_stmm).validate
  end

end