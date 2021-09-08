# frozen_string_literal: true

# SessionHelpers
#
module Features
  # SessionHelpers
  #
  module SessionHelpers
    # Sign up candidate
    #
    # === Parameters:
    #
    # * <tt>:account_name</tt>
    # * <tt>:first_name</tt>
    # * <tt>:middle_name</tt>
    # * <tt>:last_name</tt>
    # * <tt>:email</tt>
    # * <tt>:password</tt>
    # * <tt>:confirmation</tt>
    #
    def sign_up_candidate_with(account_name, first_name, middle_name, last_name, email, password, confirmation)
      visit new_candidate_path
      fill_in I18n.t('views.candidates.account_name'), with: account_name
      fill_in I18n.t('views.candidates.first_name'), with: first_name
      fill_in I18n.t('views.candidates.middle_name'), with: middle_name
      fill_in I18n.t('views.candidates.last_name'), with: last_name
      fill_in I18n.t('views.candidates.parent_email_1'), with: email
      fill_in I18n.t('views.common.password'), with: password
      fill_in I18n.t('views.common.password_confirmation'), with: confirmation
      click_button I18n.t('views.top_bar.sign_up')
    end

    # Login candidate
    #
    # === Parameters:
    #
    # * <tt>:account_name</tt>
    # * <tt>:password</tt>
    #
    def signin_candidate(account_name, password)
      visit new_candidate_session_path
      fill_in I18n.t('views.candidates.account_name'), with: account_name
      fill_in I18n.t('views.common.password'), with: password
      click_button I18n.t('views.top_bar.sign_in', name: '')
    end

    # sign up admin
    #
    # === Parameters:
    #
    # * <tt>:email</tt>
    # * <tt>:password</tt>
    # * <tt>:confirmation</tt>
    #
    def sign_up_admin_with(email, password, confirmation)
      visit new_admin_registration_path
      fill_in I18n.t('views.admins.email'), with: email
      fill_in I18n.t('views.common.password'), with: password
      fill_in 'Password confirmation', with: confirmation
      click_button I18n.t('views.top_bar.sign_up')
    end

    # Login account_name
    #
    # === Parameters:
    #
    # * <tt>:account_name</tt>
    # * <tt>:password</tt>
    #
    def signin_admin(account_name, password)
      visit new_admin_session_path
      fill_in I18n.t('views.admins.account_name'), with: account_name
      fill_in I18n.t('views.common.password'), with: password
      click_button I18n.t('views.top_bar.sign_in', name: '')
    end
  end
end
