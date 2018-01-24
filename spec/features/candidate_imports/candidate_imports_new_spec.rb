include ViewsHelpers
include Warden::Test::Helpers
Warden.test_mode!

# Feature: Candidate delete
#   As a admin
#   I want to delete my admin profile
#   So I can close my account
feature 'Other', :devise do

  after(:each) do
    Warden.test_reset!
  end

  describe 'Import Candidates' do

    scenario 'admin can import candidates via excel spreadsheet' do
      admin = FactoryBot.create(:admin)
      login_as(admin, :scope => :admin)
      visit new_candidate_import_path
      attach_file :candidate_import_file, 'spec/fixtures/Small.xlsx'
      click_button I18n.t('views.imports.import')
      expect_message(:flash_notice, I18n.t('messages.import_successful'))
    end

    scenario 'candidate cannot import candidates' do
      candidate = FactoryBot.create(:candidate)
      login_as(candidate, :scope => :candidate)
      visit new_candidate_import_path
      expect_message(:flash_alert, I18n.t('devise.failure.unauthenticated'))
    end

    scenario 'admin can import candidates via excel spreadsheet' do
      admin = FactoryBot.create(:admin)
      login_as(admin, :scope => :admin)
      visit new_candidate_import_path
      attach_file :candidate_import_file, 'spec/fixtures/Invalid.xlsx'
      click_button 'Import'

      expect_message(:error_explanation, '4 errors prohibited this import from completing: Row 2: Last name can\'t be blank Row 3: First name can\'t be blank Row 5: Parent email 1 is an invalid email: @nc.rr.com Row 5: Parent email 2 is an invalid email: rannunz')
    end

  end

  describe 'Start new year' do

    scenario 'admin will start a new year, which will cleanup the DB' do
      FactoryBot.create(:candidate)
      FactoryBot.create(:candidate, account_name: 'a1')
      expect(Candidate.all.size).to eq(2) #prove there are only 2
      admin = FactoryBot.create(:admin)
      login_as(admin, :scope => :admin)
      visit new_candidate_import_path
      click_button I18n.t('views.imports.start_new_year')
      expect_message(:flash_notice, I18n.t('messages.candidates_removed'))
      expect(Candidate.find_by_account_name('vickikristoff')).not_to be(nil), 'Could not find candidate seed: vickikristoff'
      expect(Candidate.all.size).to eq(1), "Should only have the candidate seed: #{Candidate.all.size}"
      expect(ConfirmationEvent.all.size).not_to eq(0)
      ConfirmationEvent.all.each do |ce|
        expect(ce.chs_due_date).to eq(Date.today)
        expect(ce.the_way_due_date).to eq(Date.today)
      end
    end

  end

  describe 'Reset the Database' do

    scenario 'admin can reset the database' do
      FactoryBot.create(:candidate)
      FactoryBot.create(:candidate, account_name: 'a1')
      expect(Candidate.all.size).to eq(2) #prove there are only 2
      FactoryBot.create(:admin)
      admin = FactoryBot.create(:admin, name: 'foo', email: 'paul@kristoffs.com')
      login_as(admin, :scope => :admin)
      expect(Admin.all.size).to eq(2) #prove there are only 2
      visit new_candidate_import_path
      click_button I18n.t('views.imports.reset_database')
      expect_message(:flash_notice, I18n.t('messages.database_reset'))
      expect(Candidate.all.size).to eq(1)
      expect(Admin.all.size).to eq(1)
    end

  end

  describe 'Export to excel' do

    xlsx_filename = 'exported_candidates.xlsx'
    xlsx_filename_zip = 'exported_candidates.zip'

    scenario 'admin can export to excel and read it back in.' do
      FactoryBot.create(:candidate)
      FactoryBot.create(:candidate, account_name: 'a1')
      expect(Candidate.all.size).to eq(2) #prove there are only 2
      FactoryBot.create(:admin)
      admin = FactoryBot.create(:admin, name: 'foo', email: 'paul@kristoffs.com')
      login_as(admin, :scope => :admin)
      expect(Admin.all.size).to eq(2) #prove there are only 2
      visit new_candidate_import_path
      click_button I18n.t('views.imports.excel')

      File.open(xlsx_filename_zip, 'w') { |f| f.write(page.html) }
      begin

        visit new_candidate_import_path
        click_button I18n.t('views.imports.start_new_year')
        expect(Candidate.find_by_account_name('vickikristoff')).not_to be(nil), 'Could not find candidate seed: vickikristoff'
        expect(Candidate.all.size).to eq(1), "Should only have the candidate seed: #{Candidate.all.size}"
        expect(ConfirmationEvent.all.size).not_to eq(0)
        ConfirmationEvent.all.each do |ce|
          expect(ce.chs_due_date).to eq(Date.today)
          expect(ce.the_way_due_date).to eq(Date.today)
        end

        visit new_candidate_import_path
        attach_file :candidate_import_file, xlsx_filename_zip
        click_button I18n.t('views.imports.import')
        expect(Candidate.all.size).to eq(3) # + candidate seed
      ensure
        File.delete xlsx_filename if File.exist? xlsx_filename
        File.delete xlsx_filename_zip if File.exist? xlsx_filename_zip
      end

    end

  end
  describe 'Check Events' do

    # Scenario: Admin sees confirmation events that are missing, unknown, & found
    #   Given Admin is signed in
    #   When I visit the Other page
    #   and click the click 'Check Event' button
    #   Then I see confirmation events that are missing, unknown, & found
    scenario 'admin can see if confirmation event is missing' do
      setup_unknown_missing_events

      admin = FactoryBot.create(:admin)
      login_as(admin, scope: :admin)
      visit new_candidate_import_path

      expect(page.html).to have_selector('section[id=check_events] form[id=new_candidate_import][action="/candidate_imports/check_events"]')
      expect(page.html).to have_button(I18n.t('views.imports.check_events'))

      expect(page.html).to have_selector('ul[id=missing_confirmation_events]')
      expect(page.html).to have_selector('ul[id=found_confirmation_events]')
      expect(page.html).to have_selector('ul[id=unknown_confirmation_events]')
      expect(page.html).to have_selector('section[id=check_events] ul', count: 3)
      expect(page.html).to have_selector('section[id=check_events] li', count: 0)

      click_button I18n.t('views.imports.check_events')
      expect(page.html).to have_selector('section[id=check_events] form[id=new_candidate_import][action="/candidate_imports/check_events"]')
      expect(page.html).to have_button(I18n.t('views.imports.check_events'))

      expect(page.html).to have_selector('section[id=check_events] ul[id=missing_confirmation_events] li', text: I18n.t('events.sponsor_covenant'))
      expect(page.html).to have_selector('section[id=check_events] ul[id=found_confirmation_events] li', count: 8)
      expect(page.html).to have_selector('section[id=check_events] ul[id=unknown_confirmation_events] li', text: 'unknown event')
    end

    # Scenario: Admin wants to add missing events back into the DB but has not pushed 'Check Events'
    #   Given Admin is signed in
    #   When I visit the Other page
    #   and click the click 'Add Missing Events' button
    #   Then I see message saying to 'Check Events' first
    scenario 'admin gets message saying no missing events' do
      setup_unknown_missing_events

      admin = FactoryBot.create(:admin)
      login_as(admin, scope: :admin)
      visit new_candidate_import_path

      click_button I18n.t('views.imports.add_missing_events')
      expect_message(:flash_alert, I18n.t('views.imports.check_events_first'))
    end

    # Scenario: Admin wants to add missing events back into the DB
    #   Given Admin is signed in
    #   When I visit the Other page
    #   and click the click 'Check Events' button
    #   and click the click 'Add Missing Events' button
    #   Then I see missing event is now in the found events.
    scenario 'admin gets message saying no missing events' do
      setup_unknown_missing_events

      admin = FactoryBot.create(:admin)
      login_as(admin, scope: :admin)
      visit new_candidate_import_path

      click_button I18n.t('views.imports.check_events')

      click_button I18n.t('views.imports.add_missing_events')

      expect(page.html).to have_selector('section[id=check_events] ul[id=missing_confirmation_events] li', count: 0)
      expect(page.html).to have_selector('section[id=check_events] ul[id=found_confirmation_events] li', count: 9)
      expect(page.html).to have_selector('section[id=check_events] ul[id=unknown_confirmation_events] li', text: 'unknown event')
    end

  end
end

