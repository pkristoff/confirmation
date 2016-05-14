module Features
  module SessionHelpers
    def sign_up_candidate_with(candidate_id, email, password, confirmation)
      visit new_candidate_path
      puts page.html
      fill_in 'Candidate', with: candidate_id
      fill_in 'Parent email 1', with: email
      fill_in 'Password', with: password
      fill_in 'Password confirmation', :with => confirmation
      click_button 'Sign up'
    end

    def signin_candidate(candidate_id, password)
      visit new_candidate_session_path
      puts page.html
      fill_in 'Candidate', with: candidate_id
      fill_in 'Password', with: password
      click_button 'Sign in'
    end

    def sign_up_admin_with(email, password, confirmation)
      visit new_admin_registration_path
      puts page.html
      fill_in 'Email', with: email
      fill_in 'Password', with: password
      fill_in 'Password confirmation', :with => confirmation
      click_button 'Sign up'
    end

    def signin_admin(email, password)
      visit new_admin_session_path
      puts page.html
      fill_in 'Email', with: email
      fill_in 'Password', with: password
      click_button 'Sign in'
    end
  end
end
