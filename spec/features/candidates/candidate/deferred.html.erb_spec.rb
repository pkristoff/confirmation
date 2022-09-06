# frozen_string_literal: true

Warden.test_mode!

describe 'Candidate sheet candidate', :devise do
  include Warden::Test::Helpers

  before do
    FactoryBot.create(:visitor)
    @cand_id = FactoryBot.create(:candidate).id
    admin = FactoryBot.create(:admin)
    login_as(admin, scope: :admin)

    @path = deferred_path(@cand_id)

    @path_str = 'deferred'
    @update_id = 'top-update'
    cand_name = 'Sophia Augusta'
    @updated_message = I18n.t('messages.updated', cand_name: cand_name)
    @updated_failed_verification = I18n.t('messages.updated', cand_name: cand_name)
    @is_verify = false
  end

  after do
    Warden.test_reset!
  end

  it 'admin logs in, selects deferred' do
    cand = Candidate.find(@cand_id)
    cand.candidate_sheet.candidate_email = 'm'
    cand.save(validate: false)

    visit @path

    expect_deferred_form(@cand_id, @path_str, @update_id)
  end

  it 'admin logs in, selects candidate note, changes it and saves' do
    cand = Candidate.find(@cand_id)
    cand.candidate_sheet.candidate_email = 'm'
    cand.save(validate: false)

    visit @path

    expect_deferred_form(@cand_id,
                         @path_str,
                         @update_id,
                         deferred: false)

    check(I18n.t('activerecord.attributes.candidate.deferred'))

    click_button @update_id

    candidate = Candidate.find(@cand_id)

    expect(candidate.deferred).to be(true)

    expect_deferred_form(@cand_id,
                         @path_str,
                         @update_id,
                         deferred: true,
                         expected_messages: [[:flash_notice, @updated_message]])
  end

  private

  def expect_deferred_form(cand_id, path_str, update_id, values = {})
    cand = Candidate.find(cand_id)
    expect_messages(values[:expected_messages]) unless values[:expecteded_messages].nil?
    deferred_value = values[:deferred].nil? ? false : values[:deferred]

    expect_heading(cand, I18n.t('label.sidebar.deferred'))

    expect(page).to have_selector("form[id=edit_candidate][action=\"/#{path_str}.#{cand_id}\"]")

    expect(page).to have_field(I18n.t('activerecord.attributes.candidate.deferred'), type: 'checkbox')
    expect(page).to have_unchecked_field(I18n.t('activerecord.attributes.candidate.deferred')) unless deferred_value
    expect(page).to have_checked_field(I18n.t('activerecord.attributes.candidate.deferred')) if deferred_value

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
