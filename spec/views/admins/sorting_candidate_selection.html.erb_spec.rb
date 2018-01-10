include ViewsHelpers

describe 'shared/sorting_candidate_selection' do

  before(:each) do

    @candidate_1 = Candidate.find_by_account_name(create_candidate('Vicki', 'Anne', 'Kristoff').account_name)
    @candidate_2 = Candidate.find_by_account_name(create_candidate('Paul', 'Richard', 'Kristoff').account_name)
    @candidates = [@candidate_1, @candidate_2]
    AppFactory.add_confirmation_events

    @table_id = "table[id='candidate_list_table']"

    @confirmation_event = ConfirmationEvent.find_by_name(I18n.t('events.candidate_covenant_agreement'))
    @candidate_info = PluckCan.pluck_candidates(@confirmation_event.id)
  end

  describe 'basic view' do
    it 'should have this view' do

      render 'shared/sorting_candidate_selection', {confirmation_event: @confirmation_event,
                                                    candidates: @candidates,
                                                    candidate_info: @candidate_info,
                                                    route: :mass_edit_candidates_event
                                                    }

      @columns_select = candidate_events_columns(@confirmation_event)
      expect_sorting_candidate_list(@columns_select,
                                    @candidates,
                                    rendered,
                                    @confirmation_event)
    end
  end
end