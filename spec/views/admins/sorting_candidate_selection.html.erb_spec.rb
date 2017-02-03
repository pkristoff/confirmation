include ViewsHelpers

describe 'shared/sorting_candidate_selection' do

  before(:each) do

    @candidate_1 = Candidate.find_by_account_name(create_candidate('Vicki', 'Anne', 'Kristoff').account_name)
    @candidate_2 = Candidate.find_by_account_name(create_candidate('Paul', 'Richard', 'Kristoff').account_name)
    @candidates = [@candidate_1, @candidate_2]
    AppFactory.add_confirmation_events

    @table_id = "table[id='candidate_list_table']"

    @confirmation_event = ConfirmationEvent.find_by_name(I18n.t('events.candidate_covenant_agreement'))
  end

  describe 'basic view' do
    it 'should have this view' do

      render 'shared/sorting_candidate_selection', {confirmation_event: @confirmation_event,
                                                    candidates: @candidates,
                                                    route: :mass_edit_candidates_event
                                                    }

      expect_sorting_candidate_list([
                                        [t('label.candidate_event.select'), false, '', lambda {|candidate, rendered, td_index| expect(rendered).to have_css "input[type=checkbox][id=candidate_candidate_ids_#{candidate.id}]" }],
                                        [t('views.events.completed_date'), true, [:completed_date]],
                                        [t('label.candidate.account_name'), true, [:account_name], :up],
                                        [t('label.candidate_sheet.last_name'), true, [:candidate_sheet, :last_name]],
                                        [t('label.candidate_sheet.first_name'), true, [:candidate_sheet, :first_name]],
                                        [t('label.candidate_sheet.grade'), true, [:candidate_sheet, :grade]],
                                        [t('label.candidate_sheet.attending'), true, [:candidate_sheet, :attending]]
                                    ],
                                    @candidates,
                                    rendered,
                                    @confirmation_event)
    end
  end
end