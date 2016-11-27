include ViewsHelpers
describe 'admins/monthly_mass_mailing.html.erb' do

  before(:each) do
    AppFactory.add_confirmation_events

    @candidate_1 = create_candidate('Vicki', 'Kristoff')
    @candidate_2 = create_candidate('Paul', 'Kristoff')
    @candidates = [@candidate_1, @candidate_2]

  end


  it 'display the list of candidates' do

    render

    expect(rendered).to have_css "form[action='/monthly_mass_mailing_update']"

    expect(rendered).to have_css("input[type='submit'][value='#{t('views.common.update')}']", count: 2)

    expect(rendered).to have_css("input[id='top-update'][type='submit'][value='#{t('views.common.update')}']")

    expect(rendered).to have_field(t('email.pre_late_label'), text: t('email.late_initial_text'))
    expect(rendered).to have_field(t('email.coming_due_label'), text: t('email.coming_due_initial_text'))
    expect(rendered).to have_field(t('email.completed_label'), text: t('email.completed_initial_text'))

    expect_sorting_candidate_list([
                                      [t('label.candidate_event.select'), '', lambda { |candidate, rendered, td_index| expect(rendered).to have_css "input[type=checkbox][id=candidate_candidate_ids_#{candidate.id}]" }],
                                      [t('label.candidate.account_name'), [:account_name], :up],
                                      [t('label.candidate_sheet.last_name'), [:candidate_sheet, :last_name]],
                                      [t('label.candidate_sheet.first_name'), [:candidate_sheet, :first_name]],
                                      [t('label.candidate_sheet.grade'), [:candidate_sheet, :grade]],
                                      [t('label.candidate_sheet.attending'), [:candidate_sheet, :attending]]
                                  ],
                                  @candidates,
                                  :monthly_mass_mailing,
                                  rendered)

    expect(rendered).to have_css("input[id='bottom-update'][type='submit'][value='#{t('views.common.update')}']")

  end

end