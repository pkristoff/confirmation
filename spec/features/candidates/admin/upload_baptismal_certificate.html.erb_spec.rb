include Warden::Test::Helpers
Warden.test_mode!

feature 'Baptismal Certificate', :devise do

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

  before(:each) do
    @candidate = FactoryGirl.create(:candidate)
    AppFactory.add_confirmation_event(I18n.t('events.upload_baptismal_certificate'))
    login_as(@candidate, scope: :candidate)
  end

  after(:each) do
    Warden.test_reset!
  end

  scenario 'candidate logs in, checks baptized_at_stmm, nothing else showing' do
    @candidate.baptized_at_stmm = true
    update_baptismal_certificate(false)
    visit dev_upload_baptismal_certificate_path(@candidate.id)
    expect_form_layout(@candidate)
  end

  scenario 'candidate logs in, unchecks baptized_at_stmm, rest showing' do
    @candidate.baptized_at_stmm = false
    update_baptismal_certificate(true)
    visit dev_upload_baptismal_certificate_path(@candidate.id)
    expect_form_layout(@candidate)
  end

  scenario 'candidate logs in, unchecks baptized_at_stmm, fills in template' do
    @candidate.baptized_at_stmm = false
    update_baptismal_certificate(false)
    visit dev_upload_baptismal_certificate_path(@candidate.id)
    fill_in_form
    click_button I18n.t('views.common.update')

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

  scenario 'candidate logs in, unchecks baptized_at_stmm, fills in template then changes mind she was baptized at stmm' do
    @candidate.baptized_at_stmm = false
    update_baptismal_certificate(false)
    visit dev_upload_baptismal_certificate_path(@candidate.id)
    fill_in_form
    click_button I18n.t('views.common.update')

    visit dev_upload_baptismal_certificate_path(@candidate.id)
    # puts page.html
    # expect(has_button? I18n.t('views.common.update'))
    check('Baptized at stmm')
    # puts page.html
    # expect(has_button? I18n.t('views.common.update'))
    click_button I18n.t('views.common.update')

    expect_message(:flash_notice, 'Updated')
    candidate = Candidate.find(@candidate.id)
    expect(candidate.baptized_at_stmm).to eq(true)
    expect(candidate.baptismal_certificate).to eq(nil)
  end

  scenario 'candidate logs in, unchecks baptized_at_stmm, adds picture, updates, adds rest of valid data, updates - everything is saved' do
    @candidate.baptized_at_stmm = false
    update_baptismal_certificate(false)
    visit dev_upload_baptismal_certificate_path(@candidate.id)
    attach_file('Certificate picture', 'spec/fixtures/actions.png')
    click_button I18n.t('views.common.update')

    fill_in_form(false) # no picture
    click_button I18n.t('views.common.update')

    expect_message(:flash_notice, 'Updated')
    candidate = Candidate.find(@candidate.id)
    expect(candidate.baptized_at_stmm).to eq(false)
    expect(candidate.baptismal_certificate).not_to eq(nil)
    expect(candidate.baptismal_certificate.certificate_filename).not_to eq(nil)

    visit dev_upload_baptismal_certificate_path(@candidate.id)
    candidate = Candidate.find(@candidate.id)
    expect_form_layout(candidate)

  end

  scenario 'candidate logs in, unchecks baptized_at_stmm, adds non-picture data, updates, adds picture, updates - everything is saved' do
    @candidate.baptized_at_stmm = false
    update_baptismal_certificate(false)
    visit dev_upload_baptismal_certificate_path(@candidate.id)

    fill_in_form(false) # no picture
    click_button I18n.t('views.common.update')
    expect_message(:flash_alert, I18n.t('messages.certificate_not_blank'))

    attach_file('Certificate picture', 'spec/fixtures/actions.png')
    click_button I18n.t('views.common.update')

    expect_message(:flash_notice, 'Updated')
    candidate = Candidate.find(@candidate.id)
    expect(candidate.baptized_at_stmm).to eq(false)
    expect(candidate.baptismal_certificate).not_to eq(nil)
    expect(candidate.baptismal_certificate.certificate_filename).not_to eq(nil)

    visit dev_upload_baptismal_certificate_path(@candidate.id)
    candidate = Candidate.find(@candidate.id)
    expect_form_layout(candidate)

  end

  scenario 'candidate logs in, unchecks baptized_at_stmm, fills in template, except street_1' do
    @candidate.baptized_at_stmm = false
    update_baptismal_certificate(false)
    visit dev_upload_baptismal_certificate_path(@candidate.id)
    fill_in_form
    fill_in('Street 1', with: nil)
    click_button I18n.t('views.common.update')

    expect_message(:error_explanation, '1 error prohibited saving: Church address street 1 can\'t be blank')
    candidate = Candidate.find(@candidate.id)
    expect_form_layout(candidate, '')
  end

  def expect_form_layout(candidate, street_1=STREET_1)
    visibility = candidate.baptized_at_stmm ? 'hide-div' : 'show-div'
    expect(page).to have_selector("form[id=edit_candidate][action=\"/upload_baptismal_certificate.#{@candidate.id}\"]")
    expect(page).to have_selector("div[id=baptismal-certificate-top][class=\"#{visibility}\"]")

    if candidate.baptized_at_stmm
      expect(page).to have_checked_field('Baptized at stmm')
    else
      expect(page).not_to have_checked_field('Baptized at stmm')
    end

    expect_field('Certificate picture', nil)

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
    attach_file('Certificate picture', 'spec/fixtures/actions.png') if attach_file
  end

  def update_baptismal_certificate(with_values)
    baptismal_certificate = BaptismalCertificate.new
    baptismal_certificate.church_address = Address.new
    @candidate.baptismal_certificate = baptismal_certificate
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
    end
  end

end
