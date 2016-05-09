describe Candidate do

  before(:each) { @candidate = Candidate.new(email: 'candidate@example.com') }

  subject { @candidate }

  it "#email returns a string" do
    expect(@candidate.email).to match 'candidate@example.com'
  end

end
