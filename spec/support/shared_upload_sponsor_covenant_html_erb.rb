SPONSOR_NAME = 'George Sponsor'
SPONSOR_CHURCH = 'St. George'

shared_context 'upload_sponsor_covenant_html_erb' do

  scenario 'admin logs in and selects a candidate, checks sponsor_attends_stmm, nothing else showing' do
    @candidate.sponsor_covenant.sponsor_attends_stmm = true
    @candidate.save
    update_sponsor_covenant(false)
    visit @path
    expect_form_layout(@candidate)
  end

  scenario 'admin logs in and selects a candidate, unchecks sponsor_attends_stmm, rest showing' do
    @candidate.sponsor_covenant.sponsor_attends_stmm = false
    @candidate.save
    update_sponsor_covenant(true)
    visit @path
    expect_form_layout(@candidate)
  end

  scenario 'admin logs in and selects a candidate, unchecks sponsor_attends_stmm, fills in template' do
    @candidate.sponsor_covenant.sponsor_attends_stmm = false
    @candidate.save
    update_sponsor_covenant(false)
    expect(@candidate.sponsor_covenant.sponsor_attends_stmm).to eq(false)
    visit @path
    fill_in_form(true, true)
    click_button I18n.t('views.common.update')

    expect_message(:flash_notice, 'Updated')
    candidate = Candidate.find(@candidate.id)
    expect(candidate.sponsor_covenant.sponsor_name).to eq(SPONSOR_NAME)
    expect(candidate.sponsor_covenant.sponsor_church).to eq(SPONSOR_CHURCH)
  end

  scenario 'admin logs in and selects a candidate, unchecks sponsor_attends_stmm, fills in template then changes mind she was baptized at stmm' do
    @candidate.sponsor_covenant.sponsor_attends_stmm = false
    @candidate.save
    update_sponsor_covenant(false)
    visit @path
    fill_in_form
    click_button I18n.t('views.common.update')

    visit @path
    check('Sponsor attends stmm')
    click_button I18n.t('views.common.update')

    expect_message(:flash_notice, I18n.t('messages.updated'))
    candidate = Candidate.find(@candidate.id)
    expect(candidate.sponsor_covenant.sponsor_attends_stmm).to eq(true)
    expect(candidate.sponsor_covenant).not_to eq(nil)
  end

  scenario 'admin logs in and selects a candidate, unchecks sponsor_attends_stmm, adds picture, updates, adds rest of valid data, updates - everything is saved' do
    @candidate.sponsor_covenant.sponsor_attends_stmm = false
    # @candidate.create_baptismal_certificate
    # @candidate.baptismal_certificate.create_church_address
    @candidate.save
    AppFactory.add_candidate_events(@candidate)
    update_sponsor_covenant(false)
    visit @path


    attach_file('Sponsor covenant picture', 'spec/fixtures/actions.png')
    attach_file('Sponsor elegibility picture', 'spec/fixtures/actions.png')
    click_button I18n.t('views.common.update')

    candidate = Candidate.find(@candidate.id)
    expect_message(:error_explanation, ['2 errors prohibited saving', 'Sponsor name can\'t be blank', 'Sponsor church can\'t be blank'])
    expect(candidate.sponsor_covenant).not_to eq(nil)
    expect(candidate.sponsor_covenant.sponsor_attends_stmm).to eq(false)
    expect(candidate.sponsor_covenant.sponsor_elegibility_filename).to eq('actions.png')
    expect(candidate.sponsor_covenant.sponsor_covenant_filename).to eq('actions.png')
    expect(candidate.sponsor_covenant.sponsor_name).to eq('')
    expect(candidate.sponsor_covenant.sponsor_church).to eq('')

    fill_in_form(false) # no picture
    click_button I18n.t('views.common.update')

    expect_message(:flash_notice, I18n.t('messages.updated'))
    candidate = Candidate.find(@candidate.id)
    expect(candidate.sponsor_covenant).not_to eq(nil)
    expect(candidate.sponsor_covenant.sponsor_attends_stmm).to eq(false)
    expect(candidate.sponsor_covenant.sponsor_elegibility_filename).to eq('Baptismal Certificate.png')
    expect(candidate.sponsor_covenant.sponsor_covenant_filename).to eq('actions.png')
    expect(candidate.sponsor_covenant.sponsor_name).to eq(SPONSOR_NAME)
    expect(candidate.sponsor_covenant.sponsor_church).to eq(SPONSOR_CHURCH)

    visit @path
    candidate = Candidate.find(@candidate.id)
    expect_form_layout(candidate)

  end

  scenario 'admin logs in and selects a candidate, unchecks sponsor_attends_stmm, adds non-picture data, updates, adds picture, updates - everything is saved' do
    @candidate.sponsor_covenant.sponsor_attends_stmm = false
    @candidate.save
    update_sponsor_covenant(false)
    visit @path

    fill_in_form(false) # no picture
    click_button I18n.t('views.common.update')
    expect_message(:error_explanation, ['3 errors prohibited saving', 'Sponsor elegibility filename can\'t be blank', 'Sponsor elegibility content type can\'t be blank', 'Sponsor elegibility file contents can\'t be blank'])

    expect(page).not_to have_selector(get_img_src_selector)
    expect(page).to have_selector("img[src=\"/#{@dev}upload_sponsor_elegibility_image.#{@candidate.id}\"]")

    attach_file('Sponsor covenant picture', 'spec/fixtures/actions.png')
    click_button I18n.t('views.common.update')

    expect_message(:flash_notice, 'Updated')
    candidate = Candidate.find(@candidate.id)
    expect(candidate.sponsor_covenant.sponsor_attends_stmm).to eq(false)
    expect(candidate.sponsor_covenant).not_to eq(nil)
    expect(candidate.sponsor_covenant.sponsor_elegibility_filename).not_to eq(nil)

    visit @path
    candidate = Candidate.find(@candidate.id)
    expect_form_layout(candidate)

  end

  scenario 'admin logs in and selects a candidate, unchecks sponsor_attends_stmm, fills in template, except sponsor_name' do
    @candidate.sponsor_covenant.sponsor_attends_stmm = false
    @candidate.save
    update_sponsor_covenant(false)
    visit @path
    fill_in_form
    fill_in('Sponsor name', with: nil)
    click_button I18n.t('views.common.update')

    expect_message(:error_explanation, '1 error prohibited saving: Sponsor name can\'t be blank')
    expect(page).to have_selector(get_img_src_selector)
    candidate = Candidate.find(@candidate.id)
    expect_form_layout(candidate, '')
  end

  def expect_form_layout(candidate, sponsor_name=SPONSOR_NAME)
    visibility = candidate.sponsor_covenant.sponsor_attends_stmm ? 'hide-div' : 'show-div'
    expect(page).to have_selector("form[id=edit_candidate][action=\"/#{@dev}event_with_picture/#{@candidate.id}/upload_sponsor_covenant\"]")
    expect(page).to have_selector("div[id=sponsor-covenant-top][class=\"#{visibility}\"]")

    if candidate.sponsor_covenant.sponsor_attends_stmm
      expect(page).to have_checked_field('Sponsor attends stmm')
    else
      expect(page).not_to have_checked_field('Sponsor attends stmm')
    end

    expect_field('Sponsor covenant picture', nil)

    expect_field('Sponsor name', candidate.sponsor_covenant.sponsor_attends_stmm ? nil : sponsor_name)

    expect(page).to have_button(I18n.t('views.common.update'))
    expect(page).to have_button(I18n.t('views.common.download'))
  end

  def expect_field (label, value)
    if value.nil? or value === ''
      expect(page).to have_field(label)
    else
      expect(page).to have_field(label, with: value)
    end
  end

  def fill_in_form(covenant_attach_file=true, elegibility_attach_file=true)
    fill_in('Sponsor name', with: SPONSOR_NAME)
    fill_in('Sponsor church', with: SPONSOR_CHURCH)
    if covenant_attach_file
      attach_file('Sponsor covenant picture', 'spec/fixtures/actions.png')
    end
    if elegibility_attach_file
      attach_file('Sponsor elegibility picture', 'spec/fixtures/Baptismal Certificate.png')
    end
  end

  def get_img_src_selector
    "img[src=\"/#{@dev}event_with_picture_image/#{@candidate.id}/upload_sponsor_covenant\"]"
  end

  def update_sponsor_covenant(with_values)
    if with_values
      @candidate.sponsor_covenant.sponsor_name=SPONSOR_NAME
      @candidate.save
    end
  end
end