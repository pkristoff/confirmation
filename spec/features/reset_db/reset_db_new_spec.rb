# frozen_string_literal: true

Warden.test_mode!

# Feature: Candidate delete
#   As a admin
#   I want to delete my admin profile
#   So I can close my account
describe 'ResetDB', :devise do
  include ViewsHelpers
  include Warden::Test::Helpers

  before do
    FactoryBot.create(:visitor)
    @today = Time.zone.today
  end

  after do
    Warden.test_reset!
  end

  describe 'Start new year' do
    it 'admin will start a new year, which will cleanup the DB' do
      FactoryBot.create(:candidate)
      FactoryBot.create(:candidate, account_name: 'a1')
      expect(Candidate.all.size).to eq(2) # prove there are only 2
      admin = FactoryBot.create(:admin)
      login_as(admin, scope: :admin)

      visit reset_db_show_start_new_year_url

      click_button I18n.t('views.reset_db.start_new_year.title')
      expect_message(:flash_notice, I18n.t('messages.candidates_removed'))
      expected_msg = 'Could not find candidate seed: vickikristoff'
      expect(Candidate.find_by(account_name: 'vickikristoff')).not_to be_nil, expected_msg
      expect(Candidate.all.size).to eq(1), "Should only have the candidate seed: #{Candidate.all.size}"
      expect(ConfirmationEvent.all.size).not_to eq(0)
      ConfirmationEvent.all.each do |ce|
        expect(ce.chs_due_date).to eq(@today)
        expect(ce.the_way_due_date).to eq(@today)
      end
    end
  end

  describe 'Reset the Database' do
    it 'admin can reset the database' do
      FactoryBot.create(:candidate)
      FactoryBot.create(:candidate, account_name: 'a1')
      expect(Candidate.all.size).to eq(2) # prove there are only 2
      admin = FactoryBot.create(:admin, account_name: 'Admin1', name: 'foo', email: 'paul@kristoffs.com')
      login_as(admin, scope: :admin)
      expect(Admin.all.size).to eq(1) # prove there are only 2
      visit reset_db_show_reset_database_url
      click_button I18n.t('views.reset_db.reset_database.title')
      expect_message(:flash_notice, I18n.t('messages.database_reset'))
      expect(Candidate.all.size).to eq(1)
      expect(Admin.all.size).to eq(1)
    end
  end
end
