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
                                      [t('label.candidate_event.select'), false, '', lambda {|candidate, rendered, td_index| expect(rendered).to have_css "input[type=checkbox][id=candidate_candidate_ids_#{candidate.id}]" }],
                                      [t('views.nav.edit'), false, '', lambda { |candidate, rendered, td_index| expect(rendered).to have_css "td[id='tr#{candidate.id}_td#{td_index}']" }],
                                      [t('label.candidate.account_name'), true, [:account_name], :up],
                                      [t('label.candidate_sheet.last_name'), true, [:candidate_sheet, :last_name]],
                                      [t('label.candidate_sheet.first_name'), true, [:candidate_sheet, :first_name]],
                                      [t('label.candidate_sheet.grade'), true, [:candidate_sheet, :grade]],
                                      [t('label.candidate_sheet.attending'), true, [:candidate_sheet, :attending]]
                                  ],
                                  @candidates,
                                  rendered)

  end

end