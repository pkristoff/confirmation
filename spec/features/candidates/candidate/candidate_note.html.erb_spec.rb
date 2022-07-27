# frozen_string_literal: true

Warden.test_mode!

feature 'Candidate sheet candidate', :devise do
  include Warden::Test::Helpers

  before do
    FactoryBot.create(:visitor)
  end

  before(:each) do
    @cand_id = FactoryBot.create(:candidate).id
    admin = FactoryBot.create(:admin)
    login_as(admin, scope: :admin)

    @path = candidate_note_path(@cand_id)

    @path_str = 'candidate_note'
    @update_id = 'top-update'
    cand_name = 'Sophia Augusta'
    @updated_message = I18n.t('messages.updated', cand_name: cand_name)
    @updated_failed_verification = I18n.t('messages.updated', cand_name: cand_name)
    @is_verify = false
  end

  after(:each) do
    Warden.test_reset!
  end

  scenario 'admin logs in, selects candidate note' do
    cand = Candidate.find(@cand_id)
    cand.candidate_sheet.candidate_email = 'm'
    cand.save(validate: false)

    visit @path

    expect_candidate_note_form(@cand_id, @path_str, @update_id)
  end

  scenario 'admin logs in, selects candidate note, changes it and saves' do
    cand = Candidate.find(@cand_id)
    cand.candidate_sheet.candidate_email = 'm'
    cand.save(validate: false)

    visit @path

    updated_text = 'The new admin message'
    fill_in I18n.t('label.candidate_note.note'), with: updated_text

    click_button @update_id

    candidate = Candidate.find(@cand_id)

    expect(candidate.candidate_note).to eq(updated_text)

    expect_candidate_note_form(@cand_id,
                               @path_str,
                               @update_id,
                               text_area_text: updated_text,
                               expected_messages: [[:flash_notice, @updated_message]])
  end

  private

  def expect_candidate_note_form(cand_id, path_str, update_id, values = {})
    cand = Candidate.find(cand_id)
    expect_messages(values[:expected_messages]) unless values[:expecteded_messages].nil?
    expected_text = values[:text_area_text].nil? ? 'Admin note' : values[:text_area_text]

    expect_heading(cand, I18n.t('label.sidebar.candidate_note'))

    expect(page).to have_selector("form[id=edit_candidate][action=\"/#{path_str}.#{cand_id}\"]")

    expect(page).to have_field(I18n.t('label.candidate_note.note'),
                               with: cand.candidate_note, type: 'textarea', text: expected_text)

    expect(page).to have_button(update_id)
  end

  def expect_heading(cand, event_name)
    first = cand.candidate_sheet.first_name
    last = cand.candidate_sheet.last_name

    expect(page).to have_selector('h2[id=heading]',
                                  text: I18n.t('views.events.heading',
                                               event_name: event_name, first: first, last: last))
  end
end
