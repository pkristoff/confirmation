describe Candidate do

  before(:each) { @candidate = Candidate.new(parent_email_1: 'candidate@example.com') }

  subject { @candidate }

  it '#email returns a string' do
    expect(@candidate.parent_email_1).to match 'candidate@example.com'
  end

end
