WHO_HELD_RETREAT = 'George'
WHERE_HELD_RETREAT = 'Over there'
START_DATE = Date.today - 10
END_DATE = Date.today - 5


shared_context 'retreat_verification_html_erb' do

  before(:each) do
    event_with_picture_setup(Event::Route::RETREAT_VERIFICATION, @is_verify)
    AppFactory.add_confirmation_events

    @candidate_event_id = @candidate.get_candidate_event(I18n.t('events.retreat_verification')).id
    @cand_id = @candidate.id
  end

  scenario 'admin logs in and selects a candidate, nothing else showing' do
    # AppFactory.add_confirmation_event(I18n.t('events.retreat_verification'))
    # update_retreat_verification(false)
    visit @path
    expect_retreat_verification_form(@cand_id, @dev, @path_str,
                                     who_held_retreat: '',
                                     where_held_retreat: '',
                                     start_date: '',
                                     end_date: '')
  end

  scenario 'admin logs in and selects a candidate, fills in template and no picture' do
    # AppFactory.add_confirmation_event(I18n.t('events.retreat_verification'))

    expect_db(1, 9, 0)

    visit @path

    fill_in_form(false)
    click_button @update_id

    candidate = Candidate.find(@cand_id)
    if @is_verify

      expect_mass_edit_candidates_event(ConfirmationEvent.find_by_name(I18n.t('events.retreat_verification')), candidate, @updated_message)

    else

      expect_retreat_verification_form(@cand_id, @dev, @path_str,
                                       expect_messages: [[:flash_notice, @updated_message]
                                       ])
    end

    retreat_verification = candidate.retreat_verification
    expect(retreat_verification.retreat_held_at_stmm).to eq(true)
    expect(retreat_verification.who_held_retreat).to eq(WHO_HELD_RETREAT)
    expect(retreat_verification.where_held_retreat).to eq(WHERE_HELD_RETREAT)
    expect(retreat_verification.start_date).to eq(START_DATE)
    expect(retreat_verification.end_date).to eq(END_DATE)
    expect(retreat_verification.scanned_retreat).to eq(nil)

    expect(CandidateEvent.find(@candidate_event_id).completed_date).to eq(Date.today)
    expect(CandidateEvent.find(@candidate_event_id).verified).to eq(@is_verify)

    visit @path
    expect_retreat_verification_form(@cand_id, @dev, @path_str)

    expect_db(1, 9, 0) #make sure DB does not increase in size.
  end

  scenario 'admin logs in and selects a candidate, fills in template and picture' do
    # AppFactory.add_confirmation_event(I18n.t('events.retreat_verification'))

    expect_db(1, 9, 0)
    visit @path
    fill_in_form(true)
    click_button @update_id

    candidate = Candidate.find(@cand_id)

    if @is_verify

      expect_mass_edit_candidates_event(ConfirmationEvent.find_by_name(I18n.t('events.retreat_verification')), candidate, @updated_message)

    else
    expect_retreat_verification_form(@cand_id, @dev, @path_str,
                                     expect_messages: [[:flash_notice, @updated_message]
                                     ]
    )
    end
    retreat_verification = candidate.retreat_verification
    expect(retreat_verification.who_held_retreat).to eq(WHO_HELD_RETREAT)
    expect(retreat_verification.where_held_retreat).to eq(WHERE_HELD_RETREAT)
    expect(retreat_verification.start_date).to eq(START_DATE)
    expect(retreat_verification.end_date).to eq(END_DATE)
    expect(retreat_verification.scanned_retreat.filename).to eq('actions for spec testing.png')

    expect(CandidateEvent.find(@candidate_event_id).completed_date).to eq(Date.today)
    expect(CandidateEvent.find(@candidate_event_id).verified).to eq(@is_verify)

    visit @path
    expect_retreat_verification_form(@cand_id, @dev, @path_str)

    expect_db(1, 9, 1) #make sure DB does not increase in size.
  end

  scenario 'admin logs in and selects a candidate, adds picture, updates, updates - everything is saved' do
    # AppFactory.add_confirmation_event(I18n.t('events.retreat_verification'))

    expect_db(1, 9, 0)
    candidate = Candidate.find(@cand_id)
    candidate.retreat_verification.retreat_held_at_stmm = false
    candidate.save
    visit @path

    attach_file(I18n.t('label.retreat_verification.retreat_verification_picture'), 'spec/fixtures/actions for spec testing.png')
    click_button @update_id

    expect_retreat_verification_form(@cand_id, @dev, @path_str,
                                     expect_messages: [[:flash_notice, @updated_failed_verification],
                                                       [:error_explanation, 'Your changes were saved!! 4 empty fields need to be filled in on the form to be verfied: Start date can\'t be blank End date can\'t be blank Who held retreat can\'t be blank Where held retreat can\'t be blank']
                                     ],
                                     who_held_retreat: '',
                                     where_held_retreat: '',
                                     start_date: '',
                                     end_date: '')

    expect(Candidate.find(@cand_id).retreat_verification.scanned_retreat.filename).to eq('actions for spec testing.png')

    expect(CandidateEvent.find(@candidate_event_id).completed_date).to eq(nil)

    visit @path
    expect_retreat_verification_form(@cand_id, @dev, @path_str, who_held_retreat: '',
                                     where_held_retreat: '',
                                     start_date: '',
                                     end_date: '')

    expect_db(1, 9, 1) #make sure DB does not increase in size.

  end

  scenario 'admin logs in and selects a candidate, fills in form except picture.' do
    candidate = Candidate.find(@cand_id)
    candidate.retreat_verification.retreat_held_at_stmm = false
    candidate.save

    visit @path

    fill_in_form(false, false)
    click_button @update_id

    expect_retreat_verification_form(@cand_id, @dev, @path_str,
                                     expect_messages: [[:flash_notice, @updated_failed_verification],
                                                       [:error_explanation, 'Your changes were saved!! 1 empty field needs to be filled in on the form to be verfied: Scanned retreat verification can\'t be blank']
                                     ])
  end

  scenario 'admin logs in and selects a candidate, fills in template, except Who held retreat' do

    # AppFactory.add_confirmation_event(I18n.t('events.retreat_verification'))
    # update_retreat_verification(false)
    candidate = Candidate.find(@cand_id)
    candidate.retreat_verification.retreat_held_at_stmm = false
    candidate.save
    visit @path

    fill_in_form(true, false)

    # check(I18n.t('label.retreat_verification.retreat_held_at_stmm')) # make it false
    fill_in(I18n.t('label.retreat_verification.who_held_retreat'), with: nil)
    click_button @update_id

    expect_retreat_verification_form(@cand_id, @dev, @path_str,
                                     expect_messages: [[:flash_notice, @updated_failed_verification],
                                                       [:error_explanation, 'Your changes were saved!! 1 empty field needs to be filled in on the form to be verfied: Who held retreat can\'t be blank']
                                     ],
                                     who_held_retreat: '')
  end

  def expect_retreat_verification_form(cand_id, dev_path, path_str,
                                       values = {
                                           who_held_retreat: WHO_HELD_RETREAT,
                                           where_held_retreat: WHERE_HELD_RETREAT,
                                           start_date: START_DATE,
                                           end_date: END_DATE
                                       })

    candidate = Candidate.find(cand_id)
    expect_messages(values[:expect_messages]) unless values[:expect_messages].nil?
    expect(page).to have_selector("form[id=edit_candidate][action=\"/#{dev_path}#{path_str}/#{candidate.id}/retreat_verification\"]")

    expect_field(I18n.t('label.retreat_verification.retreat_verification_picture'), nil)

    expect_field(I18n.t('label.retreat_verification.who_held_retreat'), values[:who_held_retreat])
    expect_field(I18n.t('label.retreat_verification.where_held_retreat'), values[:where_held_retreat])
    expect_field(I18n.t('label.retreat_verification.start_date'), values[:start_date])
    expect_field(I18n.t('label.retreat_verification.end_date'), values[:end_date])

    expect_image_upload('retreat_verification', 'retreat_verification_picture', I18n.t('label.retreat_verification.retreat_verification_picture'))

    expect(page).to have_button(@update_id)
    expect_download_button(Event::Document::RETREAT_VERIFICATION)
  end

  def expect_field (label, value)
    if value.nil? or value === ''
      expect(page).to have_field(label)
    else
      expect(page).to have_field(label, with: value)
    end
  end

  def fill_in_form(retreat_verification_attach_file, check_checkbox = true)
    check(I18n.t('label.retreat_verification.retreat_held_at_stmm')) if check_checkbox
    fill_in(I18n.t('label.retreat_verification.who_held_retreat'), with: WHO_HELD_RETREAT)
    fill_in(I18n.t('label.retreat_verification.where_held_retreat'), with: WHERE_HELD_RETREAT)
    fill_in(I18n.t('label.retreat_verification.start_date'), with: START_DATE)
    fill_in(I18n.t('label.retreat_verification.end_date'), with: END_DATE)
    if retreat_verification_attach_file
      attach_file(I18n.t('label.retreat_verification.retreat_verification_picture'), 'spec/fixtures/actions for spec testing.png')
    end
  end

  def img_src_selector
    "img[src=\"/#{@dev}event_with_picture_image/#{@cand_id}/retreat_verification\"]"
  end
end