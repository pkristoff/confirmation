WHO_HELD_RETREAT = 'George'
WHERE_HELD_RETREAT = 'Over there'
START_DATE = Date.today-10
END_DATE = Date.today-5


shared_context 'retreat_verification_html_erb' do

  before(:each) do
    event_with_picture_setup(Event::Route::RETREAT_VERIFICATION)
    AppFactory.add_confirmation_events

  end

  scenario 'admin logs in and selects a candidate, nothing else showing' do
    # AppFactory.add_confirmation_event(I18n.t('events.retreat_verification'))
    # update_retreat_verification(false)
    visit @path
    expect_form_layout(@candidate, false)
  end

  scenario 'admin logs in and selects a candidate, fills in template and no picture' do
    # AppFactory.add_confirmation_event(I18n.t('events.retreat_verification'))

    expect_db(1, 9, 0)

    visit @path

    fill_in_form(false)
    click_button 'top-update'

    expect_message(:flash_notice, I18n.t('messages.updated'))
    candidate = Candidate.find(@candidate.id)
    expect(candidate.retreat_verification.retreat_held_at_stmm).to eq(true)
    expect(candidate.retreat_verification.who_held_retreat).to eq(WHO_HELD_RETREAT)
    expect(candidate.retreat_verification.where_held_retreat).to eq(WHERE_HELD_RETREAT)
    expect(candidate.retreat_verification.start_date).to eq(START_DATE)
    expect(candidate.retreat_verification.end_date).to eq(END_DATE)
    expect(candidate.retreat_verification.scanned_retreat).to eq(nil)

    expect(candidate.get_candidate_event(I18n.t('events.retreat_verification')).completed_date).to eq(Date.today)

    visit @path
    candidate = Candidate.find(@candidate.id)
    expect_form_layout(candidate, true)

    expect_db(1, 9, 0)  #make sure DB does not increase in size.
  end

  scenario 'admin logs in and selects a candidate, fills in template and picture' do
    # AppFactory.add_confirmation_event(I18n.t('events.retreat_verification'))

    expect_db(1, 9, 0)
    visit @path
    fill_in_form(true)
    click_button 'top-update'

    expect_message(:flash_notice, I18n.t('messages.updated'))
    candidate = Candidate.find(@candidate.id)
    expect(candidate.retreat_verification.who_held_retreat).to eq(WHO_HELD_RETREAT)
    expect(candidate.retreat_verification.where_held_retreat).to eq(WHERE_HELD_RETREAT)
    expect(candidate.retreat_verification.start_date).to eq(START_DATE)
    expect(candidate.retreat_verification.end_date).to eq(END_DATE)
    expect(candidate.retreat_verification.scanned_retreat.filename).to eq('actions for spec testing.png')

    expect(candidate.get_candidate_event(I18n.t('events.retreat_verification')).completed_date).to eq(Date.today)
    expect(candidate.get_candidate_event(I18n.t('events.retreat_verification')).verified).to eq(false)

    visit @path
    candidate = Candidate.find(@candidate.id)
    expect_form_layout(candidate, true)

    expect_db(1, 9, 1)  #make sure DB does not increase in size.
  end

  scenario 'admin logs in and selects a candidate, adds picture, updates, updates - everything is saved' do
    # AppFactory.add_confirmation_event(I18n.t('events.retreat_verification'))

    expect_db(1, 9, 0)
    candidate = Candidate.find(@candidate.id)
    candidate.retreat_verification.retreat_held_at_stmm=false
    candidate.save
    visit @path

    attach_file(I18n.t('label.retreat_verification.retreat_verification_picture'), 'spec/fixtures/actions for spec testing.png')
    click_button 'top-update'

    expect_message(:error_explanation, '4 empty fields need to be filled in: Start date can\'t be blank End date can\'t be blank Who held retreat can\'t be blank Where held retreat can\'t be blank')
    candidate = Candidate.find(@candidate.id)
    expect(candidate.retreat_verification.who_held_retreat).to eq('')
    expect(candidate.retreat_verification.where_held_retreat).to eq('')
    expect(candidate.retreat_verification.start_date).to eq(nil)
    expect(candidate.retreat_verification.end_date).to eq(nil)
    expect(candidate.retreat_verification.scanned_retreat.filename).to eq('actions for spec testing.png')

    expect(candidate.get_candidate_event(I18n.t('events.retreat_verification')).completed_date).to eq(nil)

    visit @path
    candidate = Candidate.find(@candidate.id)
    expect_form_layout(candidate, false)

    expect_db(1, 9, 1)  #make sure DB does not increase in size.

  end

  scenario 'admin logs in and selects a candidate, fills in form except picture.' do
    candidate = Candidate.find(@candidate.id)
    candidate.retreat_verification.retreat_held_at_stmm=false
    candidate.save

    visit @path

    fill_in_form(false, false)
    click_button 'top-update'

    expect_message(:error_explanation, '1 empty field need to be filled in: Scanned retreat verification can\'t be blank')

  end

  scenario 'admin logs in and selects a candidate, fills in template, except Who held retreat' do

    # AppFactory.add_confirmation_event(I18n.t('events.retreat_verification'))
    # update_retreat_verification(false)
    candidate = Candidate.find(@candidate.id)
    candidate.retreat_verification.retreat_held_at_stmm=false
    candidate.save
    visit @path

    fill_in_form(true, false)

    # check(I18n.t('label.retreat_verification.retreat_held_at_stmm')) # make it false
    fill_in(I18n.t('label.retreat_verification.who_held_retreat'), with: nil)
    click_button 'top-update'

    expect_message(:error_explanation, '1 empty field need to be filled in: Who held retreat can\'t be blank')
    candidate = Candidate.find(@candidate.id)
    expect_form_layout(candidate, true, '')
  end

  def expect_form_layout(candidate, with_values, who_held_retreat=WHO_HELD_RETREAT)

    expect(page).to have_selector("form[id=edit_candidate][action=\"/#{@dev}event_with_picture/#{@candidate.id}/retreat_verification\"]")

    expect_field(I18n.t('label.retreat_verification.retreat_verification_picture'), nil)

    expect_field(I18n.t('label.retreat_verification.who_held_retreat'), with_values ? who_held_retreat : '')
    expect_field(I18n.t('label.retreat_verification.where_held_retreat'), with_values ? WHERE_HELD_RETREAT : '')
    expect_field(I18n.t('label.retreat_verification.start_date'), with_values ? START_DATE : '')
    expect_field(I18n.t('label.retreat_verification.end_date'), with_values ? END_DATE : '')

    expect(page).to have_button('top-update')
    expect_download_button(Event::Document::RETREAT_VERIFICATION)
  end

  def expect_field (label, value)
    if value.nil? or value === ''
      expect(page).to have_field(label)
    else
      expect(page).to have_field(label, with: value)
    end
  end

  def fill_in_form(retreat_verification_attach_file, check_checkbox=true)
    check(I18n.t('label.retreat_verification.retreat_held_at_stmm')) if check_checkbox
    fill_in(I18n.t('label.retreat_verification.who_held_retreat'), with: WHO_HELD_RETREAT)
    fill_in(I18n.t('label.retreat_verification.where_held_retreat'), with: WHERE_HELD_RETREAT)
    fill_in(I18n.t('label.retreat_verification.start_date'), with: START_DATE)
    fill_in(I18n.t('label.retreat_verification.end_date'), with: END_DATE)
    if retreat_verification_attach_file
      attach_file(I18n.t('label.retreat_verification.retreat_verification_picture'), 'spec/fixtures/actions for spec testing.png')
    end
  end

  def get_img_src_selector
    "img[src=\"/#{@dev}event_with_picture_image/#{@candidate.id}/retreat_verification\"]"
  end
end