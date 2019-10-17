# frozen_string_literal: true

# holder of visitor page info.
#
class Visitor < ApplicationRecord
  before_create :confirm_singularity

  # Editable attributes
  #
  # === Returns:
  #
  # * <tt>Array</tt> of attributes
  #
  def self.basic_permitted_params
    %i[home about contact home_parish]
  end

  def self.home_parish
    Visitor.visitor.home_parish
  end

  def self.visitor(home_parish = nil, home = nil, about = nil, contact = nil)
    if Visitor.count.zero?
      v = Visitor.create!(home_parish: home_parish.nil? ? 'St. Mary Magdalene' : home_parish,
                          home: home.nil? ? 'replace me - home' : home,
                          about: about.nil? ? 'replace me - about' : about,
                          contact: contact.nil? ? 'replace me - contaclt' : contact)
    else
      v = Visitor.all.first
      v.home_parish = home_parish unless home_parish.nil?
      v.home = home unless home.nil?
      v.about = about unless about.nil?
      v.contact = contact unless contact.nil?
      v.save
    end
    v
  end

  private

  def confirm_singularity
    raise StandardError, 'There can be only one.' if Visitor.count.positive?
  end
end
