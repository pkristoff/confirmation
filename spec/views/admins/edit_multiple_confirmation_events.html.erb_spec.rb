# frozen_string_literal: true

describe 'admins/edit_multiple_confirmation_events.html.erb' do
  include ViewsHelpers
  before(:each) do
    @candidate1 = Candidate.find_by(account_name: create_candidate('Vicki', 'Anne', 'Kristoff').account_name)
    @candidate2 = Candidate.find_by(account_name: create_candidate('Paul', 'Richard', 'Kristoff').account_name)
    @candidates = [@candidate1, @candidate2]

    AppFactory.add_confirmation_events

    @confirmation_events = ConfirmationEvent.all
  end

  it 'display the list of candidates' do
    render

    @confirmation_events.each do |confirmation_event|
      expect(rendered).to have_css('legend', text: Candidate.i18n_event_name(confirmation_event.event_key))
      id = confirmation_event.id
      the_way_due_date = confirmation_event.the_way_due_date
      expect(rendered).to have_css("input[id=confirmation_events_#{id}_the_way_due_date][value='#{the_way_due_date}']")
      chs_due_date = confirmation_event.chs_due_date
      expect(rendered).to have_css("input[id=confirmation_events_#{id}_chs_due_date][value='#{chs_due_date}']")
      expect(rendered).to have_css("span[id=instruction-area-#{id}][class=hide-div]", text: '')
      expect(rendered).to have_css("textarea[id=confirmation_events_#{id}_instructions][class=tinymce_#{id}]", text: '')

      expect(rendered).to have_css("input[id=update-#{id}][value='#{t('views.common.update')}']")
      expect(rendered).to have_css("input[id=candidates-#{id}][value='#{t('views.common.update_candidates_event')}']")
    end

    expect(rendered).to have_css('legend', count: @confirmation_events.size)
  end
end
