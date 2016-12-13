include ViewsHelpers
describe 'candidates/index.html.erb' do

  before(:each) do
    AppFactory.add_confirmation_events

    @candidate_1 = create_candidate('Vicki', 'Kristoff')
    @candidate_2 = create_candidate('Paul', 'Kristoff')
    @candidates = [@candidate_1, @candidate_2]

  end


  it 'display the list of candidates' do

    render

    expect_sorting_candidate_list([
                                      [t('label.candidate_event.select'), '', lambda {|candidate, rendered, td_index| expect(rendered).to have_css "input[type=checkbox][id=candidate_candidate_ids_#{candidate.id}]" }],
                                      [t('views.nav.edit'), '', lambda { |candidate, rendered, td_index| expect(rendered).to have_css "td[id='tr#{candidate.id}_td#{td_index}']" }],
                                      [t('label.candidate.account_name'), [:account_name], :up],
                                      [t('label.candidate_sheet.last_name'), [:candidate_sheet, :last_name]],
                                      [t('label.candidate_sheet.first_name'), [:candidate_sheet, :first_name]],
                                      [t('label.candidate_sheet.grade'), [:candidate_sheet, :grade]],
                                      [t('label.candidate_sheet.attending'), [:candidate_sheet, :attending]]
                                  ],
                                  @candidates,
                                  rendered)

  end

end