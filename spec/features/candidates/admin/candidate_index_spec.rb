include ViewsHelpers
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

    expect(page).to have_css "form[action='/mass_edit_candidates_update']"

    expect(page).to have_css("input[type='submit'][value='delete']", count: 2)
    expect(page).to have_css("input[type='submit'][value='email']", count: 2)


    expect(page).to have_css("input[id='top-update-delete'][type='submit'][value='delete']")
    expect(page).to have_css("input[id='top-update-email'][type='submit'][value='email']")

    expect_sorting_candidate_list([
                                      [I18n.t('label.candidate_event.select'), '', lambda { |candidate, rendered, td_index| expect(rendered).to have_css "input[type=checkbox][id=candidate_candidate_ids_#{candidate.id}]" }],
                                      [I18n.t('views.nav.edit'), '', lambda { |candidate, rendered, td_index| expect(rendered).to have_css "td[id='tr#{candidate.id}_td#{td_index}']" }],
                                      [I18n.t('label.candidate.account_name'), [:account_name], :up],
                                      [I18n.t('label.candidate_sheet.last_name'), [:candidate_sheet, :last_name]],
                                      [I18n.t('label.candidate_sheet.first_name'), [:candidate_sheet, :first_name]],
                                      [I18n.t('label.candidate_sheet.grade'), [:candidate_sheet, :grade]],
                                      [I18n.t('label.candidate_sheet.attending'), [:candidate_sheet, :attending]]
                                  ],
                                  [c1, c2, c3],
                                  :candidates,
                                  page)
    expect(page).to have_css("input[id='bottom-update-delete'][type='submit'][value='delete']")
    expect(page).to have_css("input[id='bottom-update-email'][type='submit'][value='email']")

  end
end