# frozen_string_literal: true

BIRTH_DATE = '1998-04-09'
BAPTISMAL_DATE = '1998-05-05'
CHURCH_NAME = 'St. Paul'
STREET_1 = 'St. Paul Way'
STREET_2 = 'Suite 1313'
CITY = 'Clarksville'
STATE = 'IN'
ZIP_CODE = '47129'
FATHER_FIRST = 'Paul'
FATHER_MIDDLE = 'The'
LAST_NAME = 'Apostle'
MOTHER_FIRST = 'Paulette'
MOTHER_MIDDLE = 'Thette'
MOTHER_MAIDEN = 'Mary'

shared_context 'baptismal_certificate_html_erb' do
  before(:each) do
    event_with_picture_setup(Event::Route::BAPTISMAL_CERTIFICATE, @is_verify)
    AppFactory.add_confirmation_events
  end

  scenario 'admin logs in and selects a candidate, initial baptized_at_stmm = false, show_empty_radio = 0, nothing else showing' do
    @candidate.baptismal_certificate.baptized_at_stmm = false
    @candidate.baptismal_certificate.show_empty_radio = 0
    @candidate.save
    update_baptismal_certificate(false)

    visit @path

    expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, true, true, true)
  end

  scenario 'admin logs in and selects a candidate, initial baptized_at_stmm = true, show_empty_radio = 0nothing else showing' do
    @candidate.baptismal_certificate.baptized_at_stmm = true
    @candidate.baptismal_certificate.show_empty_radio = 0
    @candidate.save
    update_baptismal_certificate(false)

    visit @path

    expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, true, true, true)
  end

  scenario 'admin logs in and selects a candidate, initial baptized_at_stmm = true, show_empty_radio = 0nothing else showing' do
    @candidate.baptismal_certificate.baptized_at_stmm = true
    @candidate.baptismal_certificate.show_empty_radio = 1
    @candidate.save
    update_baptismal_certificate(false)

    visit @path

    expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, true, true, true)
  end

  scenario 'admin logs in and selects a candidate, initial baptized_at_stmm = true, show_empty_radio = 1 fc showung - no check showing' do
    @candidate.baptismal_certificate.baptized_at_stmm = false
    @candidate.baptismal_certificate.show_empty_radio = 1
    @candidate.save
    update_baptismal_certificate(false)

    visit @path

    expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, false, true, true)
  end

  scenario 'admin logs in and selects a candidate, initial baptized_at_stmm = true, show_empty_radio = 1 fc showung - yes check' do
    @candidate.baptismal_certificate.baptized_at_stmm = false
    @candidate.baptismal_certificate.first_comm_at_stmm = true
    @candidate.baptismal_certificate.show_empty_radio = 2
    @candidate.save
    update_baptismal_certificate(false)

    visit @path

    expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, false, true, true)
  end

  scenario 'admin logs in and selects a candidate, initial baptized_at_stmm = true, show_empty_radio = 1 fc showung - no check' do
    @candidate.baptismal_certificate.baptized_at_stmm = false
    @candidate.baptismal_certificate.first_comm_at_stmm = false
    @candidate.baptismal_certificate.show_empty_radio = 2
    @candidate.save
    update_baptismal_certificate(false)

    visit @path

    expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, false, false, true)
  end

  scenario 'admin logs in and selects a candidate, unchecks baptized_at_stmm, first communion showing' do
    @candidate.baptismal_certificate.baptized_at_stmm = false
    @candidate.baptismal_certificate.first_comm_at_stmm = false
    @candidate.baptismal_certificate.show_empty_radio = 2
    @candidate.save
    update_baptismal_certificate(true)

    visit @path

    expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, false, false, false)
  end

  scenario 'admin logs in and selects a candidate, unchecks baptized_at_stmm, fills in template' do
    @candidate.baptismal_certificate.baptized_at_stmm = false
    @candidate.baptismal_certificate.first_comm_at_stmm = false
    @candidate.baptismal_certificate.show_empty_radio = 2
    @candidate.save
    update_baptismal_certificate(false)

    expect_db(1, 9, 0)

    visit @path
    expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, false, false, true)
    fill_in_form

    click_button @update_id

    candidate = Candidate.find(@candidate.id)

    if @is_verify

      expect_mass_edit_candidates_event(ConfirmationEvent.find_by(name: I18n.t('events.baptismal_certificate')), candidate, @updated_message)

    else

      expect_baptismal_certificate_form(candidate.id, @dev, @path_str, @button_name, false, false, false, expected_messages: [[:flash_notice, @updated_message]])

    end

    expect(candidate.baptismal_certificate.birth_date.to_s).to eq(BIRTH_DATE)
    expect(candidate.baptismal_certificate.baptismal_date.to_s).to eq(BAPTISMAL_DATE)
    expect(candidate.baptismal_certificate.church_name).to eq(CHURCH_NAME)
    expect(candidate.baptismal_certificate.church_address.street_1).to eq(STREET_1)
    expect(candidate.baptismal_certificate.church_address.street_2).to eq(STREET_2)
    expect(candidate.baptismal_certificate.church_address.city).to eq(CITY)
    expect(candidate.baptismal_certificate.church_address.state).to eq(STATE)
    expect(candidate.baptismal_certificate.church_address.zip_code).to eq(ZIP_CODE)
    expect(candidate.baptismal_certificate.father_first).to eq(FATHER_FIRST)
    expect(candidate.baptismal_certificate.father_middle).to eq(FATHER_MIDDLE)
    expect(candidate.baptismal_certificate.father_last).to eq(LAST_NAME)
    expect(candidate.baptismal_certificate.mother_first).to eq(MOTHER_FIRST)
    expect(candidate.baptismal_certificate.mother_middle).to eq(MOTHER_MIDDLE)
    expect(candidate.baptismal_certificate.mother_maiden).to eq(MOTHER_MAIDEN)
    expect(candidate.baptismal_certificate.mother_last).to eq(LAST_NAME)

    expect_db(1, 9, 1) # make sure DB does not increase in size.
  end

  scenario 'admin logs in and selects a candidate, unchecks baptized_at_stmm, fills in template then changes mind she was baptized at stmm' do
    @candidate.baptismal_certificate.baptized_at_stmm = false
    @candidate.baptismal_certificate.first_comm_at_stmm = false
    @candidate.baptismal_certificate.show_empty_radio = 2
    @candidate.save
    update_baptismal_certificate(false)
    visit @path
    fill_in_form
    click_button @update_id

    candidate = Candidate.find(@candidate.id)
    if @is_verify

      expect_mass_edit_candidates_event(ConfirmationEvent.find_by(name: I18n.t('events.baptismal_certificate')), candidate, @updated_message)

    else

      expect_baptismal_certificate_form(candidate.id, @dev, @path_str, @button_name, false, false, false, expected_messages: [[:flash_notice, @updated_message]])

    end

    visit @path

    choose('candidate_baptismal_certificate_attributes_baptized_at_stmm_1')
    # since js is not called set show_empty_radio as update_show_empty_radio would do
    find(:id, 'candidate_baptismal_certificate_attributes_show_empty_radio', visible: false).set('1')

    click_button @update_id

    candidate = Candidate.find(@candidate.id)
    if @is_verify

      expect_mass_edit_candidates_event(ConfirmationEvent.find_by(name: I18n.t('events.baptismal_certificate')), candidate, @updated_message)

    else

      expect_baptismal_certificate_form(candidate.id, @dev, @path_str, @button_name, true, true, true, expected_messages: [[:flash_notice, @updated_message]])

    end

    expect(candidate.baptized_at_stmm).to eq(true)
    expect(candidate.baptismal_certificate).not_to eq(nil) # always created now
    expect(candidate.get_candidate_event(I18n.t('events.baptismal_certificate')).completed_date).to eq(Date.today)
    expect(candidate.get_candidate_event(I18n.t('events.baptismal_certificate')).verified).to eq(@is_verify)
  end

  scenario 'admin logs in and selects a candidate, unchecks baptized_at_stmm, adds picture, updates, adds rest of valid data, updates - everything is saved' do
    @candidate.baptismal_certificate.baptized_at_stmm = false
    @candidate.baptismal_certificate.first_comm_at_stmm = false
    @candidate.baptismal_certificate.show_empty_radio = 2
    @candidate.save
    update_baptismal_certificate(false)

    expect_db(1, 9, 0)

    visit @path

    attach_file(I18n.t('label.baptismal_certificate.baptismal_certificate.certificate_picture'), 'spec/fixtures/actions.png')
    click_button @update_id

    candidate = Candidate.find(@candidate.id)
    expect_baptismal_certificate_form(candidate.id, @dev, @path_str, @button_name, false, false, false,
                                      expect_messages: [[:flash_notice, @updated_failed_verification],
                                                        [:error_explanation, "Your changes were saved!! 11 empty fields need to be filled in on the form to be verfied: Birth date can't be blank Baptismal date can't be blank Church name can't be blank Father first can't be blank Father middle can't be blank Father last can't be blank Mother first can't be blank Mother middle can't be blank Mother maiden can't be blank Mother last can't be blank Street 1 can't be blank"]])

    expect_db(1, 9, 1)
    expect(page).to have_selector(img_src_selector)

    fill_in_form(false) # no picture
    click_button @update_id

    candidate = Candidate.find(@candidate.id)

    if @is_verify

      expect_mass_edit_candidates_event(ConfirmationEvent.find_by(name: I18n.t('events.baptismal_certificate')), candidate, @updated_message)

    else
      expect_baptismal_certificate_form(candidate.id, @dev, @path_str, @button_name, false, false, false, expected_messages: [[:flash_notice, @updated_message]])
    end

    expect_db(1, 9, 1)
    expect(candidate.baptized_at_stmm).to eq(false)
    expect(candidate.baptismal_certificate).not_to eq(nil)
    expect(candidate.baptismal_certificate.scanned_certificate).not_to eq(nil)

    visit @path
    candidate = Candidate.find(@candidate.id)
    expect_baptismal_certificate_form(candidate.id, @dev, @path_str, @button_name, false, false, false)

    expect_db(1, 9, 1) # make sure DB does not increase in size.
  end

  scenario 'admin logs in and selects a candidate, unchecks baptized_at_stmm, adds non-picture data, updates, adds picture, updates - everything is saved' do
    @candidate.baptismal_certificate.baptized_at_stmm = false
    @candidate.baptismal_certificate.first_comm_at_stmm = false
    @candidate.baptismal_certificate.show_empty_radio = 2
    @candidate.save
    update_baptismal_certificate(false)
    visit @path

    fill_in_form(false) # no picture
    click_button @update_id

    expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, false, false, false,
                                      expect_messages: [[:flash_notice, @updated_failed_verification],
                                                        [:error_explanation, ['Your changes were saved!! 1 empty field needs to be filled in on the form to be verfied:', 'Scanned baptismal certificate can\'t be blank']]])

    attach_file(I18n.t('label.baptismal_certificate.baptismal_certificate.certificate_picture'), 'spec/fixtures/actions.png')
    click_button @update_id

    candidate = Candidate.find(@candidate.id)
    if @is_verify

      expect_mass_edit_candidates_event(ConfirmationEvent.find_by(name: I18n.t('events.baptismal_certificate')), candidate, @updated_message)

    else

      expect_baptismal_certificate_form(candidate.id, @dev, @path_str, @button_name, false, false, false, expect_messages: [[:flash_notice, @updated_message]])

      expect(candidate.baptized_at_stmm).to eq(false)
      expect(candidate.baptismal_certificate).not_to eq(nil)
      expect(candidate.baptismal_certificate.scanned_certificate).not_to eq(nil)

    end

    visit @path
    candidate = Candidate.find(@candidate.id)
    expect_baptismal_certificate_form(candidate.id, @dev, @path_str, @button_name, false, false, false)
  end

  scenario 'admin logs in and selects a candidate, unchecks baptized_at_stmm, fills in template, except street_1' do
    @candidate.baptismal_certificate.baptized_at_stmm = false
    @candidate.baptismal_certificate.first_comm_at_stmm = false
    @candidate.baptismal_certificate.show_empty_radio = 2
    @candidate.save
    update_baptismal_certificate(false)
    visit @path
    fill_in_form
    fill_in('Street 1', with: nil)
    click_button @update_id

    expect(page).to have_selector(img_src_selector)
    candidate = Candidate.find(@candidate.id)
    expect_baptismal_certificate_form(candidate.id, @dev, @path_str, @button_name, false, false, false,
                                      expect_messages: [[:flash_notice, @updated_failed_verification],
                                                        [:error_explanation, 'Your changes were saved!! 1 empty field needs to be filled in on the form to be verfied: Street 1 can\'t be blank']],
                                      street_1: '')
  end

  def expect_baptismal_certificate_form(cand_id, dev_path, path_str, button_name, hide_first_comm, hide_baptismal_certificate, dont_show_values,
                                        values = {
                                          birth_date: dont_show_values ? nil : BIRTH_DATE,
                                          baptismal_date: dont_show_values ? nil : BAPTISMAL_DATE,

                                          church_name: dont_show_values ? nil : CHURCH_NAME,
                                          street_1: dont_show_values ? nil : STREET_1,
                                          street_2: dont_show_values ? nil : STREET_2,
                                          city: dont_show_values ? nil : CITY,
                                          state: dont_show_values ? nil : STATE,
                                          zip_code: dont_show_values ? nil : ZIP_CODE,

                                          father_first: dont_show_values ? nil : FATHER_FIRST,
                                          father_middle: dont_show_values ? nil : FATHER_MIDDLE,
                                          father_last: dont_show_values ? nil : LAST_NAME,

                                          mother_first: dont_show_values ? nil : MOTHER_FIRST,
                                          mother_middle: dont_show_values ? nil : MOTHER_MIDDLE,
                                          mother_maiden: dont_show_values ? nil : MOTHER_MAIDEN,
                                          mother_last: dont_show_values ? nil : LAST_NAME
                                        })

    # street_1 = values[:street_1].nil? ? STREET_1 : values[:street_1]

    expect_messages(values[:expect_messages]) unless values[:expect_messages].nil?

    cand = Candidate.find(cand_id)

    expect_heading(cand, dev_path.empty?, I18n.t('events.baptismal_certificate'))

    expect(page).to have_selector("form[id=edit_candidate][action=\"/#{dev_path}#{path_str}/#{cand_id}/baptismal_certificate\"]")
    expect(page).to have_selector('div', text: I18n.t('label.baptismal_certificate.baptismal_certificate.baptized_at_stmm'))
    expect(page).to have_selector('div', text: I18n.t('label.baptismal_certificate.baptismal_certificate.first_comm_at_stmm'))

    yes_id = 'candidate_baptismal_certificate_attributes_baptized_at_stmm_1'
    no_id = 'candidate_baptismal_certificate_attributes_baptized_at_stmm_0'
    expect(page).to have_selector("input[type=radio][id=#{yes_id}][value='1']", count: 1)
    expect(page).to have_selector("input[type=radio][id=#{no_id}][value='0']", count: 1)

    should_show_checked = cand.baptismal_certificate.show_empty_radio > 0
    yes_checked = should_show_checked && cand.baptismal_certificate.baptized_at_stmm
    no_checked = should_show_checked && !cand.baptismal_certificate.baptized_at_stmm

    if should_show_checked
      expect(find_field(yes_id)).to be_checked if yes_checked
      expect(find_field(no_id)).not_to be_checked if yes_checked

      expect(find_field(yes_id)).not_to be_checked if no_checked
      expect(find_field(no_id)).to be_checked if no_checked

    end

    fc_id_yes = 'candidate_baptismal_certificate_attributes_first_comm_at_stmm_1'
    fc_id_no = 'candidate_baptismal_certificate_attributes_first_comm_at_stmm_0'

    expect(page).to have_selector("input[type=radio][id=#{fc_id_yes}][value='1']", count: 1)
    expect(page).to have_selector("input[type=radio][id=#{fc_id_no}][value='0']", count: 1)

    should_show_fc_checked = !hide_first_comm && cand.baptismal_certificate.show_empty_radio > 1
    fc_yes_checked = should_show_checked && cand.baptismal_certificate.first_comm_at_stmm
    fc_no_checked = should_show_checked && !cand.baptismal_certificate.first_comm_at_stmm

    if should_show_fc_checked
      expect(find_field(fc_id_yes)).to be_checked if fc_yes_checked
      expect(find_field(fc_id_no)).not_to be_checked if fc_yes_checked

      expect(find_field(fc_id_yes)).not_to be_checked if fc_no_checked
      expect(find_field(fc_id_no)).to be_checked if fc_no_checked

    end

    expect(page).to have_selector("div[id=first-communion-top][class='field #{hide_first_comm ? 'hide-div' : 'show-div'}']")
    expect(page).to have_selector("div[id=baptismal-certificate-top][class='#{hide_baptismal_certificate ? 'hide-div' : 'show-div'}']")

    expect_field(I18n.t('label.baptismal_certificate.baptismal_certificate.certificate_picture'), nil)

    expect_field('Birth date', values[:birth_date])
    expect_field('Baptismal date', values[:baptismal_date])

    expect_field('Church name', values[:church_name])
    expect_field('Street 1', values[:street_1])
    expect_field('Street 2', values[:street_2])
    expect_field('City', values[:city])
    expect_field('State', values[:state])
    expect_field('Zip code', values[:zip_code])

    expect_field('Father first', values[:father_first])
    expect_field('Father middle', values[:father_middle])
    expect_field('Father last', values[:father_last])

    expect_field('Mother first', values[:mother_first])
    expect_field('Mother middle', values[:mother_middle])
    expect_field('Mother maiden', values[:mother_maiden])
    expect_field('Mother last', values[:mother_last])

    expect_image_upload('baptismal_certificate', 'certificate_picture', I18n.t('label.baptismal_certificate.baptismal_certificate.certificate_picture'))

    expect(page).to have_button(button_name)
    expect_download_button(Event::Document::BAPTISMAL_CERTIFICATE, cand_id, dev_path)
  end

  def expect_field(label, value)
    if value.nil? || value == ''
      expect(page).to have_field(label)
    else
      expect(page).to have_field(label, with: value)
    end
  end

  def fill_in_form(attach_file = true)
    fill_in('Birth date', with: BIRTH_DATE)
    fill_in('Baptismal date', with: BAPTISMAL_DATE)
    fill_in('Church name', with: CHURCH_NAME)
    fill_in('Street 1', with: STREET_1)
    fill_in('Street 2', with: STREET_2)
    fill_in('City', with: CITY)
    fill_in('State', with: STATE)
    fill_in('Zip code', with: ZIP_CODE)
    fill_in('Father first', with: FATHER_FIRST)
    fill_in('Father middle', with: FATHER_MIDDLE)
    fill_in('Father last', with: LAST_NAME)
    fill_in('Mother first', with: MOTHER_FIRST)
    fill_in('Mother middle', with: MOTHER_MIDDLE)
    fill_in('Mother maiden', with: MOTHER_MAIDEN)
    fill_in('Mother last', with: LAST_NAME)
    attach_file(I18n.t('label.baptismal_certificate.baptismal_certificate.certificate_picture'), 'spec/fixtures/actions.png') if attach_file
  end

  def img_src_selector
    "img[src=\"/#{@dev}event_with_picture_image/#{@candidate.id}/baptismal_certificate\"]"
  end

  def update_baptismal_certificate(with_values)
    baptismal_certificate = @candidate.baptismal_certificate
    return unless with_values
    baptismal_certificate.birth_date = Date.parse(BIRTH_DATE)
    baptismal_certificate.baptismal_date = Date.parse(BAPTISMAL_DATE)

    baptismal_certificate.church_name = CHURCH_NAME
    baptismal_certificate.church_address.street_1 = STREET_1
    baptismal_certificate.church_address.street_2 = STREET_2
    baptismal_certificate.church_address.city = CITY
    baptismal_certificate.church_address.state = STATE
    baptismal_certificate.church_address.zip_code = ZIP_CODE

    baptismal_certificate.father_first = FATHER_FIRST
    baptismal_certificate.father_middle = FATHER_MIDDLE
    baptismal_certificate.father_last = LAST_NAME

    baptismal_certificate.mother_first = MOTHER_FIRST
    baptismal_certificate.mother_middle = MOTHER_MIDDLE
    baptismal_certificate.mother_maiden = MOTHER_MAIDEN
    baptismal_certificate.mother_last = LAST_NAME
    @candidate.save
  end
end
