include ActionDispatch::TestProcess
include FileHelper

describe CandidateImport do

  describe 'import excel spreadsheet' do

    it 'import initial spreadsheet from coordinator will update database' do

      all_event_names = AppFactory.add_confirmation_events

      uploaded_file = fixture_file_upload('Confirmation 2017 Database for all teens.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      candidate_import = CandidateImport.new(uploaded_file: uploaded_file)
      success = candidate_import.save
      unless success
        candidate_import.errors.messages.each do | error |
          puts error
        end
      end
      expect(success).to eq(true)

      expect(Candidate.all.size).to eq(115)
      the_way_candidates = Candidate.all.select {|c| c.candidate_sheet.attending === I18n.t('views.candidates.attending_the_way')}
      expect(the_way_candidates.size).to eq(91)
      chs_candidates = Candidate.all.select {|c| c.candidate_sheet.attending === I18n.t('views.candidates.attending_catholic_high_school')}
      expect(chs_candidates.size).to eq(24)

      the_way_candidate = Candidate.find_by_account_name('laiquongnicholas')
      expect(the_way_candidate.candidate_sheet.first_name).to eq('Nicholas')
      expect(the_way_candidate.candidate_sheet.last_name).to eq('Lai Quong')
      expect(the_way_candidate.candidate_sheet.grade).to eq(10)
      expect(the_way_candidate.candidate_sheet.parent_email_1).to eq('mardavnich@yahoo.com')
      expect(the_way_candidate.candidate_sheet.parent_email_2).to eq('dlqtrini@hotmail.com')
      expect(the_way_candidate.candidate_sheet.attending).to eq(I18n.t('views.candidates.attending_the_way'))

      chs_candidate = Candidate.find_by_account_name('woomerkevin')
      expect(chs_candidate.candidate_sheet.first_name).to eq('Kevin')
      expect(chs_candidate.candidate_sheet.last_name).to eq('Woomer')
      expect(chs_candidate.candidate_sheet.grade).to eq(12)
      expect(chs_candidate.candidate_sheet.parent_email_1).to eq('karenwoomer@gmail.com')
      expect(chs_candidate.candidate_sheet.parent_email_2).to eq('')
      expect(chs_candidate.candidate_sheet.attending).to eq(I18n.t('views.candidates.attending_catholic_high_school'))

      expect(the_way_candidates[0].candidate_events.size).to eq(all_event_names.size)

    end

    it 'import invalid spreadsheet will not update database' do
      uploaded_file = fixture_file_upload('Invalid.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      candidate_import = CandidateImport.new(uploaded_file: uploaded_file)
      expect(candidate_import.save).to eq(false)
      error_messages = [
          'Row 2: Candidate sheet last name can\'t be blank',
          'Row 3: Candidate sheet first name can\'t be blank',
          'Row 5: Candidate sheet parent email 1 is an invalid email: @nc.rr.com',
          'Row 5: Candidate sheet parent email 2 is an invalid email: rannunz'
      ]
      candidate_import.errors.each_with_index do |candidate, index|
        expect(candidate[1]).to eq(error_messages[index])
      end
      expect(candidate_import.errors.size).to eq(4)
    end

    it 'import spreadsheet from export will update database' do
      uploaded_zip_file = fixture_file_upload('export_with_events.zip', 'application/zip')
      candidate_import = CandidateImport.new(uploaded_zip_file: uploaded_zip_file)

      expect(save candidate_import).to eq(true)

      expect_import_with_events
    end
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

    it 'export baptismal certificate image' do
      candidate = FactoryGirl.create(:candidate,
                                     baptismal_certificate: FactoryGirl.create(:baptismal_certificate))
      add_baptismal_certificate_image(candidate)

      dir_name = 'temp'
      begin

        Dir.mkdir(dir_name)

        candidate_import = CandidateImport.new
        package = candidate_import.create_xlsx_package(dir_name)

        filename = CandidateImport.image_filename(candidate, dir_name)
        package.workbook do |wb|
          ws = wb.worksheets[1]
          header_row = ws.rows[0]
          c1_row = ws.rows[1]
          expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.certificate_filename')].value).to eq(filename) #certificate_filename
          expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.certificate_content_type')].value).to eq(filename) #certificate_content_type
          expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.certificate_file_contents')].value).to eq(filename) #certificate_file_contents
        end

        expect(File.exist? filename).to eq(true)

      ensure
        File.delete(filename) if File.exist?(filename)
        Dir.rmdir(dir_name) if Dir.exist?(dir_name)

      end

    end

    def find_cell_offset (header_row, column_name)
      index = -1
      header_row.find do |cell|
        index += 1
        cell.value === column_name
      end
      index
    end

    it 'read in exported image' do
      candidate = FactoryGirl.create(:candidate,
                                     baptismal_certificate: FactoryGirl.create(:baptismal_certificate))
      add_baptismal_certificate_image(candidate)

      dir_name = 'temp'
      filename = 'export.xlsx'

      xlsx_path = "#{dir_name}/#{filename}"
      image_path = "#{dir_name}/#{'sophiaagusta_actions.png'}"
      begin

        Dir.mkdir(dir_name)
        CandidateImport.new.to_xlsx(dir_name).serialize(xlsx_path)
        uploaded_file = Rack::Test::UploadedFile.new(xlsx_path, 'type/png', true)
        CandidateImport.new.reset_database

        expect(Candidate.find_by_account_name(candidate.account_name)).to eq(nil)

        candidate_import = CandidateImport.new(uploaded_file: uploaded_file)
        save_result = candidate_import.save
        expect(save_result).to eq(true)

        candidate = Candidate.find_by_account_name(candidate.account_name)
        expect(candidate).not_to eq(nil)
        baptismal_certificate = candidate.baptismal_certificate
        expect(baptismal_certificate).not_to eq(nil)
        expect(baptismal_certificate.certificate_filename).to eq('actions.png')
        expect(baptismal_certificate.certificate_content_type).to eq('type/png')
        expect(baptismal_certificate.certificate_file_contents).not_to eq(nil)

      ensure
        # puts "#{xlsx_path}=#{File.exist?(xlsx_path)}"
        File.delete(xlsx_path) if File.exist?(xlsx_path)
        # puts "#{image_path}=#{File.exist?(image_path)}"
        File.delete(image_path) if File.exist?(image_path)
        # Dir.entries(dir_name).each {|x| puts x}
        Dir.rmdir(dir_name) if Dir.exist?(dir_name)
      end
    end

    it 'reset after adding in some candidates' do

      c1 = FactoryGirl.create(:candidate, account_name: 'c1')
      c1.candidate_sheet.parent_email_1 = 'test@example.com'
      c1.candidate_sheet.candidate_email = 'candiate@example.com'
      c1.baptismal_certificate = FactoryGirl.create(:baptismal_certificate)
      c1.save
      FactoryGirl.create(:candidate, account_name: 'c2')
      FactoryGirl.create(:candidate, account_name: 'c3')


      candidate_import = CandidateImport.new
      dir_name = 'temp'
      begin

        Dir.mkdir(dir_name)
        package = candidate_import.create_xlsx_package(dir_name)

        package.workbook do |wb|
          wb.worksheets.each do |ws|
            if ws.name == 'Candidates with events'
              expect_candidates(ws, candidate_import)
            elsif ws.name == 'Confirmation Events'
              expect_confirmation_events(ws, candidate_import)
            else
              # error
              expect(ws.name).to eq('Candidates with events  Confirmation Events')
            end

          end
        end
      ensure
        delete_dir(dir_name)
      end

    end


  end

  describe 'combinations' do
    it 'reset db followed by import should update existing candidate and confirmation_events' do
      uploaded_file_zip = fixture_file_upload('export_with_events.zip', 'application/zip')
      candidate_import = CandidateImport.new(uploaded_zip_file: uploaded_file_zip)
      candidate_import.reset_database

      expect(save candidate_import).to eq(true)

      expect_import_with_events
    end
  end

  def add_baptismal_certificate_image(candidate)
    filename = 'actions.png'
    baptismal_certificate = candidate.baptismal_certificate
    baptismal_certificate.certificate_filename = filename
    baptismal_certificate.certificate_content_type = 'type/png'
    File.open(File.join('spec/fixtures/', filename), "rb").read do |data|
      baptismal_certificate.certificate_file_contents = data
    end
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
        expect(candidate_subs.size).to eq(value.size)
        value.each_with_index do |sub_values, index|
          # puts "Name: #{candidate_subs[index].confirmation_event.name}"
          expect_keys(candidate_subs[index], sub_values)
        end
      else
        expect(candidate.send(key)).to eq(value)
      end
    end
    expect(candidate.candidate_events.size).to eq(get_all_event_names.size)
  end

  def expect_candidates(ws, candidate_import)
    header_row = ws.rows[0]
    candidate_import.xlsx_columns.each_with_index do |column_name, index|
      # puts "#{index}:#{header_row.cells[index].value}"
      expect(header_row.cells[index].value).to eq(column_name)
    end
    c1_row = ws.rows[1]
    c2_row = ws.rows[2]
    c3_row = ws.rows[3]
    (1..ws.rows.size-1).each do |i|
      account_name = ws.rows[i].cells[find_cell_offset(header_row, 'account_name')].value
      # puts account_name
      c1_row = ws.rows[i] if account_name === 'c1'
      c2_row = ws.rows[i] if account_name === 'c2'
      c3_row = ws.rows[i] if account_name === 'c3'
    end

    expect(c1_row.cells[find_cell_offset(header_row, 'account_name')].value).to eq('c1')
    expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.first_name')].value).to eq('Sophia')
    expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.last_name')].value).to eq('Agusta')
    expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.candidate_email')].value).to eq('candiate@example.com')
    expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.parent_email_1')].value).to eq('test@example.com')
    expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.parent_email_2')].value).to eq('')
    expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.grade')].value).to eq(10)
    expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.attending')].value).to eq(I18n.t('model.candidate.attending_the_way'))
    expect(c1_row.cells[find_cell_offset(header_row, 'baptized_at_stmm')].value).to eq(1)
    expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.address.street_1')].value).to eq('2120 Frissell Ave.')
    expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.address.street_2')].value).to eq('Apt. 456')
    expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.address.city')].value).to eq('Apex')
    expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.address.state')].value).to eq('NC')
    expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.address.zip_code')].value).to eq(27502)
    expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.birth_date')].value.to_s).to eq('1983-08-20')
    expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.baptismal_date')].value.to_s).to eq('1983-10-20')
    expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.church_name')].value).to eq('St. Francis')
    expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.church_address.street_1')].value).to eq('1313 Magdalene Way')
    expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.church_address.street_2')].value).to eq('Apt. 456')
    expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.church_address.city')].value).to eq('Apex')
    expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.church_address.state')].value).to eq('NC')
    expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.church_address.zip_code')].value).to eq(27502)
    expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.father_first')].value).to eq('George')
    expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.father_middle')].value).to eq('Paul')
    expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.father_last')].value).to eq('Smith')
    expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.mother_first')].value).to eq('Georgette')
    expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.mother_middle')].value).to eq('Paula')
    expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.mother_maiden')].value).to eq('Kirk')
    expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.mother_last')].value).to eq('Smith')
    expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.certificate_filename')].value).to eq('temp/c1_actions.png')
    expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.certificate_content_type')].value).to eq('temp/c1_actions.png')
    expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.certificate_file_contents')].value).to eq('temp/c1_actions.png')
    # TODO: add other 31 tests
    expect(c1_row.size).to eq(65)

    expect(c2_row.cells[0].value).to eq('c2')

    expect(c3_row.cells[0].value).to eq('c3')
  end

  def expect_confirmation_events(ws, candidate_import)
    header_row = ws.rows[0]
    expect(header_row.cells.size).to eq(4)
    candidate_import.xlsx_conf_event_columns.each_with_index do |column_name, index|
      expect(header_row.cells[index].value).to eq(column_name)
    end
    expect(ws.rows.size).to eq(3)

    c1_row = ws.rows[1]
    expect(c1_row.cells.size).to eq(4)
    expect(c1_row.cells[0].value).to eq('Going out to eat')
    expect(c1_row.cells[1].value.to_s).to eq('2016-05-31')
    expect(c1_row.cells[2].value.to_s).to eq('2016-05-24')
    expect(c1_row.cells[3].value.to_s).to eq("<h3>Do this</h3><ul>\n<li>one</li>\n<li>two</li>\n<li>three</li>\n</ul>")

    c2_row = ws.rows[2]
    expect(c2_row.cells.size).to eq(4)
    expect(c2_row.cells[0].value).to eq('Staying home')
    expect(c2_row.cells[1].value.to_s).to eq('2016-04-30')
    expect(c2_row.cells[2].value.to_s).to eq('2016-04-01')
    expect(c2_row.cells[3].value.to_s).to eq("<h3>Do this</h3><ul>\n<li>one</li>\n<li>two</li>\n<li>three</li>\n</ul>")
  end

  def expect_import_with_events
    expect(ConfirmationEvent.find_by_name(I18n.t('events.parent_meeting')).the_way_due_date.to_s).to eq('2016-06-30')
    expect(ConfirmationEvent.find_by_name(I18n.t('events.parent_meeting')).chs_due_date.to_s).to eq('2016-06-03')

    expect(ConfirmationEvent.find_by_name(I18n.t('events.retreat_weekend')).the_way_due_date.to_s).to eq('2016-05-31')
    expect(ConfirmationEvent.find_by_name(I18n.t('events.retreat_weekend')).chs_due_date.to_s).to eq('2016-05-03')

    expect(ConfirmationEvent.find_by_name(I18n.t('events.candidate_covenant_agreement')).the_way_due_date.to_s).to eq('2016-07-31')
    expect(ConfirmationEvent.find_by_name(I18n.t('events.candidate_covenant_agreement')).chs_due_date.to_s).to eq('2016-07-13')

    expect(ConfirmationEvent.find_by_name(I18n.t('events.candidate_information_sheet')).the_way_due_date.to_s).to eq('2016-02-29')
    expect(ConfirmationEvent.find_by_name(I18n.t('events.candidate_information_sheet')).chs_due_date.to_s).to eq('2016-02-16')

    expect(ConfirmationEvent.find_by_name(I18n.t('events.baptismal_certificate')).the_way_due_date.to_s).to eq('2016-08-31')
    expect(ConfirmationEvent.find_by_name(I18n.t('events.baptismal_certificate')).chs_due_date.to_s).to eq('2016-08-12')

    expect(ConfirmationEvent.find_by_name(I18n.t('events.sponsor_covenant')).the_way_due_date.to_s).to eq('2016-10-31')
    expect(ConfirmationEvent.find_by_name(I18n.t('events.sponsor_covenant')).chs_due_date.to_s).to eq('2016-10-15')

    expect(ConfirmationEvent.find_by_name(I18n.t('events.confirmation_name')).the_way_due_date.to_s).to eq('2016-11-30')
    expect(ConfirmationEvent.find_by_name(I18n.t('events.confirmation_name')).chs_due_date.to_s).to eq('2016-11-20')

    expect(ConfirmationEvent.find_by_name(I18n.t('events.sponsor_agreement')).the_way_due_date.to_s).to eq('2016-12-31')
    expect(ConfirmationEvent.find_by_name(I18n.t('events.sponsor_agreement')).chs_due_date.to_s).to eq('2016-12-15')

    expect(ConfirmationEvent.find_by_name(I18n.t('events.christian_ministry')).the_way_due_date.to_s).to eq('2017-01-31')
    expect(ConfirmationEvent.find_by_name(I18n.t('events.christian_ministry')).chs_due_date.to_s).to eq('2017-01-22')

    if ConfirmationEvent.all.size != 9
      ConfirmationEvent.all.each {|x| puts x.name}
    end

    expect(ConfirmationEvent.all.size).to eq(9)

    confirmation_event_2 = ConfirmationEvent.find_by_name('Attend Retreat')
    expect(confirmation_event_2.the_way_due_date.to_s).to eq('2016-05-31')
    expect(confirmation_event_2.chs_due_date.to_s).to eq('2016-05-03')
    expect(confirmation_event_2.instructions).to eq("<h1>a heading</h1>\n<ul>\n<li>step 1</li>\n<li>step 2</li>\n</ul>\n<p> </p>\n<p> </p>")

    expect(Candidate.all.size).to eq(3)
    expect_candidate(get_vicki_kristoff)
    expect_candidate(get_paul_kristoff)
    expect_candidate(get_foo_bar)
  end

  def expect_keys(obj, attributes)
    attributes.keys.each do |sub_key|
      # puts obj.class
      # puts "#{obj.first_name}" if obj.class.to_s === 'CandidateSheet'
      # puts "#{obj.confirmation_event.name}:#{sub_key}" if obj.class.to_s === 'CandidateSheet'
      if attributes[sub_key].is_a?(Hash)
        expect_keys(obj.send(sub_key), attributes[sub_key])
      else
        expect(obj.send(sub_key).to_s).to eq(attributes[sub_key].to_s)
      end
    end
  end

  def find_cell_offset (header_row, column_name)
    index = -1
    header_row.find do |cell|
      index += 1
      cell.value === column_name
    end
    index
  end

  def get_all_event_names
    config = YAML.load_file('config/locales/en.yml')
    all_events_names = []
    config['en']['events'].each do |event_name_entry|
      all_events_names << "events.#{event_name_entry[0]}"
    end
    all_events_names
  end

  def get_foo_bar
    {
        account_name: 'foobar',
        candidate_sheet: {
            first_name: 'foo',
            last_name: 'bar',
            candidate_email: '',
            parent_email_1: 'foo@bar.com',
            parent_email_2: '',
            grade: 10,
            attending: I18n.t('model.candidate.attending_the_way'),
            address: {
                street_1: '',
                street_2: 'street 2',
                city: 'Clarksville',
                state: 'IN',
                zip_code: '47129'
            },
        },
        candidate_events_sorted: [
            {completed_date: '', # Fill Out Candidate Information Sheet 2/29/16
             name: I18n.t('events.candidate_information_sheet'),
             due_date: '2016-02-29',
             verified: false},
            {completed_date: '', # Attend Retreat 5/31/16
             name: I18n.t('events.retreat_weekend'),
             due_date: '2016-05-31',
             verified: false},
            {completed_date: '', # Parent Information Meeting 6/30/16
             name: I18n.t('events.parent_meeting'),
             due_date: '2016-06-30',
             verified: false},
            {completed_date: '', # Sign Agreement 7/31/2016
             name: I18n.t('events.candidate_covenant_agreement'),
             due_date: '2016-07-31',
             verified: false},
            {completed_date: '', # Baptismal Certificate 8/31/16
             name: I18n.t('events.baptismal_certificate'),
             due_date: '2016-08-31',
             verified: false},
            {completed_date: '', # Christian Ministry Awareness 1/31/17
             name: I18n.t('events.christian_ministry'),
             due_date: '2017-01-31',
             verified: false},
            {completed_date: '2017-01-01', # Sponsor Covenant 10/31/16
             name: I18n.t('events.sponsor_covenant'),
             due_date: '2016-10-31',
             verified: false},
            {completed_date: '2016-12-25', # Confirmation Name
             name: I18n.t('events.confirmation_name'),
             due_date: '2016-11-30',
             verified: true},
            {completed_date: '2017-01-25', # Sponsor Agreement 12/31/2016
             name: I18n.t('events.sponsor_agreement'),
             due_date: '2016-12-31',
             verified: false}
        ]
    }
  end

  def get_paul_kristoff
    {
        account_name: 'paulkristoff',
        candidate_sheet: {
            first_name: 'Paul',
            last_name: 'Kristoff',
            candidate_email: 'paul@kristoffs.com',
            parent_email_1: 'vicki@kristoffs.com',
            parent_email_2: 'vicki@kristoffs.com',
            grade: 9,
            attending: I18n.t('model.candidate.attending_the_way'),
            address: {
                street_1: '2116 Frissell Ave',
                street_2: '',
                city: 'Cary',
                state: 'NC',
                zip_code: '27555'
            },
        },
        candidate_events_sorted: [
            {completed_date: '', # Fill Out Candidate Information Sheet 2/29/16
             name: I18n.t('events.candidate_information_sheet'),
             due_date: '2016-02-29',
             verified: false},
            {completed_date: '', # Sign Agreement 7/31/16
             name: I18n.t('events.candidate_covenant_agreement'),
             due_date: '2016-07-31',
             verified: false},
            {completed_date: '', #  Baptismal Certificate 8/31/16
             name: I18n.t('events.baptismal_certificate'),
             due_date: '2016-08-31',
             verified: false},
            {completed_date: '', # Sponsor Covenant 10/31/16
             name: I18n.t('events.sponsor_covenant'),
             due_date: '2016-10-31',
             verified: false},
            {completed_date: '', # Confirmation Name
             name: I18n.t('events.confirmation_name'),
             due_date: '2016-11-30',
             verified: false},
            {completed_date: '', # Sponsor Agreement 12/31/2016
             name: I18n.t('events.sponsor_agreement'),
             due_date: '2016-12-31',
             verified: false},
            {completed_date: '', # Christian Ministry Awareness 1/31/17
             name: I18n.t('events.christian_ministry'),
             due_date: '2017-01-31',
             verified: false},
            {name: I18n.t('events.retreat_weekend'),
             completed_date: '2016-05-02', # Attend Retreat 5/31/16
             due_date: '2016-05-31',
             verified: true},
            {name: I18n.t('events.parent_meeting'),
             completed_date: '2016-07-07', # Parent Information Meeting 6/30/16
             due_date: '2016-06-30',
             verified: false}
        ]
    }
  end

  def get_vicki_kristoff
    {
        account_name: 'vickikristoff',
        candidate_sheet: {
            first_name: 'Vicki',
            last_name: 'Kristoff',
            candidate_email: 'vicki@kristoffs.com',
            parent_email_1: 'paul@kristoffs.com',
            parent_email_2: 'paul@kristoffs.com',
            grade: 12,
            attending: I18n.t('model.candidate.attending_catholic_high_school'),
            address: {
                street_1: '2120 Frissell Ave',
                street_2: '',
                city: 'Apex',
                state: 'NC',
                zip_code: '27502'
            },
        },
        candidate_events_sorted: [
            {completed_date: '', # Fill Out Candidate Information Sheet
             name: I18n.t('events.candidate_information_sheet'),
             due_date: '2016-02-16',
             verified: false},
            {completed_date: '', # Attend Retreat
             name: I18n.t('events.retreat_weekend'),
             due_date: '2016-05-03',
             verified: false},
            {completed_date: '', # Parent Information Meeting
             name: I18n.t('events.parent_meeting'),
             due_date: '2016-06-03',
             verified: false},
            {completed_date: '', # Baptismal Certificate
             name: I18n.t('events.baptismal_certificate'),
             due_date: '2016-08-12',
             verified: false},
            {completed_date: '', # Sponsor Covenant
             name: I18n.t('events.sponsor_covenant'),
             due_date: '2016-10-15',
             verified: false},
            {completed_date: '', # Confirmation Name
             name: I18n.t('events.confirmation_name'),
             due_date: '2016-11-20',
             verified: false},
            {completed_date: '', # Sponsor Agreement 12/15/2016
             name: I18n.t('events.sponsor_agreement'),
             due_date: '2016-12-15',
             verified: false},
            {completed_date: '', # Christian Ministry Awareness 1/31/17
             name: I18n.t('events.christian_ministry'),
             due_date: '2017-01-22',
             verified: false},
            {completed_date: '2016-06-06', # Sign Agreement
             name: I18n.t('events.candidate_covenant_agreement'),
             due_date: '2016-07-13',
             verified: true}
        ]
    }
  end

  def save(candidate_import)
    import_result = candidate_import.save
    candidate_import.errors.each do |candidate|
      puts "Errors:  #{candidate[1]}"
    end
    import_result
  end

end
