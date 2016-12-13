include ViewsHelpers
include Warden::Test::Helpers
Warden.test_mode!

# Feature: Candidate delete
#   As an admin
#   I want to delete candidates

feature 'Candidate delete', :devise do

  before(:each) do
    AppFactory.add_confirmation_events

    admin = FactoryGirl.create(:admin)
    login_as(admin, scope: :admin)

    @candidate_1 = create_candidate('Vicki', 'Kristoff')
    @candidate_2 = create_candidate('Paul', 'Kristoff')
    @candidate_3 = create_candidate('Karen', 'Kristoff')
    @candidates = [@candidate_1, @candidate_2, @candidate_3]

  end

  after(:each) do
    Warden.test_reset!
  end

  scenario 'admin cannot delete candidates if none are selected' do
    visit candidates_path
    click_button('top-update-delete')

    expect_message(:flash_alert, I18n.t('messages.no_candidate_selected'))
  end

  scenario 'admin can delete candidates if they are selected' do
    visit candidates_path

    check("candidate_candidate_ids_#{@candidate_1.id}")
    check("candidate_candidate_ids_#{@candidate_3.id}")
    click_button('top-update-delete')

    expect_message(:flash_notice, I18n.t('messages.candidates_deleted'))
    expect_sorting_candidate_list([
                                      [I18n.t('label.candidate_event.select'), false, '', lambda { |candidate, rendered, td_index| expect(rendered).to have_css "input[type=checkbox][id=candidate_candidate_ids_#{candidate.id}]" }],
                                      [I18n.t('views.nav.edit'), false, '', lambda { |candidate, rendered, td_index| expect(rendered).to have_css "td[id='tr#{candidate.id}_td#{td_index}']" }],
                                      [I18n.t('label.candidate.account_name'), true, [:account_name], :up],
                                      [I18n.t('label.candidate_sheet.last_name'), true, [:candidate_sheet, :last_name]],
                                      [I18n.t('label.candidate_sheet.first_name'), true, [:candidate_sheet, :first_name]],
                                      [I18n.t('label.candidate_sheet.grade'), true, [:candidate_sheet, :grade]],
                                      [I18n.t('label.candidate_sheet.attending'), true, [:candidate_sheet, :attending]]
                                  ],
                                  [@candidate_2],
                                  page)
  end

end




