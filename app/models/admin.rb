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

  # Update table_filter upon login (sign_in)
  #
  def after_database_authentication
    super
    update(table_filter: Admin.initial_sorting_settings)
  end

  # sorting and filter values
  #
  def sorting_settings
    Admin.initial_sorting_settings
  end

  # initial sorting and filter values
  #
  def self.initial_sorting_settings
    [
      { "column_name": 'Status',
        "data_column_offset": 1,
        "filter": 'Active',
        "Sort": 'asc' },
      { "column_name": 'Last name',
        "data_column_offset": 4,
        "filter": '',
        "sort": 'asc' },
      { "column_name": 'First name',
        "data_column_offset": 5,
        "filter": '',
        "sort": 'asc' },
      { "column_name": 'Grade',
        "data_column_offset": 6,
        "filter": '',
        "sort": 'asc' },
      { "column_name": 'Program Year',
        "data_column_offset": 7,
        "filter": '',
        "sort": 'asc' },
      { "column_name": 'Attending',
        "data_column_offset": 8,
        "filter": '',
        "sort": 'asc' },
      { "column_name": 'Covenant Agreement',
        "data_column_offset": 9,
        "filter": '',
        "sort": 'asc' },
      { "column_name": 'Information Sheet',
        "data_column_offset": 10,
        "filter": '',
        "sort": 'asc' },
      { "column_name": 'Baptismal Certificate',
        "data_column_offset": 11,
        "filter": '',
        "sort": 'asc' },
      { "column_name": 'Sponsor\'s Covenant',
        "data_column_offset": 12,
        "filter": '',
        "sort": 'asc' },
      { "column_name": 'Sponsor\'s Eligibility',
        "data_column_offset": 13,
        "filter": '',
        "sort": 'asc' },
      { "column_name": 'Confirmation Name',
        "data_column_offset": 14,
        "filter": '',
        "sort": 'asc' },
      { "column_name": 'Christian Ministry',
        "data_column_offset": 15,
        "filter": '',
        "sort": 'asc' },
      { "column_name": 'Attend Retreat',
        "data_column_offset": 16,
        "filter": '',
        "sort": 'asc' },
      { "column_name": 'Parent Information Meeting',
        "data_column_offset": 17,
        "filter": '',
        "sort": 'asc' },
      { "column_name": 'Account Confirma†ion',
        "data_column_offset": 18,
        "filter": '',
        "sort": 'asc' },
      { "column_name": 'Password Changed',
        "data_column_offset": 19,
        "filter": '',
        "sort": 'asc' }
    ].to_json
  end

  private

  def validate_email_address(email)
    return true if email.blank?

    email =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  end
end
