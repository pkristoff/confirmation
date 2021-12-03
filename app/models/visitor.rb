# frozen_string_literal: true

# holder of visitor page info.
#
class Visitor < ApplicationRecord
  before_create :confirm_singularity

  belongs_to(:home_parish_address, class_name: 'Address', validate: true, dependent: :destroy)
  accepts_nested_attributes_for :home_parish_address, allow_destroy: true

  after_initialize :build_associations, if: :new_record?

  # Editable attributes
  #
  # === Returns:
  #
  # * <tt>Array</tt> of attributes
  #
  def self.basic_permitted_params
    %i[id home about contact home_parish]
  end

  # Editable attributes
  #
  # === Returns:
  #
  # * <tt>Array</tt> of attributes
  #
  def self.permitted_params
    Visitor.basic_permitted_params.concat(
      [{ home_parish_address_attributes: Address.basic_permitted_params }]
    )
  end

  # The home parish of the current Visitor
  #
  def self.home_parish
    Visitor.visitor.home_parish
  end

  # Creates a Visitor
  #
  # === Parameters:
  #
  # * <tt>:home_parish</tt> like St. Mary Magdalene
  # * <tt>:home</tt>
  # * <tt>:about</tt>
  # * <tt>:contact</tt> Admin
  #
  # === Returns:
  #
  # * <tt>Visitor</tt>
  #
  def self.visitor(home_parish = nil, home = nil, about = nil, contact = nil)
    if Visitor.count.zero?
      v = Visitor.create!(home_parish: home_parish.nil? ? 'St. Mary Magdalene' : home_parish,
                          home: home.nil? ? 'replace me - home' : home,
                          about: about.nil? ? 'replace me - about' : about,
                          contact: contact.nil? ? 'replace me - contact' : contact)
    else
      v = Visitor.all.first
      v.home_parish = home_parish unless home_parish.nil?
      v.home = home unless home.nil?
      v.about = about unless about.nil?
      v.contact = contact unless contact.nil?
    end
    v.save
    v
  end

  private

  def build_associations
    home_parish_address || build_home_parish_address
  end

  def confirm_singularity
    raise StandardError, 'There can be only one.' if Visitor.count.positive?
  end
end
