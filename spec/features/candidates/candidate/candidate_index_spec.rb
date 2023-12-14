# frozen_string_literal: true

Warden.test_mode!

# Feature: Candidate index page
#   As a candidate
#   I cannot see a list of candidates
describe 'Candidate index page', :devise do
  include Warden::Test::Helpers

  before do
    AppFactory.generate_default_status
  end

  after do
    Warden.test_reset!
  end

  it 'candidate cannot see list of candidates' do
    candidate = FactoryBot.create(:candidate)
    login_as(candidate, scope: :candidate)
    expect { dev_candidates_path }.to raise_error(NameError)
  end
end
