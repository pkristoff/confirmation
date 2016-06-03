module Features
  module SessionHelpers
    def sign_up_candidate_with(account_name, first_name, last_name, email, password, confirmation)
      visit new_candidate_path
      fill_in 'Account name', with: account_name
      fill_in 'First name', with: first_name
      fill_in 'Last name', with: last_name
      fill_in 'Parent email 1', with: email
      fill_in 'Password', with: password
      fill_in 'Password confirmation', :with => confirmation
      click_button 'Sign up'
    end

    def signin_candidate(account_name, password)
      visit new_candidate_session_path
      fill_in 'Account name', with: account_name
      fill_in 'Password', with: password
      click_button 'Sign in'
    end

    def sign_up_admin_with(email, password, confirmation)
      visit new_admin_registration_path
      fill_in 'Email', with: email
      fill_in 'Password', with: password
      fill_in 'Password confirmation', :with => confirmation
      click_button 'Sign up'
    end

    def signin_admin(email, password)
      visit new_admin_session_path
      fill_in 'Email', with: email
      fill_in 'Password', with: password
      click_button 'Sign in'
    end
  end
end
