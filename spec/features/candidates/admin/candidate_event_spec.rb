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
    program_year = 1
    @candidate.candidate_sheet.program_year = program_year
    @candidate.save
    visit event_candidate_path(@candidate.id)

    # if this fails then going to wrong controller
    expect(page).not_to have_selector('form[id=new_admin]')
    expect_confirmation_events(program_year)
  end

  it 'candidate changes email address - 2' do
    program_year = 2
    @candidate.candidate_sheet.program_year = program_year
    @candidate.save
    visit event_candidate_path(@candidate.id)

    # if this fails then going to wrong controller
    expect(page).not_to have_selector('form[id=new_admin]')
    expect_confirmation_events(program_year)
  end

  private

  def expect_confirmation_events(program_year)
    @candidate.candidate_events_sorted.each_with_index do |ce, index|
      conf_e = ce.confirmation_event
      expect_candidate_event(index,
                             conf_e.id,
                             conf_e.event_key,
                             (program_year == 2 ? nil : conf_e.program_year1_due_date),
                             (program_year == 2 ? conf_e.program_year2_due_date : nil),
                             conf_e.instructions,
                             false,
                             '',
                             'fieldset')
    end
  end
end
