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
      expect_message(:flash_notice, I18n.t('messages.import_successful'))
    end

    scenario 'candidate cannot import candidates' do
      candidate = FactoryGirl.create(:candidate)
      login_as(candidate, :scope => :candidate)
      visit new_candidate_import_path
      expect_message(:flash_alert, I18n.t('devise.failure.unauthenticated'))
    end

    scenario 'admin can import candidates via excel spreadsheet' do
      admin = FactoryGirl.create(:admin)
      login_as(admin, :scope => :admin)
      visit new_candidate_import_path
      attach_file :candidate_import_file, 'spec/fixtures/Invalid.xlsx'
      click_button 'Import'
      expect_message(:error_explanation, '4 errors prohibited this import from completing: Row 2: Candidate sheet last name can\'t be blank Row 3: Candidate sheet first name can\'t be blank Row 6: Candidate sheet parent email 1 is an invalid email Row 6: Candidate sheet parent email 2 is an invalid email')
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
      expect_message(:flash_notice, I18n.t('messages.candidates_removed'))
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
      expect_message(:flash_notice, I18n.t('messages.database_reset'))
      expect(Candidate.all.size).to eq(1)
      expect(Admin.all.size).to eq(1)
    end

  end

  describe 'Export to excel' do

    xlsx_filename = 'exported_candidates.xlsx'
    xlsx_filename_zip = 'exported_candidates.zip'

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

      File.open(xlsx_filename_zip, 'w') { |f| f.write(page.html) }
      begin

        visit new_candidate_import_path
        click_button I18n.t('views.imports.remove_all_candidates')
        expect(Candidate.all.size).to eq(0)

        visit new_candidate_import_path
        attach_file :candidate_import_file, xlsx_filename_zip
        click_button I18n.t('views.imports.import')
        expect(Candidate.all.size).to eq(2)
      ensure
        File.delete xlsx_filename if File.exist? xlsx_filename
        File.delete xlsx_filename_zip if File.exist? xlsx_filename_zip
      end

    end

  end
end

