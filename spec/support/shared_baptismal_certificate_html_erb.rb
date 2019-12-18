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
LAST_NAME = 'Agusta'
MOTHER_FIRST = 'Paulette'
MOTHER_MIDDLE = 'Thette'
MOTHER_MAIDEN = 'Mary'
FIRST_NAME = 'Sophia'
MIDDLE_NAME = 'xxx'

shared_context 'baptismal_certificate_html_erb' do
  include ViewsHelpers
  before(:each) do
    event_with_picture_setup(Event::Route::BAPTISMAL_CERTIFICATE, @is_verify)
    AppFactory.add_confirmation_events
    @today = Time.zone.today
  end

  scenario 'admin logs in and selects a candidate, initial baptized_at_home_parish = false, show_empty_radio = 0, nothing else showing' do
    @candidate.baptismal_certificate.baptized_at_home_parish = false
    @candidate.baptismal_certificate.show_empty_radio = 0
    @candidate.save
    update_baptismal_certificate(false)

    visit @path

    expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify, true, true, true)
  end

  scenario 'admin logs in and selects a candidate, initial baptized_at_home_parish = true, show_empty_radio = 0 nothing else showing' do
    @candidate.baptismal_certificate.baptized_at_home_parish = true
    @candidate.baptismal_certificate.show_empty_radio = 0
    @candidate.save
    update_baptismal_certificate(false)

    visit @path

    expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify, true, true, true)
  end

  scenario 'admin logs in and selects a candidate, initial baptized_at_home_parish = true, show_empty_radio = 0 nothing else showing' do
    @candidate.baptismal_certificate.baptized_at_home_parish = true
    @candidate.baptismal_certificate.show_empty_radio = 1
    @candidate.save
    update_baptismal_certificate(false)

    visit @path

    expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify, true, true, true)
  end

  scenario 'admin logs in and selects a candidate, initial baptized_at_home_parish = true, show_empty_radio = 1 fc showing - no check showing' do
    @candidate.baptismal_certificate.baptized_at_home_parish = false
    @candidate.baptismal_certificate.show_empty_radio = 1
    @candidate.save
    update_baptismal_certificate(false)

    visit @path

    expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify, false, true, true)
  end

  scenario 'admin logs in and selects a candidate, initial baptized_at_home_parish = true, show_empty_radio = 1 fc showing - yes check' do
    @candidate.baptismal_certificate.baptized_at_home_parish = false
    @candidate.baptismal_certificate.first_comm_at_home_parish = true
    @candidate.baptismal_certificate.show_empty_radio = 2
    @candidate.save
    update_baptismal_certificate(false)

    visit @path

    expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify, false, false, true)
  end

  scenario 'admin logs in and selects a candidate, initial baptized_at_home_parish = true, show_empty_radio = 1 fc showung - no check' do
    @candidate.baptismal_certificate.baptized_at_home_parish = false
    @candidate.baptismal_certificate.first_comm_at_home_parish = false
    @candidate.baptismal_certificate.show_empty_radio = 2
    @candidate.save
    update_baptismal_certificate(false)

    visit @path

    expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify, false, false, true)
  end

  scenario 'admin logs in and selects a candidate, unchecks baptized_at_home_parish, first communion showing' do
    @candidate.baptismal_certificate.baptized_at_home_parish = false
    @candidate.baptismal_certificate.first_comm_at_home_parish = false
    @candidate.baptismal_certificate.show_empty_radio = 2
    @candidate.save
    update_baptismal_certificate(true)

    visit @path

    expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify, false, false, false)
  end

  scenario 'should not show a validation error for city and zip code' do
    candidate = Candidate.find(@candidate.id)
    @candidate.baptismal_certificate.baptized_at_home_parish = false
    @candidate.baptismal_certificate.first_comm_at_home_parish = false
    @candidate.baptismal_certificate.show_empty_radio = 2
    candidate.candidate_sheet.address.street_1 = ''
    candidate.candidate_sheet.address.street_2 = ''
    candidate.candidate_sheet.address.city = ''
    candidate.candidate_sheet.address.state = ''
    candidate.candidate_sheet.address.zip_code = ''
    suc = candidate.save
    expect(suc).to be(true)

    @candidate.save
    update_baptismal_certificate(false)

    visit @path
    expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify, false, false, true)
    fill_in_form

    click_button @update_id

    if @is_verify

      expect_mass_edit_candidates_event(ConfirmationEvent.find_by(name: I18n.t('events.baptismal_certificate')), candidate.id, @updated_message)

    else

      expect_baptismal_certificate_form(candidate.id, @dev, @path_str, @button_name, @is_verify, false, false, false,
                                        expect_messages: [[:flash_notice, @updated_message]])
    end
  end

  scenario 'admin logs in and selects a candidate, unchecks baptized_at_home_parish, fills in template' do
    @candidate.baptismal_certificate.baptized_at_home_parish = false
    @candidate.baptismal_certificate.first_comm_at_home_parish = false
    @candidate.baptismal_certificate.show_empty_radio = 2
    @candidate.save
    update_baptismal_certificate(false)

    expect_db(1, 8, 0)

    visit @path
    expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify, false, false, true)
    fill_in_form

    click_button @update_id

    candidate = Candidate.find(@candidate.id)

    if @is_verify

      expect_mass_edit_candidates_event(ConfirmationEvent.find_by(name: I18n.t('events.baptismal_certificate')), candidate.id, @updated_message)

    else

      expect_baptismal_certificate_form(candidate.id, @dev, @path_str, @button_name, @is_verify, false, false, false, expected_messages: [[:flash_notice, @updated_message]])

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

    expect(candidate.candidate_sheet.first_name).to eq(FIRST_NAME)
    expect(candidate.candidate_sheet.middle_name).to eq(MIDDLE_NAME)
    expect(candidate.candidate_sheet.last_name).to eq(LAST_NAME)

    expect_db(1, 8, 1) # make sure DB does not increase in size.
  end

  scenario 'admin logs in and selects a candidate, unchecks baptized_at_home_parish, fills in template then changes mind she was baptized at stmm' do
    @candidate.baptismal_certificate.baptized_at_home_parish = false
    @candidate.baptismal_certificate.first_comm_at_home_parish = false
    @candidate.baptismal_certificate.show_empty_radio = 2
    @candidate.save
    update_baptismal_certificate(false)
    visit @path
    fill_in_form
    click_button @update_id

    candidate = Candidate.find(@candidate.id)
    if @is_verify

      expect_mass_edit_candidates_event(ConfirmationEvent.find_by(name: I18n.t('events.baptismal_certificate')), candidate.id, @updated_message)

    else

      expect_baptismal_certificate_form(candidate.id, @dev, @path_str, @button_name, @is_verify, false, false, false, expected_messages: [[:flash_notice, @updated_message]])

    end

    visit @path

    choose('candidate_baptismal_certificate_attributes_baptized_at_home_parish_1')
    # since js is not called set show_empty_radio as update_show_empty_radio would do
    find(:id, 'candidate_baptismal_certificate_attributes_show_empty_radio', visible: false).set('1')

    click_button @update_id

    candidate = Candidate.find(@candidate.id)
    if @is_verify

      expect_mass_edit_candidates_event(ConfirmationEvent.find_by(name: I18n.t('events.baptismal_certificate')), candidate.id, @updated_message)

    else

      expect_baptismal_certificate_form(candidate.id, @dev, @path_str, @button_name, @is_verify, true, true, true, expected_messages: [[:flash_notice, @updated_message]])

    end

    expect(candidate.baptismal_certificate).not_to eq(nil) # always created now
    expect(candidate.baptismal_certificate.baptized_at_home_parish).to eq(true)
    expect(candidate.get_candidate_event(BaptismalCertificate.event_key).completed_date).to eq(@today)
    expect(candidate.get_candidate_event(BaptismalCertificate.event_key).verified).to eq(@is_verify)
  end

  scenario 'admin logs in and selects a candidate, unchecks baptized_at_home_parish, adds picture, updates, adds rest of valid data, updates - everything is saved' do
    @candidate.baptismal_certificate.baptized_at_home_parish = false
    @candidate.baptismal_certificate.first_comm_at_home_parish = false
    @candidate.baptismal_certificate.show_empty_radio = 2
    update_baptismal_certificate(false)
    @candidate.save

    expect_db(1, 8, 0)

    visit @path
    attach_file(I18n.t('label.baptismal_certificate.baptismal_certificate.certificate_picture'), 'spec/fixtures/actions.png')
    click_button @update_id

    candidate = Candidate.find(@candidate.id)
    expect_baptismal_certificate_form(candidate.id, @dev, @path_str, @button_name, @is_verify, false, false, false,
                                      expect_messages: [[:flash_notice, @updated_failed_verification],
                                                        [:error_explanation, ['Your changes were saved!! 15 empty fields need to be filled in on the form to be verified:',
                                                                              'Middle name can\'t be blank',
                                                                              'Birth date can\'t be blank',
                                                                              'Baptismal date can\'t be blank',
                                                                              'Church name can\'t be blank',
                                                                              'Father first can\'t be blank',
                                                                              'Father middle can\'t be blank',
                                                                              'Father last can\'t be',
                                                                              'Mother first can\'t be blank',
                                                                              'Mother middle can\'t be blank',
                                                                              'Mother maiden can\'t be blank',
                                                                              'Mother last can\'t be blank',
                                                                              'Street 1 can\'t be blank',
                                                                              'City can\'t be blank',
                                                                              'State can\'t be blank',
                                                                              'Zip code can\'t be blank']]])

    expect_db(1, 8, 1)
    expect(page).to have_selector(img_src_selector)

    fill_in_form(false) # no picture
    click_button @update_id

    candidate = Candidate.find(@candidate.id)

    if @is_verify

      expect_mass_edit_candidates_event(ConfirmationEvent.find_by(name: BaptismalCertificate.event_key), candidate.id, @updated_message)

    else
      expect_baptismal_certificate_form(candidate.id, @dev, @path_str, @button_name, @is_verify, false, false, false, expected_messages: [[:flash_notice, @updated_message]])
    end

    expect_db(1, 8, 1)
    expect(candidate.baptismal_certificate.baptized_at_home_parish).to eq(false)
    expect(candidate.baptismal_certificate).not_to eq(nil)
    expect(candidate.baptismal_certificate.scanned_certificate).not_to eq(nil)

    visit @path
    candidate = Candidate.find(@candidate.id)
    expect_baptismal_certificate_form(candidate.id, @dev, @path_str, @button_name, @is_verify, false, false, false)

    expect_db(1, 8, 1) # make sure DB does not increase in size.
  end

  scenario 'admin logs in and selects a candidate, unchecks baptized_at_home_parish, adds picture, updates, adds rest of valid data, updates - everything is saved' do
    @candidate.baptismal_certificate.baptized_at_home_parish = false
    @candidate.baptismal_certificate.first_comm_at_home_parish = false
    @candidate.baptismal_certificate.show_empty_radio = 2
    update_baptismal_certificate(true)
    @candidate.candidate_sheet.middle_name = ''
    @candidate.save

    visit @path
    attach_file(I18n.t('label.baptismal_certificate.baptismal_certificate.certificate_picture'), 'spec/fixtures/actions.png')
    click_button @update_id

    candidate = Candidate.find(@candidate.id)
    expect_baptismal_certificate_form(candidate.id, @dev, @path_str, @button_name, @is_verify, false, false, false,
                                      expect_messages: [[:flash_notice, @updated_failed_verification],
                                                        [:error_explanation, ['Your changes were saved!! 1 empty field needs to be filled in on the form to be verified:',
                                                                              'Middle name can\'t be blank']]])

    candidate = Candidate.find(@candidate.id)

    expect_baptismal_certificate_form(candidate.id, @dev, @path_str, @button_name, @is_verify, false, false, false, expected_messages: [[:flash_notice, @updated_message]])

    expect(candidate.get_candidate_event(BaptismalCertificate.event_key).verified).to eq(false), 'Baptismal certificate not verified.'
    expect(candidate.get_candidate_event(BaptismalCertificate.event_key).completed_date).to eq(Time.zone.today)

    expect(candidate.get_candidate_event(CandidateSheet.event_key).verified).to eq(false)
    expect(candidate.get_candidate_event(CandidateSheet.event_key).completed_date).to eq(nil)

    fill_in(I18n.t('label.candidate_sheet.middle_name'), with: MIDDLE_NAME)

    click_button @update_id

    if @is_verify

      expect_mass_edit_candidates_event(ConfirmationEvent.find_by(name: BaptismalCertificate.event_key), candidate.id, @updated_message)

    else
      expect_baptismal_certificate_form(candidate.id, @dev, @path_str, @button_name, @is_verify, false, false, false, expected_messages: [[:flash_notice, @updated_message]])
    end

    cand = Candidate.find_by(id: candidate.id)
    expect(cand.get_candidate_event(BaptismalCertificate.event_key).verified).to eq(@is_verify), 'Baptismal certificate not verified.'
    expect(cand.get_candidate_event(BaptismalCertificate.event_key).completed_date).to eq(Time.zone.today)

    # candidate_information_sheet if completed is automatically verified
    expect(cand.get_candidate_event(CandidateSheet.event_key).verified?).to eq(true)
    expect(cand.get_candidate_event(CandidateSheet.event_key).completed_date).to eq(Time.zone.today)
  end

  scenario 'admin logs in and selects a candidate, checks no for baptized_at_home_parish and updates' do
    @candidate.baptismal_certificate.baptized_at_home_parish = false
    @candidate.baptismal_certificate.first_comm_at_home_parish = false
    @candidate.baptismal_certificate.show_empty_radio = 1
    @candidate.save
    update_baptismal_certificate(false)

    visit @path

    click_button @update_id

    candidate = Candidate.find(@candidate.id)
    expect_baptismal_certificate_form(candidate.id, @dev, @path_str, @button_name, @is_verify, false, true, true,
                                      expect_messages: [[:flash_notice, @updated_failed_verification],
                                                        [:error_explanation, ['Your changes were saved!! 1 empty field needs to be filled in on the form to be verified:', 'I received First Communion at St. Mary Magdalene should be checked.']]])
  end

  scenario 'admin logs in and selects a candidate, unchecks baptized_at_home_parish, adds non-picture data, updates, adds picture, updates - everything is saved' do
    @candidate.baptismal_certificate.baptized_at_home_parish = false
    @candidate.baptismal_certificate.first_comm_at_home_parish = false
    @candidate.baptismal_certificate.show_empty_radio = 2
    @candidate.save
    update_baptismal_certificate(false)
    visit @path

    fill_in_form(false) # no picture
    click_button @update_id

    expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify, false, false, false,
                                      expect_messages: [[:flash_notice, @updated_failed_verification],
                                                        [:error_explanation, ['Your changes were saved!! 1 empty field needs to be filled in on the form to be verified:', 'Scanned baptismal certificate can\'t be blank']]])

    attach_file(I18n.t('label.baptismal_certificate.baptismal_certificate.certificate_picture'), 'spec/fixtures/actions.png')
    click_button @update_id

    candidate = Candidate.find(@candidate.id)
    if @is_verify

      expect_mass_edit_candidates_event(ConfirmationEvent.find_by(name: BaptismalCertificate.event_key), candidate.id, @updated_message)

    else

      expect_baptismal_certificate_form(candidate.id, @dev, @path_str, @button_name, @is_verify, false, false, false, expect_messages: [[:flash_notice, @updated_message]])

      expect(candidate.baptismal_certificate.baptized_at_home_parish).to eq(false)
      expect(candidate.baptismal_certificate).not_to eq(nil)
      expect(candidate.baptismal_certificate.scanned_certificate).not_to eq(nil)

    end

    visit @path
    candidate = Candidate.find(@candidate.id)
    expect_baptismal_certificate_form(candidate.id, @dev, @path_str, @button_name, @is_verify, false, false, false)
  end

  scenario 'admin un-verifies a verified baptized event' do
    expect(@is_verify == true || @is_verify == false).to eq(true)

    @candidate.baptismal_certificate.baptized_at_home_parish = true
    @candidate.baptismal_certificate.show_empty_radio = 1
    event_key = BaptismalCertificate.event_key
    @candidate.get_candidate_event(event_key).completed_date = @today
    @candidate.get_candidate_event(event_key).verified = true
    @candidate.save

    visit @path

    expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify, true, true, true)

    expect(page).to have_button(I18n.t('views.common.un_verify'), count: 2) if @is_verify
    click_button 'bottom-unverify' if @is_verify

    candidate = Candidate.find(@candidate.id)
    if @is_verify
      expect_mass_edit_candidates_event(ConfirmationEvent.find_by(name: event_key), candidate.id, I18n.t('messages.updated_unverified', cand_name: "#{candidate.candidate_sheet.first_name} #{candidate.candidate_sheet.last_name}"), true)
    else
      expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify, true, true, true)
    end

    expect(candidate.get_candidate_event(event_key).completed_date).to eq(@today)
    expect(candidate.get_candidate_event(event_key).verified).to eq(!@is_verify)
  end

  def expect_baptismal_certificate_form(cand_id, dev_path, path_str, button_name, is_verify, hide_first_comm, hide_baptismal_certificate, dont_show_values,
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
                                          mother_last: dont_show_values ? nil : LAST_NAME,

                                          first_name: dont_show_values ? nil : FIRST_NAME,
                                          middle_name: dont_show_values ? nil : MIDDLE_NAME,
                                          last_name: dont_show_values ? nil : LAST_NAME
                                        })

    expect_messages(values[:expect_messages]) unless values[:expect_messages].nil?

    cand = Candidate.find(cand_id)

    expect_heading(cand, dev_path.empty?, I18n.t('events.baptismal_certificate'))

    expect(page).to have_selector("form[id=edit_candidate][action=\"/#{dev_path}#{path_str}/#{cand_id}/baptismal_certificate\"]")
    expect(page).to have_selector('div', text: I18n.t('label.baptismal_certificate.baptismal_certificate.baptized_at_home_parish', home_parish: Visitor.home_parish))
    expect(page).to have_selector('div', text: I18n.t('label.baptismal_certificate.baptismal_certificate.first_comm_at_home_parish', home_parish: Visitor.home_parish))

    yes_id = 'candidate_baptismal_certificate_attributes_baptized_at_home_parish_1'
    no_id = 'candidate_baptismal_certificate_attributes_baptized_at_home_parish_0'
    expect(page).to have_selector("input[type=radio][id=#{yes_id}][value='1']", count: 1)
    expect(page).to have_selector("input[type=radio][id=#{no_id}][value='0']", count: 1)

    should_show_checked = cand.baptismal_certificate.show_empty_radio > 0
    yes_checked = should_show_checked && cand.baptismal_certificate.baptized_at_home_parish
    no_checked = should_show_checked && !cand.baptismal_certificate.baptized_at_home_parish

    if should_show_checked
      expect(find_field(yes_id)).to be_checked if yes_checked
      expect(find_field(no_id)).not_to be_checked if yes_checked

      expect(find_field(yes_id)).not_to be_checked if no_checked
      expect(find_field(no_id)).to be_checked if no_checked

    end

    fc_id_yes = 'candidate_baptismal_certificate_attributes_first_comm_at_home_parish_1'
    fc_id_no = 'candidate_baptismal_certificate_attributes_first_comm_at_home_parish_0'

    expect(page).to have_selector("input[type=radio][id=#{fc_id_yes}][value='1']", count: 1)
    expect(page).to have_selector("input[type=radio][id=#{fc_id_no}][value='0']", count: 1)

    should_show_fc_checked = !hide_first_comm && cand.baptismal_certificate.show_empty_radio > 1
    fc_yes_checked = should_show_checked && cand.baptismal_certificate.first_comm_at_home_parish
    fc_no_checked = should_show_checked && !cand.baptismal_certificate.first_comm_at_home_parish

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

    expect(page).to have_button(button_name, count: 2)
    remove_count = cand.baptismal_certificate.scanned_certificate.nil? ? 0 : 1
    expect_remove_button('candidate_baptismal_certificate_attributes_remove_certificate_picture', 'certificate_picture') unless cand.baptismal_certificate.scanned_certificate.nil?
    expect(page).to have_button(I18n.t('views.common.remove_image'), count: remove_count)
    expect(page).to have_button(I18n.t('views.common.replace_image'), count: remove_count)
    expect(page).to have_button(I18n.t('views.common.un_verify'), count: 2) if is_verify
    expect_download_button(Event::Document::BAPTISMAL_CERTIFICATE, cand_id, dev_path)
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

    fill_in(I18n.t('label.candidate_sheet.first_name'), with: FIRST_NAME)
    fill_in(I18n.t('label.candidate_sheet.middle_name'), with: MIDDLE_NAME)
    fill_in(I18n.t('label.candidate_sheet.last_name'), with: LAST_NAME)

    attach_file(I18n.t('label.baptismal_certificate.baptismal_certificate.certificate_picture'), 'spec/fixtures/actions.png') if attach_file
  end

  def img_src_selector
    "img[src=\"/#{@dev}event_with_picture_image/#{@candidate.id}/baptismal_certificate\"]"
  end

  def update_baptismal_certificate(with_values)
    baptismal_certificate = @candidate.baptismal_certificate

    candidate_sheet = @candidate.candidate_sheet
    candidate_sheet.middle_name = '' unless with_values
    candidate_sheet.attending = '' unless with_values

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

    candidate_sheet.first_name = FIRST_NAME
    candidate_sheet.middle_name = MIDDLE_NAME
    candidate_sheet.last_name = LAST_NAME
    @candidate.save
  end
end
