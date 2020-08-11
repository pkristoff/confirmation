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

  describe 'Start new year' do
    scenario 'admin will start a new year, which will cleanup the DB' do
      FactoryBot.create(:candidate)
      FactoryBot.create(:candidate, account_name: 'a1')
      expect(Candidate.all.size).to eq(2) # prove there are only 2
      admin = FactoryBot.create(:admin)
      login_as(admin, scope: :admin)
      visit new_candidate_import_path
      click_button I18n.t('views.imports.start_new_year.title')
      expect_message(:flash_notice, I18n.t('messages.candidates_removed'))
      expected_msg = 'Could not find candidate seed: vickikristoff'
      expect(Candidate.find_by(account_name: 'vickikristoff')).not_to be(nil), expected_msg
      expect(Candidate.all.size).to eq(1), "Should only have the candidate seed: #{Candidate.all.size}"
      expect(ConfirmationEvent.all.size).not_to eq(0)
      ConfirmationEvent.all.each do |ce|
        expect(ce.chs_due_date).to eq(@today)
        expect(ce.the_way_due_date).to eq(@today)
      end
    end
  end

  describe 'Reset the Database' do
    scenario 'admin can reset the database' do
      FactoryBot.create(:candidate)
      FactoryBot.create(:candidate, account_name: 'a1')
      expect(Candidate.all.size).to eq(2) # prove there are only 2
      admin = FactoryBot.create(:admin, account_name: 'Admin1', name: 'foo', email: 'paul@kristoffs.com')
      login_as(admin, scope: :admin)
      expect(Admin.all.size).to eq(1) # prove there are only 2
      visit new_candidate_import_path
      click_button I18n.t('views.imports.reset_database.title')
      expect_message(:flash_notice, I18n.t('messages.database_reset'))
      expect(Candidate.all.size).to eq(1)
      expect(Admin.all.size).to eq(1)
    end
  end
end
