module Features
  module SessionHelpers
    def sign_up_candidate_with(email, password, confirmation)
      visit new_candidate_registration_path
      fill_in 'Email', with: email
      fill_in 'Password', with: password
      fill_in 'Password confirmation', :with => confirmation
      click_button 'Sign up'
    end

    def signin_candidate(email, password)
      visit new_candidate_session_path
      fill_in 'Email', with: email
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
