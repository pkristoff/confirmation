# frozen_string_literal: true

describe 'admins/mass_edit_candidates_event.html.erb' do
  include ViewsHelpers
  before(:each) do
    @candidate1 = Candidate.find_by(account_name: create_candidate('Vicki', 'Anne', 'Kristoff').account_name)
    @candidate2 = Candidate.find_by(account_name: create_candidate('Paul', 'Richard', 'Kristoff').account_name)
    @candidates = [@candidate1, @candidate2]
    AppFactory.add_confirmation_events
  end

  AppFactory.all_i18n_confirmation_event_names.each do |confirmation_event_name|
    it "display the list of candidates for #{confirmation_event_name}" do
      @confirmation_event = ConfirmationEvent.find_by(name: confirmation_event_name)
      @candidate_info = PluckCan.pluck_candidates(event_id: @confirmation_event.id)

      render

      expect(rendered).to have_css "form[action='/mass_edit_candidates_event_update/#{@confirmation_event.id}']"

      expect(rendered).to have_css("input[type='submit'][value='#{t('views.common.update')}']", count: 2)

      expect(rendered).to have_css("input[id='top-update'][type='submit'][value='#{t('views.common.update')}']")

      expect(rendered).to have_css 'input[type=checkbox][id=verified][value="1"]'
      expect(rendered).to have_field(t('views.events.verified'))
      expect(rendered).to have_field(t('views.events.completed_date'))

      expect_sorting_candidate_list(
        candidate_events_columns(@confirmation_event),
        @candidates,
        rendered,
        @confirmation_event
      )

      expect(rendered).to have_css("input[id='bottom-update'][type='submit'][value='#{t('views.common.update')}']")
    end
  end
end
