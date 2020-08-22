# frozen_string_literal: true

Warden.test_mode!

# Feature: Candidate delete
#   As a admin
#   I want to delete my admin profile
#   So I can close my account
feature 'Other', :devise do
  include ViewsHelpers
  include Warden::Test::Helpers

  before(:each) do
    @today = Time.zone.today
  end

  after(:each) do
    Warden.test_reset!
  end

  describe 'Import Candidates' do
    scenario 'admin can import candidates via excel spreadsheet' do
      admin = FactoryBot.create(:admin)
      login_as(admin, scope: :admin)
      visit new_candidate_import_path
      attach_file :candidate_import_file, 'spec/fixtures/Small.xlsx'
      click_button I18n.t('views.imports.import')
      expect_message(:flash_notice, I18n.t('messages.import_successful'))
    end

    scenario 'candidate cannot import candidates' do
      candidate = FactoryBot.create(:candidate)
      login_as(candidate, scope: :candidate)
      visit new_candidate_import_path
      expect_message(:flash_alert, I18n.t('devise.failure.unauthenticated'))
    end

    scenario 'admin can import candidates via excel spreadsheet' do
      admin = FactoryBot.create(:admin)
      login_as(admin, scope: :admin)
      visit new_candidate_import_path
      attach_file :candidate_import_file, 'spec/fixtures/Invalid.xlsx'
      click_button 'Import'

      expect_message(:error_explanation, ['5 errors prohibited this import from completing:',
                                          'Row 2: Last name can\'t be blank',
                                          'Row 3: First name can\'t be blank',
                                          'Row 5: Parent email 1 is an invalid email: @nc.rr.com',
                                          'Row 5: Parent email 2 is an invalid email: rannunz'])
    end
  end
end
