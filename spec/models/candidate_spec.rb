include ActionDispatch::TestProcess
describe Candidate do

  before(:each) { @candidate = Candidate.new(parent_email_1: 'candidate@example.com') }

  subject { @candidate }

  it '#email returns a string' do
    expect(@candidate.parent_email_1).to match 'candidate@example.com'
  end

  describe 'import excel spreadsheet' do

    it 'import spreadsheet will update database' do
      uploaded_file = fixture_file_upload('Small.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      Candidate.import(uploaded_file)

      expect(Candidate.all.size).to eq(4)
      candidate = Candidate.find_by_candidate_id('annunziatarobert')
      expect(candidate.first_name).to eq('Robert')
      expect(candidate.last_name).to eq('Annunziata')
      expect(candidate.grade).to eq(10)
      expect(candidate.attending).to eq('Catholic High School')
      expect(candidate.parent_email_1).to eq('lannunz@nc.rr.com')
      expect(candidate.parent_email_2).to eq('rannunz@nc.rr.com')

    end
  end

end
