include ViewsHelpers

describe 'admins/mass_edit_candidates_event.html.erb' do

  before(:each) do

    @candidate_1 = Candidate.find_by_account_name(create_candidate('Vicki', 'Anne', 'Kristoff').account_name)
    @candidate_2 = Candidate.find_by_account_name(create_candidate('Paul', 'Richard', 'Kristoff').account_name)
    @candidates = [@candidate_1, @candidate_2]
    AppFactory.add_confirmation_events

    @confirmation_event = ConfirmationEvent.find_by_name(I18n.t('events.candidate_covenant_agreement'))
    @candidate_info = PluckCan.pluck_candidates(@confirmation_event.id)

  end


  it 'display the list of candidates' do

    render

    expect(rendered).to have_css "form[action='/mass_edit_candidates_event_update/#{@confirmation_event.id}']"

    expect(rendered).to have_css("input[type='submit'][value='#{t('views.common.update')}']", count: 2)

    expect(rendered).to have_css("input[id='top-update'][type='submit'][value='#{t('views.common.update')}']")

    expect(rendered).to have_css 'input[type=checkbox][id=verified][value="1"]'
    expect(rendered).to have_field(t('views.events.verified'))
    expect(rendered).to have_field(t('views.events.completed_date'))

    expect_sorting_candidate_list(
        candidate_events_columns,
        @candidates,
        rendered,
        @confirmation_event)

    expect(rendered).to have_css("input[id='bottom-update'][type='submit'][value='#{t('views.common.update')}']")

  end

end