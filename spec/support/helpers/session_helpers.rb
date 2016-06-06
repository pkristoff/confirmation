module Features
  module SessionHelpers
    def sign_up_candidate_with(account_name, first_name, last_name, email, password, confirmation)
      visit new_candidate_path
      fill_in I18n.t('views.candidates.account_name'), with: account_name
      fill_in I18n.t('views.candidates.first_name'), with: first_name
      fill_in I18n.t('views.candidates.last_name'), with: last_name
      fill_in I18n.t('views.candidates.parent_email_1'), with: email
      fill_in I18n.t('views.common.password'), with: password
      fill_in I18n.t('views.common.password_confirmation'), :with => confirmation
      click_button I18n.t('views.common.sign_up')
    end

    def signin_candidate(account_name, password)
      visit new_candidate_session_path
      fill_in I18n.t('views.candidates.account_name'), with: account_name
      fill_in I18n.t('views.common.password'), with: password
      click_button I18n.t('views.common.sign_in', name: '')
    end

    def sign_up_admin_with(email, password, confirmation)
      visit new_admin_registration_path
      fill_in I18n.t('views.common.email'), with: email
      fill_in I18n.t('views.common.password'), with: password
      fill_in 'Password confirmation', :with => confirmation
      click_button I18n.t('views.common.sign_up')
    end

    def signin_admin(email, password)
      visit new_admin_session_path
      fill_in I18n.t('views.common.email'), with: email
      fill_in I18n.t('views.common.password'), with: password
      click_button I18n.t('views.common.sign_in', name: '')
    end
  end
end
