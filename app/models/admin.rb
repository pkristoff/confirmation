# frozen_string_literal: true

#
# Admin for the candidates
#
class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :timeoutable,
         :recoverable, :trackable, :validatable,
         authentication_keys: [:account_name],
         reset_password_keys: [:account_name]

  validates :account_name,
            presence: true,
            uniqueness: {
              case_sensitive: false
            }

  validates :contact_name,
            presence: true

  validates :contact_phone,
            presence: true

  # Valadate the email address
  #
  def validate_email
    errors.add(:email, I18n.t('messages.error.invalid_email', email: email)) unless validate_email_address(email)
  end

  # Editable attributes
  #
  # === Returns:
  #
  # * <tt>Array</tt> of attributes
  #
  def self.permitted_params
    %i[email contact_name contact_phone account_name name password password_confirmation]
  end

  # next_available_account_name
  #   account_name Admin, Admin_1 ...
  #
  # === Returns:
  #
  # * <tt>Array</tt> [account_name, name]
  #
  def self.next_available_account_name
    ["Admin #{Admin.count}", "Admin_#{Admin.count}"]
  end

  private

  def validate_email_address(email)
    return true if email.blank?

    email =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  end
end
