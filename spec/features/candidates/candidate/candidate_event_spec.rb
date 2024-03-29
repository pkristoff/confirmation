# frozen_string_literal: true

Warden.test_mode!

# Feature: Candidate edit
#   As a candidate
#   I want to edit my candidate profile
#   So I can change my email address
describe 'Candidate event', :devise do
  include Warden::Test::Helpers

  before do
    AppFactory.generate_default_status
    candidate = FactoryBot.create(:candidate)
    AppFactory.add_confirmation_events
    @candidate = Candidate.find(candidate.id)
    login_as(@candidate, scope: :candidate)
  end

  after do
    Warden.test_reset!
  end

  it 'candidate changes email address - 2' do
    visit event_candidate_registration_path(@candidate.id)

    # if this passes then going to wrong controller
    expect(page).not_to have_selector('form[id=new_admin]')

    expect_confirmation_events(false)
  end

  it 'candidate changes email address - 3' do
    @candidate.candidate_sheet.attending = I18n.t('model.candidate.attending_catholic_high_school')
    @candidate.save
    visit event_candidate_registration_path(@candidate.id)

    # if this passes then going to wrong controller
    expect(page).not_to have_selector('form[id=new_admin]')

    expect_confirmation_events(true)
  end

  private

  def expect_confirmation_events(is_chs)
    ConfirmationEvent.all.each_with_index do |ce, index|
      expect_candidate_event(index + 3,
                             ce.id,
                             ce.event_key,
                             (is_chs ? nil : ce.the_way_due_date),
                             (is_chs ? ce.chs_due_date : nil),
                             ce.instructions,
                             false,
                             '',
                             'div')
    end
  end
end
