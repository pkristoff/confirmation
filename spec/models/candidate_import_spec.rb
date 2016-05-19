include ActionDispatch::TestProcess
describe CandidateImport do

  describe 'import excel spreadsheet' do

    it 'import spreadsheet will update database' do
      uploaded_file = fixture_file_upload('Small.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      candidate_import = CandidateImport.new(uploaded_file: uploaded_file)
      expect(candidate_import.save).to eq(true)

      expect(Candidate.all.size).to eq(4)
      candidate = Candidate.find_by_candidate_id('annunziatarobert')
      expect(candidate.first_name).to eq('Robert')
      expect(candidate.last_name).to eq('Annunziata')
      expect(candidate.grade).to eq(10)
      expect(candidate.attending).to eq('Catholic High School')
      expect(candidate.parent_email_1).to eq('lannunz@nc.rr.com')
      expect(candidate.parent_email_2).to eq('rannunz@nc.rr.com')

    end

    it 'import spreadsheet will update database' do
      uploaded_file = fixture_file_upload('Invalid.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      candidate_import = CandidateImport.new(uploaded_file: uploaded_file)
      expect(candidate_import.save).to eq(false)
      error_messages = [
          "Row 2: Last name can't be blank",
          "Row 3: First name can't be blank",
          "Row 6: Parent email 1 is an invalid email",
          "Row 6: Parent email 2 is an invalid email",
          "Row 7: Parent email 1 can't be blank"
      ]
      candidate_import.errors.each_with_index do | obj, index |
        expect(obj[1]).to eq(error_messages[index])

      end
      expect(candidate_import.errors.size).to eq(5)
    end
  end

  describe 'reset system back to original state' do

    it 'reset after adding in some candidates' do

      expect(Candidate.all.size).to eq(0)
      FactoryGirl.create(:candidate, candidate_id: 'a1')
      FactoryGirl.create(:candidate, candidate_id: 'a2')
      FactoryGirl.create(:candidate, candidate_id: 'a3')
      expect(Candidate.all.size).to eq(3)

      expect(Admin.all.size).to eq(0)
      FactoryGirl.create(:admin, email: 'paul@kristoffs.com', name: 'Paul')
      FactoryGirl.create(:admin, email: 'vicki@kristoffs.com', name: 'Vicki')
      expect(Admin.all.size).to eq(2)

      CandidateImport.new.reset_database

      expect(Candidate.all.size).to eq(1)
      expect(Candidate.find_by_candidate_id('vickikristoff')).not_to eq(nil)
      expect(Admin.all.size).to eq(1)
      expect(Admin.find_by_email('confirmation@kristoffs.com')).not_to eq(nil)

    end


  end

end
