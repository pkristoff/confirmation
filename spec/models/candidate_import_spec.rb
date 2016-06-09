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
          'Row 2: Last name can\'t be blank',
          'Row 3: First name can\'t be blank',
          'Row 6: Parent email 1 is an invalid email',
          'Row 6: Parent email 2 is an invalid email',
          'Row 7: Parent email 1 can\'t be blank'
      ]
      candidate_import.errors.each_with_index do |candidate, index|
        expect(candidate[1]).to eq(error_messages[index])
      end
      expect(candidate_import.errors.size).to eq(5)
    end

    it 'import spreadsheet from export will update database' do
      uploaded_file = fixture_file_upload('export_with_events.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      candidate_import = CandidateImport.new(uploaded_file: uploaded_file)

      expect(save candidate_import).to eq(true)

      expect_import_with_events
    end
  end

  def get_foo_bar
    {
        account_name: 'foobar',
        first_name: 'foo',
        last_name: 'bar',
        candidate_email: '',
        parent_email_1: 'foo@bar.com',
        parent_email_2: '',
        grade: 10,
        attending: 'The Way',
        address: {
            street_1: '',
            street_2: 'street 2',
            city: 'Clarksville',
            state: 'IN',
            zip_code: '47129'
        },
        candidate_events: [
            {completed_date: '',
             verified: ''},
            {completed_date: '',
             verified: ''}
        ]
    }
  end

  def get_paul_kristoff
    {
        account_name: 'paulkristoff',
        first_name: 'Paul',
        last_name: 'Kristoff',
        candidate_email: 'paul@kristoffs.com',
        parent_email_1: 'vicki@kristoffs.com',
        parent_email_2: 'vicki@kristoffs.com',
        grade: 9,
        attending: 'The Way',
        address: {
            street_1: '2116 Frissell Ave',
            street_2: '',
            city: 'Cary',
            state: 'NC',
            zip_code: '27555'
        },
        candidate_events: [
            {completed_date: '',
             verified: false},
            {completed_date: '2016-05-02',
             verified: true}
        ]
    }
  end

  def get_vicki_kristoff
    {
        account_name: 'vickikristoff',
        first_name: 'Vicki',
        last_name: 'Kristoff',
        candidate_email: 'vicki@kristoffs.com',
        parent_email_1: 'paul@kristoffs.com',
        parent_email_2: 'paul@kristoffs.com',
        grade: 12,
        attending: 'Catholic High School',
        address: {
            street_1: '2120 Frissell Ave',
            street_2: '',
            city: 'Apex',
            state: 'NC',
            zip_code: '27502'
        },
        candidate_events: [
            {completed_date: '2016-06-06',
             verified: true},
            {completed_date: '',
             verified: false}
        ]
    }
  end

  def expect_candidate (values)
    candidate = Candidate.find_by_account_name(values[:account_name])
    values.keys.each do |key|
      value = values[key]
      if value.is_a? Hash
        candidate_sub = candidate.send(key)
        expect_keys(candidate_sub, value)
      elsif value.is_a? Array
        candidate_subs = candidate.send(key)
        value.each_with_index do |sub_values, index|
          expect_keys(candidate_subs[index], sub_values)
        end
      else
        expect(candidate.send(key)).to eq(value)
      end
    end
  end

  def expect_keys(obj, attributes)
    attributes.keys.each do |sub_key|
      expect(obj.send(sub_key).to_s).to eq(attributes[sub_key].to_s)
    end
  end

  def expect_import_with_events
    expect(ConfirmationEvent.all.size).to eq(2)
    confirmation_event = ConfirmationEvent.find_by_name('Parent Information Meeting')
    expect(confirmation_event.due_date.to_s).to eq('2016-06-03')
    expect(confirmation_event.instructions).to eq("<p><em><strong>simple text</strong></em></p>")

    confirmation_event_2 = ConfirmationEvent.find_by_name('Attend Retreat')
    expect(confirmation_event_2.due_date.to_s).to eq('2016-05-03')
    expect(confirmation_event_2.instructions).to eq("<h1>a heading</h1>\n<ul>\n<li>step 1</li>\n<li>step 2</li>\n</ul>\n<p> </p>\n<p> </p>")

    expect(Candidate.all.size).to eq(3)
    expect_candidate(get_vicki_kristoff)
    expect_candidate(get_paul_kristoff)
    expect_candidate(get_foo_bar)
  end

  def save(candidate_import)
    import_result = candidate_import.save
    candidate_import.errors.each do |candidate|
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

      FactoryGirl.create(:candidate,
                         account_name: 'c1',
                         parent_email_1: 'test@example.com',
                         candidate_email: 'candiate@example.com')
      FactoryGirl.create(:candidate, account_name: 'c2')
      FactoryGirl.create(:candidate, account_name: 'c3')

      candidate_import = CandidateImport.new
      package = candidate_import.create_xlsx_package

      package.workbook do |wb|
        wb.worksheets.each do |ws|
          if ws.name == 'Candidates with events'
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
          elsif ws.name == 'Confirmation Events'
            header_row = ws.rows[0]
            expect(header_row.cells.size).to eq(3)
            candidate_import.xlsx_conf_event_columns.each_with_index do |column_name, index|
              expect(header_row.cells[index].value).to eq(column_name)
            end
            expect(ws.rows.size).to eq(3)

            c1_row = ws.rows[1]
            expect(c1_row.cells.size).to eq(3)
            expect(c1_row.cells[0].value).to eq('Going out to eat')
            expect(c1_row.cells[1].value.to_s).to eq('2016-05-24')
            expect(c1_row.cells[2].value.to_s).to eq("<h3>Do this</h3><ul>\n<li>one</li>\n<li>two</li>\n<li>three</li>\n</ul>")

            c2_row = ws.rows[2]
            expect(c2_row.cells.size).to eq(3)
            expect(c2_row.cells[0].value).to eq('Staying home')
            expect(c2_row.cells[1].value.to_s).to eq('2016-04-01')
            expect(c2_row.cells[2].value.to_s).to eq("<h3>Do this</h3><ul>\n<li>one</li>\n<li>two</li>\n<li>three</li>\n</ul>")
          else
            expect(ws.name).to eq('Candidates with events  Confirmation Events')
          end

        end
      end

    end


  end

  describe 'combinations' do
    it 'reset db followed by import should update existing candidate and confirmation_events' do
      uploaded_file = fixture_file_upload('export_with_events.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      candidate_import = CandidateImport.new(uploaded_file: uploaded_file)
      candidate_import.reset_database

      expect(save candidate_import).to eq(true)

      expect_import_with_events
    end
  end

end
