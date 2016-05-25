include ActionDispatch::TestProcess
describe CandidateImport do

  describe 'import excel spreadsheet' do

    it 'import spreadsheet will update database' do
      uploaded_file = fixture_file_upload('Small.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      candidate_import = CandidateImport.new(uploaded_file: uploaded_file)
      expect(candidate_import.save).to eq(true)

      expect(Candidate.all.size).to eq(4)
      candidate = Candidate.find_by_account_name('annunziatarobert')
      expect(candidate.first_name).to eq('Robert')
      expect(candidate.last_name).to eq('Annunziata')
      expect(candidate.grade).to eq(10)
      expect(candidate.attending).to eq('Catholic High School')
      expect(candidate.parent_email_1).to eq('lannunz@nc.rr.com')
      expect(candidate.parent_email_2).to eq('rannunz@nc.rr.com')

    end

    it 'import invalid spreadsheet will not update database' do
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
      candidate_import.errors.each_with_index do |candidate, index|
        expect(candidate[1]).to eq(error_messages[index])
      end
      expect(candidate_import.errors.size).to eq(5)
    end

    it 'import spreadsheet from export will update database' do
      uploaded_file = fixture_file_upload('export_with_address.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      candidate_import = CandidateImport.new(uploaded_file: uploaded_file)

      expect(save candidate_import).to eq(true)

      expect(Candidate.all.size).to eq(2)
    end
  end

  def save candidate_import
    import_result = candidate_import.save
    candidate_import.errors.each_with_index do |candidate, index|
      puts "Errors:  #{candidate[1]}"
    end
    import_result
  end

  describe 'reset system back to original state' do

    it 'reset after adding in some candidates' do

      expect(Candidate.all.size).to eq(0)
      FactoryGirl.create(:candidate, account_name: 'a1')
      FactoryGirl.create(:candidate, account_name: 'a2')
      FactoryGirl.create(:candidate, account_name: 'a3')
      expect(Candidate.all.size).to eq(3)

      expect(Admin.all.size).to eq(0)
      FactoryGirl.create(:admin, email: 'paul@kristoffs.com', name: 'Paul')
      FactoryGirl.create(:admin, email: 'vicki@kristoffs.com', name: 'Vicki')
      expect(Admin.all.size).to eq(2)

      CandidateImport.new.reset_database

      expect(Candidate.all.size).to eq(1)
      expect(Candidate.find_by_account_name('vickikristoff')).not_to eq(nil)
      expect(Admin.all.size).to eq(1)
      expect(Admin.find_by_email('confirmation@kristoffs.com')).not_to eq(nil)

    end
  end

  describe 'export candidate to excel' do

    it 'reset after adding in some candidates' do

      c1 = FactoryGirl.create(:candidate,
                              account_name: 'c1',
                              parent_email_1: 'test@example.com',
                              candidate_email: 'candiate@example.com')
      c2 = FactoryGirl.create(:candidate, account_name: 'c2')
      c3 = FactoryGirl.create(:candidate, account_name: 'c3')

      candidate_import = CandidateImport.new
      package = candidate_import.create_xlsx_package

      package.workbook do |wb|
        wb.worksheets.each do |ws|
          expect(ws.name).to eq('Candidates with address')
          header_row = ws.rows[0]
          candidate_import.xlsx_columns.each_with_index do |column_name, index|
            expect(header_row.cells[index].value).to eq(column_name)
          end
          c1_row = ws.rows[1]
          expect(c1_row.cells[0].value).to eq('c1')
          expect(c1_row.cells[1].value).to eq('Sophia')
          expect(c1_row.cells[2].value).to eq('Agusta')
          expect(c1_row.cells[3].value).to eq('candiate@example.com')
          expect(c1_row.cells[4].value).to eq('test@example.com')
          expect(c1_row.cells[5].value).to eq('')
          expect(c1_row.cells[6].value).to eq(10)
          expect(c1_row.cells[7].value).to eq('The Way')
          expect(c1_row.cells[8].value).to eq('2120 Frissell Ave.')
          expect(c1_row.cells[9].value).to eq('Apt. 456')
          expect(c1_row.cells[10].value).to eq('Apex')
          expect(c1_row.cells[11].value).to eq('NC')
          expect(c1_row.cells[12].value).to eq(27502)

          c2_row = ws.rows[2]
          expect(c2_row.cells[0].value).to eq('c2')

          c3_row = ws.rows[3]
          expect(c3_row.cells[0].value).to eq('c3')
        end
      end

    end


  end

end
