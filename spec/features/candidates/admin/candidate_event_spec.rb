# frozen_string_literal: true

Warden.test_mode!

# Feature: Candidate edit
#   As a candidate
#   I want to edit my candidate profile
#   So I can change my email address
describe 'Candidate event', :devise do
  include Warden::Test::Helpers

  before do
    FactoryBot.create(:visitor)
    candidate = FactoryBot.create(:candidate)
    AppFactory.add_confirmation_events
    @candidate = Candidate.find(candidate.id)
    @admin = FactoryBot.create(:admin)
    login_as(@admin, scope: :admin)
  end

  after do
    Warden.test_reset!
  end

  it 'candidate changes email address' do
    visit event_candidate_path(@candidate.id)

    # if this fails then going to wrong controller
    expect(page).not_to have_selector('form[id=new_admin]')
    expect_confirmation_events(false)
  end

  it 'candidate changes email address - 2' do
    @candidate.candidate_sheet.attending = I18n.t('model.candidate.attending_catholic_high_school')
    @candidate.save
    visit event_candidate_path(@candidate.id)

    # if this fails then going to wrong controller
    expect(page).not_to have_selector('form[id=new_admin]')
    expect_confirmation_events(true)
  end

  private

  def expect_confirmation_events(is_chs)
    @candidate.candidate_events_sorted.each_with_index do |ce, index|
      conf_e = ce.confirmation_event
      expect_candidate_event(index,
                             conf_e.id,
                             conf_e.event_key,
                             (is_chs ? nil : conf_e.the_way_due_date),
                             (is_chs ? conf_e.chs_due_date : nil),
                             conf_e.instructions,
                             false,
                             '',
                             'fieldset')
    end
  end
end
