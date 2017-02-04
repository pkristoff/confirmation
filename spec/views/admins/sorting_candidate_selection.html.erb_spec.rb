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
                                        [t('label.candidate_event.select'), false, '', expect_select_checkbox],
                                        [t('views.events.completed_date'), true, [:completed_date]],
                                        [t('label.candidate_sheet.last_name'), true, [:candidate_sheet, :last_name]],
                                        [t('label.candidate_sheet.first_name'), true, [:candidate_sheet, :first_name]],
                                        [t('label.candidate_sheet.grade'), true, [:candidate_sheet, :grade]],
                                        [t('label.candidate_sheet.attending'), true, [:candidate_sheet, :attending]],
                                        [I18n.t('events.candidate_covenant_agreement'), true, '', expect_event(I18n.t('events.candidate_covenant_agreement'))],
                                        [I18n.t('events.candidate_information_sheet'), true, '', expect_event(I18n.t('events.candidate_information_sheet'))],
                                        [I18n.t('events.baptismal_certificate'), true, '', expect_event(I18n.t('events.baptismal_certificate'))],
                                        [I18n.t('events.sponsor_covenant'), true, '', expect_event(I18n.t('events.sponsor_covenant'))],
                                        [I18n.t('events.confirmation_name'), true, '', expect_event(I18n.t('events.confirmation_name'))],
                                        [I18n.t('events.sponsor_agreement'), true, '', expect_event(I18n.t('events.sponsor_agreement'))],
                                        [I18n.t('events.christian_ministry'), true, '', expect_event(I18n.t('events.christian_ministry'))]
                                    ],
                                    @candidates,
                                    rendered,
                                    @confirmation_event)
    end
  end
end