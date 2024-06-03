# frozen_string_literal: true

# @!Status
#
class Status < ApplicationRecord
  has_many(:candidates, dependent: :destroy)
  validates :name, presence: true, uniqueness: true
  validates :description, presence: true

  ACTIVE = 'Active'
  DEFERRED = 'Deferred'
  CONFIRMED_ELSEWHERE = 'Getting Confirmed elsewhere'
  FROM_ANOTHER_PARISH = 'From another parish'

  # Looks up 'Active status'
  #
  def self.active
    Status.find_by(name: ACTIVE)
  end

  # Looks up 'Active status'
  #
  def self.confirmed_elsewhere
    Status.find_by(name: CONFIRMED_ELSEWHERE)
  end

  # Looks up 'Deferred status'
  #
  def self.deferred
    Status.find_by(name: DEFERRED)
  end

  # Looks up 'From another parish status'
  #
  def self.from_another_parish
    Status.find_by(name: FROM_ANOTHER_PARISH)
  end

  # returns true if status_id is the id of the active status
  #
  # === Parameters:
  #
  # * <tt>:status_id</tt> BigInt
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def self.active?(status_id)
    Status.find_by(id: status_id).name == ACTIVE
  end

  # returns true if status_id is the id of the confirmed elsewhere status
  #
  # === Parameters:
  #
  # * <tt>:status_id</tt> BigInt
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def self.confirmed_elsewhere?(status_id)
    Status.find_by(id: status_id).name == CONFIRMED_ELSEWHERE
  end

  # returns true if status_id is the id of the deferred status
  #
  # === Parameters:
  #
  # * <tt>:status_id</tt> BigInt
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def self.deferred?(status_id)
    Status.find_by(id: status_id).name == DEFERRED
  end

  # returns true if status_id is the id of the From another parish status
  #
  # === Parameters:
  #
  # * <tt>:status_id</tt> BigInt
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def self.from_another_parish?(status_id)
    Status.find_by(id: status_id).name == FROM_ANOTHER_PARISH
  end

  # Used when deciding whether a Status can be deleted.
  #
  def used_by_candidate?
    Candidate.where(status_id: id).count.positive?
  end
end
