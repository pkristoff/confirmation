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
    program_year = 1
    @candidate.candidate_sheet.program_year = program_year
    @candidate.save
    visit event_candidate_registration_path(@candidate.id)

    # if this passes then going to wrong controller
    expect(page).not_to have_selector('form[id=new_admin]')

    expect_confirmation_events(program_year)
  end

  private

  def expect_confirmation_events(program_year)
    ConfirmationEvent.all.each_with_index do |ce, index|
      expect_candidate_event(index + 3,
                             ce.id,
                             ce.event_key,
                             (program_year == 2 ? nil : ce.program_year1_due_date),
                             (program_year == 2 ? ce.program_year2_due_date : nil),
                             ce.instructions,
                             false,
                             '',
                             'div')
    end
  end
end
