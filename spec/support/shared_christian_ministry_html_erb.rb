require_relative "helpers/sorting_cand_list_helper.rb"
include SortingCandListHelpers

WHAT_SERVICE = '9am mass'
WHERE_SERVICE = 'Over there'
WHEN_SERVICE = 'Yesterday'
HELPED_ME = 'look better'


shared_context 'christian_ministry_html_erb' do

  before(:each) do
    AppFactory.add_confirmation_events
    @candidate = Candidate.find_by_account_name(@candidate.account_name)
    @admin_verified = @updated_message === I18n.t('messages.updated_verified')

  end

  scenario 'admin logs in and selects a candidate, nothing else showing' do
    update_christian_ministry(false)
    visit @path

    expect_christian_ministry_form(@candidate, @path_str, @dev, @update_id,
                                   what_service: '', where_service: '',
                                   when_service: '', helped_me: '')
  end

  scenario 'admin logs in and selects a candidate, fills in template and no picture' do
    update_christian_ministry(false)

    expect_db(1, 9, 0)
    visit @path

    fill_in_form
    click_button @update_id

    candidate = Candidate.find(@candidate.id)

    if @admin_verified

      expect_mass_edit_candidates_event(ConfirmationEvent.find_by_name(I18n.t('events.christian_ministry')), candidate, @updated_message)

    else

      expect_christian_ministry_form(candidate, @path_str, @dev, @update_id,
                                     what_service: WHAT_SERVICE, where_service: WHERE_SERVICE,
                                     when_service: WHEN_SERVICE, helped_me: HELPED_ME,
                                     expect_messages: [[:flash_notice, @updated_message]]
      )
    end

    expect(candidate.get_candidate_event(I18n.t('events.christian_ministry')).completed_date).to eq(Date.today)
    expect(candidate.get_candidate_event(I18n.t('events.christian_ministry')).verified).to eq(true)

    visit @path
    candidate = Candidate.find(@candidate.id)
    expect_christian_ministry_form(candidate, @path_str, @dev, @update_id,
                                   what_service: '', where_service: WHERE_SERVICE,
                                   when_service: WHEN_SERVICE, helped_me: HELPED_ME)

    expect_db(1, 9, 0) #make sure DB does not increase in size.
  end

  scenario 'admin logs in and selects a candidate, fills in template and picture' do
    update_christian_ministry(false)

    expect_db(1, 9, 0)

    visit @path
    fill_in_form
    click_button @update_id

    expect_message(:flash_notice, I18n.t('messages.updated'))
    candidate = Candidate.find(@candidate.id)


    if @admin_verified

      expect_mass_edit_candidates_event(ConfirmationEvent.find_by_name(I18n.t('events.christian_ministry')), candidate, @updated_message)

    else

      expect_christian_ministry_form(candidate, @path_str, @dev, @update_id,
                                     what_service: WHAT_SERVICE, where_service: WHERE_SERVICE,
                                     when_service: WHEN_SERVICE, helped_me: HELPED_ME,
                                     expect_messages: [[:flash_notice, @updated_message]]
      )
    end

    expect(candidate.get_candidate_event(I18n.t('events.christian_ministry')).completed_date).to eq(Date.today)
    expect(candidate.get_candidate_event(I18n.t('events.christian_ministry')).verified).to eq(true)

    visit @path
    candidate = Candidate.find(@candidate.id)
    expect_christian_ministry_form(candidate, @path_str, @dev, @update_id,
                                   what_service: '', where_service: WHERE_SERVICE,
                                   when_service: WHEN_SERVICE, helped_me: HELPED_ME)

    expect_db(1, 9, 0) #make sure DB does not increase in size.
  end

  scenario 'admin logs in and selects a candidate, adds picture, updates, updates - everything is saved' do
    candidate = Candidate.find(@candidate.id)
    candidate.save
    update_christian_ministry(false)

    expect_db(1, 9, 0)
    visit @path

    click_button @update_id

    candidate = Candidate.find(@candidate.id)
    expect_christian_ministry_form(candidate, @path_str, @dev, @update_id,
                                   what_service: '', where_service: '',
                                   when_service: '', helped_me: '',
                                   expect_messages: [[:flash_notice, @updated_failed_verification],
                                                     [:error_explanation, 'Your changes were saved!! 4 empty fields need to be filled in on the form to be verfied: What service can\'t be blank Where service can\'t be blank When service can\'t be blank Helped me can\'t be blank']
                                   ]
    )

    expect(candidate.get_candidate_event(I18n.t('events.christian_ministry')).completed_date).to eq(nil)
    expect(candidate.get_candidate_event(I18n.t('events.christian_ministry')).verified).to eq(false)

    visit @path
    candidate = Candidate.find(@candidate.id)
    expect_christian_ministry_form(candidate, @path_str, @dev, @update_id,
                                   what_service: '', where_service: '',
                                   when_service: '', helped_me: '')

    expect_db(1, 9, 0) #make sure DB does not increase in size.

  end

  scenario 'admin logs in and selects a candidate, fills in template, except saint_name' do

    update_christian_ministry(false)

    expect_db(1, 9, 0)

    visit @path
    fill_in_form
    fill_in(I18n.t('label.christian_ministry.what_service'), with: nil)
    click_button @update_id

    candidate = Candidate.find(@candidate.id)
    expect_christian_ministry_form(candidate, @path_str, @dev, @update_id,
                                   what_service: '', where_service: WHERE_SERVICE,
                                   when_service: WHEN_SERVICE, helped_me: HELPED_ME,
                                   expect_messages: [[:flash_notice, @updated_failed_verification],
                                                     [:error_explanation, 'Your changes were saved!! 1 empty field needs to be filled in on the form to be verfied: What service can\'t be blank']
                                   ]
    )

    expect_db(1, 9, 0) #make sure DB does not increase in size.
  end

  def expect_field (label, value)
    if value.nil? or value === ''
      expect(page).to have_field(label)
    else
      expect(page).to have_field(label, with: value)
    end
  end

  def fill_in_form
    fill_in(I18n.t('label.christian_ministry.what_service'), with: WHAT_SERVICE)
    fill_in(I18n.t('label.christian_ministry.where_service'), with: WHERE_SERVICE)
    fill_in(I18n.t('label.christian_ministry.when_service'), with: WHEN_SERVICE)
    fill_in(I18n.t('label.christian_ministry.helped_me'), with: HELPED_ME)
  end

  def img_src_selector
    "img[src=\"/#{@dev}event_with_picture_image/#{@candidate.id}/christian_ministry\"]"
  end

  def update_christian_ministry(with_values)
    if with_values
      @candidate.christian_ministry.what_service = WHAT_SERVICE
      @candidate.save
    end
  end
end