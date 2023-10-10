# frozen_string_literal: true

Warden.test_mode!

# Feature: Candidate delete
#   As a admin
#   I want to delete my admin profile
#   So I can close my account
describe 'Other', :devise do
  include ViewsHelpers
  include Warden::Test::Helpers

  before do
    @admin = FactoryBot.create(:admin)
    FactoryBot.create(:visitor)
    @today = Time.zone.today
    FactoryBot.create(:status)
    FactoryBot.create(:status, name: 'Deferred')
  end

  after do
    Warden.test_reset!
  end

  describe 'Import Candidates' do
    it 'admin can import candidates via excel spreadsheet - 2' do
      login_as(@admin, scope: :admin)
      visit new_candidate_import_path
      attach_file :candidate_import_file, 'spec/fixtures/imports/Test upload.xlsx'
      click_button I18n.t('views.imports.import')
      expect_message(:flash_notice, I18n.t('messages.import_successful'))
    end

    it 'candidate cannot import candidates' do
      candidate = FactoryBot.create(:candidate)
      login_as(candidate, scope: :candidate)
      visit new_candidate_import_path
      expect_message(:flash_alert, I18n.t('devise.failure.unauthenticated'))
    end

    it 'admin cannot import a candidate with an missing attending' do
      login_as(@admin, scope: :admin)
      visit new_candidate_import_path
      attach_file :candidate_import_file, 'spec/fixtures/imports/Test upload missing attending.xlsx'
      click_button 'Import'
      expect_message(:flash_alert, 'donethpeyton Attending cell cannot be empty')
    end

    it 'admin cannot import a candidate with an illegal attending' do
      login_as(@admin, scope: :admin)
      visit new_candidate_import_path
      attach_file :candidate_import_file, 'spec/fixtures/imports/Test upload illegal attending.xlsx'
      click_button 'Import'
      expect_message(:flash_alert, 'donethpeyton Illegal Attending value: The foo')
    end

    it 'admin cannot import a candidate with an missing grade' do
      login_as(@admin, scope: :admin)
      visit new_candidate_import_path
      attach_file :candidate_import_file, 'spec/fixtures/imports/Test upload missing grade.xlsx'
      click_button 'Import'
      expect_message(:flash_alert, 'donethpeyton: Grade should be between 9 & 12')
    end

    it 'admin cannot import a candidate with an illegal grade' do
      login_as(@admin, scope: :admin)
      visit new_candidate_import_path
      attach_file :candidate_import_file, 'spec/fixtures/imports/Test upload illegal grade.xlsx'
      click_button 'Import'
      expect_message(:flash_alert, 'donethpeyton Illegal grade=5. It should be between 9 & 12')
    end

    it 'admin cannot import a candidate with an illegal program year' do
      login_as(@admin, scope: :admin)
      visit new_candidate_import_path
      attach_file :candidate_import_file, 'spec/fixtures/imports/Test upload illegal program year.xlsx'
      click_button 'Import'
      expect_message(:flash_alert, 'donethpeyton program year should be 1 or 2 : 3')
    end

    it 'admin cannot import a candidate with an missing program year' do
      login_as(@admin, scope: :admin)
      visit new_candidate_import_path
      attach_file :candidate_import_file, 'spec/fixtures/imports/Test upload missing program year.xlsx'
      click_button 'Import'
      expect_message(:flash_alert, 'donethpeyton program year cannot blank')
    end

    it 'admin cannot import a candidate missing a status' do
      login_as(@admin, scope: :admin)
      visit new_candidate_import_path
      attach_file :candidate_import_file, 'spec/fixtures/imports/Test upload illegal status.xlsx'
      click_button 'Import'
      expect_message(:flash_alert, 'donethpeyton Illegal status: Foo')
    end
  end

  it 'admin cannot import a candidate with an illegal status' do
    login_as(@admin, scope: :admin)
    visit new_candidate_import_path
    attach_file :candidate_import_file, 'spec/fixtures/imports/Test upload missing status.xlsx'
    click_button 'Import'
    expect_message(:flash_alert, 'donethpeyton Status cannot be blank.')
  end
end
