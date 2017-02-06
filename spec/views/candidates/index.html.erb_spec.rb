include ViewsHelpers
describe 'candidates/index.html.erb' do

  before(:each) do

    candidate_1 = create_candidate('Vicki', 'Anne', 'Kristoff')
    candidate_2 = create_candidate('Paul', 'Richard', 'Kristoff')

    AppFactory.add_confirmation_events

    # have to re-look up canduidates because local is diff object than db onstance
    @candidates = [Candidate.find_by_account_name(candidate_1.account_name),
                   Candidate.find_by_account_name(candidate_2.account_name)]

  end


  it 'display the list of candidates' do

    render

    expect_sorting_candidate_list(
        get_columns_index,
        @candidates,
        rendered)

  end

end

def get_columns_index
  [
      [I18n.t('label.candidate_event.select'), false, '', expect_select_checkbox],
      [I18n.t('views.nav.edit'), false, '', lambda { |candidate, rendered, td_index| expect(rendered).to have_css "td[id='tr#{candidate.id}_td#{td_index}']" }],
      [I18n.t('label.candidate_sheet.last_name'), true, [:candidate_sheet, :last_name]],
      [I18n.t('label.candidate_sheet.first_name'), true, [:candidate_sheet, :first_name]],
      [I18n.t('label.candidate_sheet.grade'), true, [:candidate_sheet, :grade]],
      [I18n.t('label.candidate_sheet.attending'), true, [:candidate_sheet, :attending]]
  ].concat(get_event_columns)
end