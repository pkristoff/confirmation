# frozen_string_literal: true

# @!Status
#
class Status < ApplicationRecord
  has_many(:candidates, dependent: :destroy)
  validates :name, :description, presence: true

  # Looks up 'Active status'
  #
  def self.active
    Status.find_by(name: 'Active')
  end
end
