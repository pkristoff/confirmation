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
      admin = FactoryGirl.create(:admin)
      login_as(admin, :scope => :admin)
      visit new_candidate_import_path
      attach_file :candidate_import_file, 'spec/fixtures/Small.xlsx'
      click_button I18n.t('views.imports.import')
      expect(page).to have_selector('div[id=flash_notice]', text: 'Imported candidates successfully.')
    end

    scenario 'candidate cannot import candidates' do
      candidate = FactoryGirl.create(:candidate)
      login_as(candidate, :scope => :candidate)
      visit new_candidate_import_path
      expect(page).to have_selector('div[id=flash_alert]', text: 'You need to sign in or sign up before continuing.')
    end

    scenario 'admin can import candidates via excel spreadsheet' do
      admin = FactoryGirl.create(:admin)
      login_as(admin, :scope => :admin)
      visit new_candidate_import_path
      attach_file :candidate_import_file, 'spec/fixtures/Invalid.xlsx'
      click_button 'Import'
      expect(page).to have_selector('div[id=error_explanation]')
    end

  end

  describe 'Remove All Candiadates from database' do

    scenario 'admin can remove all candidates from database' do
      FactoryGirl.create(:candidate)
      FactoryGirl.create(:candidate, account_name: 'a1')
      expect(Candidate.all.size).to eq(2) #prove there are only 2
      admin = FactoryGirl.create(:admin)
      login_as(admin, :scope => :admin)
      visit new_candidate_import_path
      click_button I18n.t('views.imports.remove_all_candidates')
      expect(page).to have_selector('div[id=flash_notice]', text: 'All candidates successfully removed.')
      expect(Candidate.all.size).to eq(0)
    end

  end

  describe 'Reset the Database' do

    scenario 'admin can reset the database' do
      FactoryGirl.create(:candidate)
      FactoryGirl.create(:candidate, account_name: 'a1')
      expect(Candidate.all.size).to eq(2) #prove there are only 2
      FactoryGirl.create(:admin)
      admin = FactoryGirl.create(:admin, name: 'foo', email: 'paul@kristoffs.com')
      login_as(admin, :scope => :admin)
      expect(Admin.all.size).to eq(2) #prove there are only 2
      visit new_candidate_import_path
      click_button I18n.t('views.imports.reset_database')
      expect(page).to have_selector('div[id=flash_notice]', text: 'Database successfully reset.')
      expect(Candidate.all.size).to eq(1)
      expect(Admin.all.size).to eq(1)
    end

  end

  describe 'Export to excel' do

    xlsx_filename = 'exported_candidates.xlsx'

    scenario 'admin can export to excel and read it back in.' do
      FactoryGirl.create(:candidate)
      FactoryGirl.create(:candidate, account_name: 'a1')
      expect(Candidate.all.size).to eq(2) #prove there are only 2
      FactoryGirl.create(:admin)
      admin = FactoryGirl.create(:admin, name: 'foo', email: 'paul@kristoffs.com')
      login_as(admin, :scope => :admin)
      expect(Admin.all.size).to eq(2) #prove there are only 2
      visit new_candidate_import_path
      click_button I18n.t('views.imports.excel')

      File.open(xlsx_filename, 'w') { |f| f.write(page.html) }
      begin

        visit new_candidate_import_path
        click_button I18n.t('views.imports.remove_all_candidates')
        expect(Candidate.all.size).to eq(0)

        visit new_candidate_import_path
        attach_file :candidate_import_file, xlsx_filename
        click_button I18n.t('views.imports.import')
        expect(Candidate.all.size).to eq(2)
      ensure
        if File.exist? xlsx_filename
          File.delete xlsx_filename
        end
      end

    end

  end
end

