include Warden::Test::Helpers
Warden.test_mode!

# Feature: Candidate index page
#   As a candidate
#   I want to see a list of candidates
#   So I can see who has registered
feature 'Candidate index page', :devise do

  after(:each) do
    Warden.test_reset!
  end

  scenario 'admin can get list of candidates' do
    c1 = FactoryGirl.create(:candidate, account_name: 'c1')
    c3 = FactoryGirl.create(:candidate, account_name: 'c3')
    c2 = FactoryGirl.create(:candidate, account_name: 'c2')
    admin = FactoryGirl.create(:admin)
    login_as(admin, scope: :admin)
    visit candidates_path
    expect(page).to have_css 'table'
    within 'table' do
      expect(page).to have_css 'tr', count: 4
      expect(page).to have_css 'tr[id="header"]'
      headers = [I18n.t('views.common.delete'), I18n.t('views.nav.edit'), I18n.t('views.candidates.account_name'), I18n.t('label.candidate_sheet.last_name') ,
                 I18n.t('label.candidate_sheet.first_name'), I18n.t('label.candidate_sheet.grade'), I18n.t('label.candidate_sheet.attending')]
      within 'tr[id="header"]' do

        expect(page).to have_css 'th', count: headers.size
        headers.each do |header|
          expect(page).to have_css 'th', text: header
        end
      end
      expect_data_row(0, 'c1', headers.size)
      expect_data_row(1, 'c2', headers.size)
      expect_data_row(2, 'c3', headers.size)
    end
  end

  def expect_data_row(row_num, account_name, num_of_td)
    expect(page).to have_css "tr[id='tr#{row_num}']"
    within "tr[id='tr#{row_num}']" do
      expect(page).to have_css 'td', count: num_of_td
      expect(page).to have_css 'td a', text: I18n.t('views.common.delete')
      expect(page).to have_css 'td a', text: I18n.t('views.nav.edit')
      expect(page).to have_css 'td', text: account_name
      expect(page).to have_css 'td', text: 'Agusta'
      expect(page).to have_css 'td', text: 'Sophia'
      expect(page).to have_css 'td', text: 10
      expect(page).to have_css 'td', text: 'The Way'
    end
  end

end
