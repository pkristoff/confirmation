include ActionDispatch::TestProcess
describe Candidate do

  it 'can retrieve a candiadate\'s address' do
    @candidate = FactoryGirl.create(:candidate)
    expect(@candidate.parent_email_1).to match 'test@example.com'
    expect(@candidate.address.street_1).to match '2120 Frissell Ave.'
    expect(@candidate.address.street_2).to match 'Apt. 456'
    expect(@candidate.address.city).to match 'Apex'
    expect(@candidate.address.state).to match 'NC'
    expect(@candidate.address.zip_code).to match '27502'
  end

  it 'can retrieve a new candiadate\'s address' do
    @candidate = Candidate.new_with_address
    expect(@candidate.parent_email_1).to match ''
    expect(@candidate.address.street_1).to match ''
    expect(@candidate.address.street_2).to match ''
    expect(@candidate.address.city).to match 'Apex'
    expect(@candidate.address.state).to match 'NC'
    expect(@candidate.address.zip_code).to match '27502'
  end

end
