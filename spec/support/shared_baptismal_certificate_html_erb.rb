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
    event_with_picture_setup(I18n.t('events.baptismal_certificate'), Event::Route::BAPTISMAL_CERTIFICATE)
  end

  scenario 'admin logs in and selects a candidate, checks baptized_at_stmm, nothing else showing' do
    @candidate.baptized_at_stmm = true
    @candidate.save
    update_baptismal_certificate(false)
    visit @path
    expect_form_layout(@candidate)
  end

  scenario 'admin logs in and selects a candidate, unchecks baptized_at_stmm, rest showing' do
    @candidate.baptized_at_stmm = false
    @candidate.save
    update_baptismal_certificate(true)
    visit @path
    expect_form_layout(@candidate)
  end

  scenario 'admin logs in and selects a candidate, unchecks baptized_at_stmm, fills in template' do
    @candidate.baptized_at_stmm = false
    @candidate.save
    update_baptismal_certificate(false)
    expect(@candidate.baptized_at_stmm).to eq(false)
    visit @path
    fill_in_form
    click_button 'bottom-update'

    expect_message(:flash_notice, 'Updated')
    candidate = Candidate.find(@candidate.id)
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
  end

  scenario 'admin logs in and selects a candidate, unchecks baptized_at_stmm, fills in template then changes mind she was baptized at stmm' do
    @candidate.baptized_at_stmm = false
    @candidate.save
    update_baptismal_certificate(false)
    visit @path
    fill_in_form
    click_button 'bottom-update'

    visit @path

    check(I18n.t('label.baptismal_certificate.baptized_at_stmm'))

    click_button 'bottom-update'

    expect_message(:flash_notice, 'Updated')
    candidate = Candidate.find(@candidate.id)
    expect(candidate.baptized_at_stmm).to eq(true)
    expect(candidate.baptismal_certificate).not_to eq(nil) #always created now
  end

  scenario 'admin logs in and selects a candidate, unchecks baptized_at_stmm, adds picture, updates, adds rest of valid data, updates - everything is saved' do
    @candidate.baptized_at_stmm = false
    @candidate.save
    AppFactory.add_candidate_events(@candidate)
    update_baptismal_certificate(false)
    visit @path

    attach_file(I18n.t('label.baptismal_certificate.baptismal_certificate.certificate_picture'), 'spec/fixtures/actions.png')
    click_button 'bottom-update'

    expect(page).to have_selector(get_img_src_selector)

    fill_in_form(false) # no picture
    click_button 'bottom-update'

    expect_message(:flash_notice, 'Updated')
    candidate = Candidate.find(@candidate.id)
    expect(candidate.baptized_at_stmm).to eq(false)
    expect(candidate.baptismal_certificate).not_to eq(nil)
    expect(candidate.baptismal_certificate.certificate_filename).not_to eq(nil)

    visit @path
    candidate = Candidate.find(@candidate.id)
    expect_form_layout(candidate)

  end

  scenario 'admin logs in and selects a candidate, unchecks baptized_at_stmm, adds non-picture data, updates, adds picture, updates - everything is saved' do
    @candidate.baptized_at_stmm = false
    @candidate.save
    update_baptismal_certificate(false)
    visit @path

    fill_in_form(false) # no picture
    click_button 'bottom-update'
    expect_message(:error_explanation, ['3 empty fields need to be filled in:', 'Certificate filename can\'t be blank', 'Certificate content type can\'t be blank', 'Certificate file contents can\'t be blank'])
    expect(page).not_to have_selector(get_img_src_selector)

    attach_file(I18n.t('label.baptismal_certificate.baptismal_certificate.certificate_picture'), 'spec/fixtures/actions.png')
    click_button 'bottom-update'

    expect_message(:flash_notice, 'Updated')
    candidate = Candidate.find(@candidate.id)
    expect(candidate.baptized_at_stmm).to eq(false)
    expect(candidate.baptismal_certificate).not_to eq(nil)
    expect(candidate.baptismal_certificate.certificate_filename).not_to eq(nil)

    visit @path
    candidate = Candidate.find(@candidate.id)
    expect_form_layout(candidate)

  end

  scenario 'admin logs in and selects a candidate, unchecks baptized_at_stmm, fills in template, except street_1' do
    @candidate.baptized_at_stmm = false
    @candidate.save
    update_baptismal_certificate(false)
    visit @path
    fill_in_form
    fill_in('Street 1', with: nil)
    click_button 'bottom-update'

    expect_message(:error_explanation, '1 empty field need to be filled in: Street 1 can\'t be blank')
    expect(page).to have_selector(get_img_src_selector)
    candidate = Candidate.find(@candidate.id)
    expect_form_layout(candidate, '')
  end

  def expect_form_layout(candidate, street_1=STREET_1)
    visibility = candidate.baptized_at_stmm ? 'hide-div' : 'show-div'
    expect(page).to have_selector("form[id=edit_candidate][action=\"/#{@dev}event_with_picture/#{@candidate.id}/baptismal_certificate\"]")
    expect(page).to have_selector("div[id=baptismal-certificate-top][class=\"#{visibility}\"]")

    if candidate.baptized_at_stmm
      expect(page).to have_checked_field(I18n.t('label.baptismal_certificate.baptized_at_stmm'))
    else
      expect(page).not_to have_checked_field(I18n.t('label.baptismal_certificate.baptized_at_stmm'))
    end

    expect_field(I18n.t('label.baptismal_certificate.baptismal_certificate.certificate_picture'), nil)

    expect_field('Birth date', candidate.baptized_at_stmm ? nil : BIRTH_DATE)
    expect_field('Baptismal date', candidate.baptized_at_stmm ? nil : BAPTISMAL_DATE)

    expect_field('Church name', candidate.baptized_at_stmm ? nil : CHURCH_NAME)
    expect_field('Street 1', candidate.baptized_at_stmm ? nil : street_1)
    expect_field('Street 2', candidate.baptized_at_stmm ? nil : STREET_2)
    expect_field('City', candidate.baptized_at_stmm ? nil : CITY)
    expect_field('State', candidate.baptized_at_stmm ? nil : STATE)
    expect_field('Zip code', candidate.baptized_at_stmm ? nil : ZIP_CODE)

    expect_field('Father first', candidate.baptized_at_stmm ? nil : FATHER_FIRST)
    expect_field('Father middle', candidate.baptized_at_stmm ? nil : FATHER_MIDDLE)
    expect_field('Father last', candidate.baptized_at_stmm ? nil : LAST_NAME)

    expect_field('Mother first', candidate.baptized_at_stmm ? nil : MOTHER_FIRST)
    expect_field('Mother middle', candidate.baptized_at_stmm ? nil : MOTHER_MIDDLE)
    expect_field('Mother maiden', candidate.baptized_at_stmm ? nil : MOTHER_MAIDEN)
    expect_field('Mother last', candidate.baptized_at_stmm ? nil : LAST_NAME)

    expect(page).to have_button(I18n.t('views.common.update'))
    expect_download_button(Event::Document::BAPTISMAL_CERTIFICATE)
  end

  def expect_field (label, value)
    if value.nil? or value === ''
      expect(page).to have_field(label)
    else
      expect(page).to have_field(label, with: value)
    end
  end

  def fill_in_form(attach_file=true)
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

  def get_img_src_selector
    "img[src=\"/#{@dev}event_with_picture_image/#{@candidate.id}/baptismal_certificate\"]"
  end

  def update_baptismal_certificate(with_values)
    baptismal_certificate = @candidate.baptismal_certificate
    # baptismal_certificate.church_address = Address.new
    # @candidate.baptismal_certificate = baptismal_certificate
    if with_values
      baptismal_certificate.birth_date=Date.parse(BIRTH_DATE)
      baptismal_certificate.baptismal_date=Date.parse(BAPTISMAL_DATE)

      baptismal_certificate.church_name=CHURCH_NAME
      baptismal_certificate.church_address.street_1=STREET_1
      baptismal_certificate.church_address.street_2=STREET_2
      baptismal_certificate.church_address.city=CITY
      baptismal_certificate.church_address.state=STATE
      baptismal_certificate.church_address.zip_code=ZIP_CODE

      baptismal_certificate.father_first=FATHER_FIRST
      baptismal_certificate.father_middle=FATHER_MIDDLE
      baptismal_certificate.father_last=LAST_NAME

      baptismal_certificate.mother_first=MOTHER_FIRST
      baptismal_certificate.mother_middle=MOTHER_MIDDLE
      baptismal_certificate.mother_maiden=MOTHER_MAIDEN
      baptismal_certificate.mother_last=LAST_NAME
      @candidate.save
    end
  end
end