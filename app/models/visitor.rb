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
    vs = Visitor.all
    #  this is mostly here for testing
    Visitor.create! if vs.empty?
    Visitor.all.first.home_parish
  end

  private

  def confirm_singularity
    raise StandardError, 'There can be only one.' if Visitor.count.positive?
  end
end
