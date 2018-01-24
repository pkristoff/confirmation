include ViewsHelpers
include ActionDispatch::TestProcess
include FileHelper

describe CandidateImport do

  before(:each) do

    @image_column_mappings = {
        baptismal_certificate: 'baptismal_certificate.scanned_certificate',
        retreat_verification: 'retreat_verification.scanned_retreat',
        sponsor_eligibility: 'sponsor_covenant.scanned_eligibility',
        sponsor_covenant: 'sponsor_covenant.scanned_covenant'
    }
  end

  describe 'import excel spreadsheet' do

    it 'import initial spreadsheet from coordinator will update database' do

      all_event_names = AppFactory.add_confirmation_events

      uploaded_file = fixture_file_upload('Confirmation 2018 Group The Way test.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      candidate_import = CandidateImport.new
      success = candidate_import.load_initial_file(uploaded_file)
      unless success
        candidate_import.errors.messages.each do |error|
          puts error
        end
      end
      expect(success).to eq(true)

      expect_db(85, 9, 0)

      the_way_candidates = Candidate.all.select {|c| c.candidate_sheet.attending === I18n.t('views.candidates.attending_the_way')}
      expect(the_way_candidates.size).to eq(83)
      chs_candidates = Candidate.all.select {|c| c.candidate_sheet.attending === I18n.t('views.candidates.attending_catholic_high_school')}
      expect(chs_candidates.size).to eq(2)

      the_way_candidate = Candidate.find_by_account_name('dawannie')
      expect(the_way_candidate.candidate_sheet.first_name).to eq('Annie')
      expect(the_way_candidate.candidate_sheet.last_name).to eq('Daw')
      expect(the_way_candidate.candidate_sheet.grade).to eq(10)
      expect(the_way_candidate.candidate_sheet.candidate_email).to eq('financial@kristoffs.com')
      expect(the_way_candidate.candidate_sheet.parent_email_1).to eq('retail@kristoffs.com')
      expect(the_way_candidate.candidate_sheet.parent_email_2).to eq('')
      expect(the_way_candidate.candidate_sheet.attending).to eq(I18n.t('views.candidates.attending_the_way'))

      chs_candidate = Candidate.find_by_account_name('clavijoabbie')
      expect(chs_candidate.candidate_sheet.first_name).to eq('Abbie')
      expect(chs_candidate.candidate_sheet.last_name).to eq('Clavijo')
      expect(chs_candidate.candidate_sheet.grade).to eq(10)
      expect(the_way_candidate.candidate_sheet.candidate_email).to eq('financial@kristoffs.com')
      expect(chs_candidate.candidate_sheet.parent_email_1).to eq('retail@kristoffs.com')
      expect(chs_candidate.candidate_sheet.parent_email_2).to eq('stmm-confirmation@kristoffs.com')
      expect(chs_candidate.candidate_sheet.attending).to eq(I18n.t('views.candidates.attending_catholic_high_school'))

      expect(the_way_candidates[0].candidate_events.size).to eq(all_event_names.size)

    end

    it 'import invalid spreadsheet will not update database' do
      uploaded_file = fixture_file_upload('Invalid.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      candidate_import = CandidateImport.new
      expect(candidate_import.load_initial_file(uploaded_file)).to eq(false)
      error_messages = [
          'Row 2: Last name can\'t be blank',
          'Row 3: First name can\'t be blank',
          'Row 5: Parent email 1 is an invalid email: @nc.rr.com',
          'Row 5: Parent email 2 is an invalid email: rannunz'
      ]
      candidate_import.errors.each_with_index do |candidate, index|
        expect(candidate[1]).to eq(error_messages[index])
      end
      expect(candidate_import.errors.size).to eq(4)
    end

    it 'import spreadsheet from export will update database' do
      uploaded_zip_file = fixture_file_upload('export_with_events.zip', 'application/zip')
      candidate_import = CandidateImport.new

      expect(save_zip candidate_import, uploaded_zip_file).to eq(true)

      expect_import_with_events
    end

    it 'import spreadsheet with images from export will update database' do
      uploaded_zip_file = fixture_file_upload('export with images.zip', 'application/zip')
      candidate_import = CandidateImport.new

      expect(save_zip candidate_import, uploaded_zip_file).to eq(true)

      candidate = Candidate.find_by_account_name 'vickikristoff'
      expect_image_values(candidate, :baptismal_certificate, 'Baptismal Certificate.png')
      expect_image_values(candidate, :retreat_verification, 'actions.png')
      expect_image_values(candidate, :sponsor_eligibility, 'Baptismal Certificate.png')
      expect_image_values(candidate, :sponsor_covenant, 'actions.png')
    end

    def image_column_value (candidate, columns)
      association, image_method, value_method = columns.split('.')
      candidate.send(association).send(image_method).send(value_method)
    end
  end

  describe 'reset system back to original state' do

    it 'reset after adding in some candidates' do

      expect(Candidate.all.size).to eq(0)
      FactoryBot.create(:candidate, account_name: 'a1')
      FactoryBot.create(:candidate, account_name: 'a2')
      FactoryBot.create(:candidate, account_name: 'a3')
      expect(Candidate.all.size).to eq(3)

      expect(Admin.all.size).to eq(0)
      FactoryBot.create(:admin, email: 'paul@kristoffs.com', name: 'Paul')
      FactoryBot.create(:admin, email: 'vicki@kristoffs.com', name: 'Vicki')
      expect(Admin.all.size).to eq(2)

      CandidateImport.new.reset_database

      expect(Candidate.all.size).to eq(1)
      expect(Candidate.find_by_account_name('vickikristoff')).not_to eq(nil)
      expect(Admin.all.size).to eq(1)
      expect(Admin.find_by_email('stmm.confirmation@kristoffs.com')).not_to eq(nil)

    end
  end

  describe 'export candidate to excel' do

    describe 'export images to excel' do

      before(:each) do
        @candidate_import = CandidateImport.new
        @candidate_import.reset_database

        @dir_name = 'temp'

        Dir.mkdir(@dir_name)

      end

      after(:each) do
        clean_dir(@dir_name)

      end

      it 'export baptismal certificate image' do
        candidate = Candidate.first
        add_baptismal_certificate_image(candidate)
        expect_image(@dir_name, [:baptismal_certificate])
      end

      it 'export retreat image' do
        candidate = Candidate.first
        add_retreat_verification_image(candidate)
        expect_image(@dir_name, [:retreat_verification])
      end

      it 'export sponsor_covenants image - sponsor_eligibility' do
        candidate = Candidate.first
        add_sponsor_eligibility_image(candidate)
        expect_image(@dir_name, [:sponsor_eligibility])
      end

      it 'export sponsor_covenants image - sponsor_covenant' do
        candidate = Candidate.first
        add_sponsor_covenant_image(candidate)
        expect_image(@dir_name, [:sponsor_covenant])
      end

      it 'export retreat image, sponsor_covenant and baptismal certificate avoiding name conflicts' do
        candidate = Candidate.first
        add_baptismal_certificate_image(candidate)
        add_retreat_verification_image(candidate)
        add_sponsor_covenant_image(candidate)
        add_sponsor_eligibility_image(candidate)
        expect_image(@dir_name, [:baptismal_certificate, :retreat_verification, :sponsor_covenant, :sponsor_eligibility])

      end
    end

    def expect_image (dir_name, image_types)
      candidate = Candidate.first
      package = @candidate_import.to_xlsx(@dir_name)

      package.workbook do |wb|
        ws = wb.worksheets[1]
        header_row = ws.rows[0]
        c1_row = ws.rows[1]
        @image_column_mappings.each_key do |image_type|
          column_name = @image_column_mappings[image_type]
          cell = c1_row.cells[find_cell_offset(header_row, column_name)].value
          if image_types.include? image_type

            association_column, image_column = column_name.split('.')
            expected_export_filename = CandidateImport.image_filepath_export(candidate, dir_name, image_column, candidate.send(association_column).send(image_column))
            expected_filename = 'actions.png'
            expected_content_type = 'png'

            original_filename, original_content_type, export_filename = cell.split(':::')

            expect(expected_filename).to eq(original_filename)
            expect(expected_content_type).to eq(original_content_type)
            expect(expected_export_filename).to eq(export_filename)

            expect(File.exist? export_filename).to eq(true), "Expected export_filename '#{export_filename}' to exist"
            expect(File.size export_filename).to_not eq(0), "Expected export_filename '#{export_filename}' is greater than 0 for image type: #{image_type}"
          else
            expect(cell).to eq(nil)
          end
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

    it 'read in exported image' do
      candidate = FactoryBot.create(:candidate,
                                     baptismal_certificate: FactoryBot.create(:baptismal_certificate))
      add_baptismal_certificate_image(candidate)

      dir_name = 'temp'
      filename = 'export.xlsx'

      xlsx_path = "#{dir_name}/#{filename}"
      image_path = "#{dir_name}/#{'sophiaagusta_actions.png'}"
      begin

        Dir.mkdir(dir_name)
        CandidateImport.new.to_xlsx(dir_name).serialize(xlsx_path)
        uploaded_file = Rack::Test::UploadedFile.new(xlsx_path, 'image/png', true)
        CandidateImport.new.reset_database

        expect(Candidate.find_by_account_name(candidate.account_name)).to eq(nil)

        candidate_import = CandidateImport.new
        save_result = candidate_import.load_initial_file(uploaded_file)
        expect(save_result).to eq(true)

        candidate = Candidate.find_by_account_name(candidate.account_name)
        expect(candidate).not_to eq(nil)
        baptismal_certificate = candidate.baptismal_certificate
        expect(baptismal_certificate).not_to eq(nil)
        expect(baptismal_certificate.scanned_certificate.filename).to eq('actions.png')
        expect(baptismal_certificate.scanned_certificate.content_type).to eq('image/png')
        expect(baptismal_certificate.scanned_certificate.content).not_to eq(nil)
        expect(baptismal_certificate.scanned_certificate.content).not_to eq('')

      ensure
        clean_dir(dir_name)
      end
    end

    it 'import with image followed by export' do

      uploaded_zip_file = fixture_file_upload('export with images.zip', 'application/zip')
      candidate_import = CandidateImport.new

      expect(save_zip candidate_import, uploaded_zip_file).to eq(true)

      # now do the export
      dir_name = 'temp'
      begin

        Dir.mkdir(dir_name)

        candidate_import = CandidateImport.new
        package = candidate_import.to_xlsx(dir_name)
        # column_names = @image_column_mappings[image_type]

        expected_export_filename = 'temp/vickikristoff_scanned_certificate_Baptismal Certificate.png'
        package.workbook do |wb|
          ws = wb.worksheets[1]
          header_row = ws.rows[0]
          c1_row = ws.rows[1]
          cell = c1_row.cells[find_cell_offset(header_row, @image_column_mappings[:baptismal_certificate])].value
          expect(cell).not_to be(nil)
          original_filename, original_content_type, export_filename = cell.split(':::')
          expect(original_filename).to eq('Baptismal Certificate.png')
          expect(original_content_type).to eq('png')
          expect(export_filename).to eq(expected_export_filename)
        end

        expect(File.exist? expected_export_filename).to eq(true)

      ensure
        clean_dir(dir_name)

      end

    end

    it 'reset after adding in some candidates' do

      c1 = FactoryBot.create(:candidate, account_name: 'c1')
      c1.candidate_sheet.parent_email_1 = 'test@example.com'
      c1.candidate_sheet.candidate_email = 'candiate@example.com'
      c1.baptismal_certificate = FactoryBot.create(:baptismal_certificate)
      c1.save
      FactoryBot.create(:candidate, account_name: 'c2')
      FactoryBot.create(:candidate, account_name: 'c3')

      AppFactory.add_confirmation_events

      candidate_import = CandidateImport.new
      dir_name = 'temp'
      begin

        Dir.mkdir(dir_name)
        package = candidate_import.to_xlsx(dir_name)

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

  describe 'orphaned associations errors' do
    it 'login should not cause orphaned associations' do

      c1 = FactoryBot.create(:candidate)
      expect_no_orphaned_associations
    end
  end

  describe 'orphaned associations' do
    it 'No orphaned associations' do

      c1 = FactoryBot.create(:candidate)
      expect_no_orphaned_associations
    end
    it 'orphaned associations' do
      expected_orphans = get_expected_orphans

      c1 = FactoryBot.create(:candidate)
      candidate_import = CandidateImport.new
      # create orphans
      expect_ophans(candidate_import, expected_orphans)
    end
    it 'destroy orphaned associations' do
      expected_orphans = get_expected_orphans

      c1 = FactoryBot.create(:candidate)
      candidate_import = CandidateImport.new

      expect_ophans(candidate_import, expected_orphans)

      candidate_import.remove_orphaned_table_rows
      candidate_import.add_orphaned_table_rows
      orphaned_table_rows = candidate_import.orphaned_table_rows

      orphaned_table_rows.each do |key, orphan_ids|
        expect(orphan_ids.size).to be(0), "There should be no orphaned rows for '#{key}': #{orphan_ids}"
      end
    end

  end

  it 'what do things look like when empty' do

    Candidate.create(account_name: 'c1', password: 'asdfgthe',
                     candidate_sheet: CandidateSheet.create(first_name: 'Paul', last_name: 'George'))
    # c1.save

    AppFactory.add_confirmation_events

    candidate_import = CandidateImport.new
    dir_name = 'temp'
    begin

      Dir.mkdir(dir_name)
      package = candidate_import.to_xlsx(dir_name)

      package.workbook do |wb|
        wb.worksheets.each do |ws|
          if ws.name == 'Candidates with events'
            expect_candidates_empty(ws, candidate_import)
          elsif ws.name == 'Confirmation Events'
            expect_confirmation_events_empty(ws, candidate_import)
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

def expect_ophans(candidate_import, expected_orphans)
  candidate_import.add_orphaned_table_rows
  orphaned_table_rows = candidate_import.orphaned_table_rows
  orphaned_table_rows.each do |key, orphan_ids|
    expect(orphan_ids.size).to be(1), "There should be only one orphaned row for '#{key}': #{orphan_ids}"
    expect(orphan_ids[0]).to be(expected_orphans[key].id), "Id mismatch for '#{key}' orphan:#{orphan_ids[0]} expected:#{expected_orphans[key].id}"
  end
end

def get_expected_orphans

  {
      # Candidate associations
      BaptismalCertificate: FactoryBot.create(:baptismal_certificate, skip_address_replacement: true),
      CandidateSheet: FactoryBot.create(:candidate_sheet),
      ChristianMinistry: FactoryBot.create(:christian_ministry),
      PickConfirmationName: FactoryBot.create(:pick_confirmation_name),
      RetreatVerification: FactoryBot.create(:retreat_verification),
      SponsorCovenant: FactoryBot.create(:sponsor_covenant),
      # # other associations
      ScannedImage: FactoryBot.create(:scanned_image),
      Address: FactoryBot.create(:address),
      ToDo: FactoryBot.create(:to_do, confirmation_event_id: nil, candidate_event_id: nil)
  }
end

def expect_confirmation_event(event_name, way_date, chs_date)
  confirmation_event = ConfirmationEvent.find_by_name(event_name)
  expect(confirmation_event.the_way_due_date.to_s).to eq(way_date)
  expect(confirmation_event.chs_due_date.to_s).to eq(chs_date)
end

def expect_initial_conf_events
  today = Date.today.to_s

  expect_confirmation_event(I18n.t('events.parent_meeting'), today, today)
  expect_confirmation_event(I18n.t('events.retreat_verification'), today, today)
  expect_confirmation_event(I18n.t('events.candidate_covenant_agreement'), today, today)
  expect_confirmation_event(I18n.t('events.candidate_information_sheet'), today, today)
  expect_confirmation_event(I18n.t('events.baptismal_certificate'), today, today)
  expect_confirmation_event(I18n.t('events.sponsor_covenant'), today, today)
  expect_confirmation_event(I18n.t('events.confirmation_name'), today, today)
  expect_confirmation_event(I18n.t('events.christian_ministry'), today, today)
  expect_confirmation_event(I18n.t('events.sponsor_agreement'), today, today)

  if ConfirmationEvent.all.size != 9
    ConfirmationEvent.all.each {|x| puts x.name}
    expect(ConfirmationEvent.all.size).to eq(9), '"Wrong number of Confirmation Events" '
  end
end

describe 'combinations' do
  it 'reset db followed by import should update existing candidate and confirmation_events' do
    uploaded_file_zip = fixture_file_upload('export_with_events.zip', 'application/zip')
    candidate_import = CandidateImport.new(uploaded_zip_file: uploaded_file_zip)
    candidate_import.reset_database

    expect(save_zip candidate_import, uploaded_file_zip).to eq(true)

    expect_import_with_events
  end
  it 'initial import followed by initial import should update and add' do
    uploaded_file = fixture_file_upload('Initial candidates.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    candidate_import = CandidateImport.new
    candidate_import.reset_database

    expect(save candidate_import, uploaded_file).to eq(true)

    expect_initial_conf_events
    expect(Candidate.all.size).to eq(4) # vicki + 3 import

    uploaded_file_updated = fixture_file_upload('Initial candidates update.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')

    expect(save candidate_import, uploaded_file_updated).to eq(true)

    expect_initial_conf_events
    expect(Candidate.all.size).to eq(6) # vicki + 3 old import + 2 new from update
    expect_candidate(
        account_name: 'corganmakenzie',
        candidate_sheet: {
            first_name: 'Makenzie',
            last_name: 'Corgan',
            grade: 10,
            attending: I18n.t('model.candidate.attending_catholic_high_school')
        }
    )
    expect_candidate(
        account_name: 'barrerocarlos',
        candidate_sheet: {
            first_name: 'Carlos',
            last_name: 'Barrero',
            grade: 11,
            attending: I18n.t('model.candidate.attending_the_way')
        }
    )
    expect_candidate(
        account_name: 'agiusjulia',
        candidate_sheet: {
            first_name: 'Julia',
            last_name: 'Agius',
            grade: 10,
            attending: I18n.t('model.candidate.attending_the_way')
        }
    )
    expect_candidate(
        account_name: 'brixeynoah',
        candidate_sheet: {
            first_name: 'Noah',
            last_name: 'Brixey',
            grade: 11,
            attending: I18n.t('model.candidate.attending_catholic_high_school')
        }
    )
    expect_candidate(
        account_name: 'baronemaddy',
        candidate_sheet: {
            first_name: 'Maddy',
            last_name: 'Barone',
            grade: 10,
            attending: I18n.t('model.candidate.attending_catholic_high_school')
        }
    )
  end
end

describe 'check_events' do

  it 'should show "Sponsor Covenant" is missing.' do
    candidate_import = CandidateImport.new
    candidate_import.start_new_year
    setup_unknown_missing_events

    candidate_import.check_events

    expect(candidate_import.missing_confirmation_events.length).to be(1)
    expect(candidate_import.missing_confirmation_events[0]).to eq(I18n.t('events.sponsor_covenant'))
    expect(candidate_import.found_confirmation_events.length).to be(AppFactory.all_i18n_confirmation_event_names.length - 1)
    expect(candidate_import.unknown_confirmation_events.length).to be(1)
    expect(candidate_import.unknown_confirmation_events[0]).to eq('unknown event')
  end

  it 'should add "Sponsor Covenant".' do
    candidate_import = CandidateImport.new
    candidate_import.start_new_year
    setup_unknown_missing_events
    sponsor_covenant_event_name = I18n.t('events.sponsor_covenant')

    candidate_import.add_missing_events([sponsor_covenant_event_name])

    expect(ConfirmationEvent.find_by_name(sponsor_covenant_event_name).name).to eq(sponsor_covenant_event_name)

    expect(candidate_import.missing_confirmation_events.length).to be(0)
    expect(candidate_import.found_confirmation_events.length).to be(AppFactory.all_i18n_confirmation_event_names.length)
    expect(candidate_import.unknown_confirmation_events.length).to be(1)
    expect(candidate_import.unknown_confirmation_events[0]).to eq('unknown event')
  end

end

describe 'image_filename' do

  before(:each) do
    CandidateImport.new.reset_database
    candidate = Candidate.first
    add_baptismal_certificate_image(candidate)
    add_retreat_verification_image(candidate)
    add_sponsor_covenant_image(candidate)
    add_sponsor_eligibility_image(candidate)

  end

  it 'should concat a file path for the scanned in file' do
    candidate = Candidate.find_by_account_name('vickikristoff')
    expect(CandidateImport.image_filepath_export(candidate, 'temp_dir', 'scanned_certificate', candidate.baptismal_certificate.scanned_certificate)).to eq('temp_dir/vickikristoff_scanned_certificate_actions.png')
    expect(CandidateImport.image_filepath_export(candidate, 'temp_dir', 'scanned_retreat', candidate.retreat_verification.scanned_retreat)).to eq('temp_dir/vickikristoff_scanned_retreat_actions.png')
    expect(CandidateImport.image_filepath_export(candidate, 'temp_dir', 'scanned_eligibility', candidate.sponsor_covenant.scanned_eligibility)).to eq('temp_dir/vickikristoff_scanned_eligibility_actions.png')
    expect(CandidateImport.image_filepath_export(candidate, 'temp_dir', 'scanned_covenant', candidate.sponsor_covenant.scanned_covenant)).to eq('temp_dir/vickikristoff_scanned_covenant_actions.png')
  end

  it 'should handle filename being nil.' do
    candidate = Candidate.find_by_account_name('vickikristoff')
    candidate.baptismal_certificate.scanned_certificate = nil
    candidate.retreat_verification.scanned_retreat = nil
    candidate.sponsor_covenant.scanned_eligibility = nil
    candidate.sponsor_covenant.scanned_covenant = nil
    expect(CandidateImport.image_filepath_export(candidate, 'temp_dir', 'scanned_certificate', nil)).to eq('temp_dir/vickikristoff_scanned_certificate_')
    expect(CandidateImport.image_filepath_export(candidate, 'temp_dir', 'scanned_retreat', nil)).to eq('temp_dir/vickikristoff_scanned_retreat_')
    expect(CandidateImport.image_filepath_export(candidate, 'temp_dir', 'scanned_eligibility', nil)).to eq('temp_dir/vickikristoff_scanned_eligibility_')
    expect(CandidateImport.image_filepath_export(candidate, 'temp_dir', 'scanned_covenant', nil)).to eq('temp_dir/vickikristoff_scanned_covenant_')
  end

  it 'should concat a file path for the scanned in file removing unnecessary directories from the filename' do
    candidate = Candidate.find_by_account_name('vickikristoff')
    candidate.baptismal_certificate.scanned_certificate = ScannedImage.new(filename: 'foo/actions.png')
    candidate.retreat_verification.scanned_retreat = ScannedImage.new(filename: 'foo/actions.png')
    candidate.sponsor_covenant.scanned_eligibility = ScannedImage.new(filename: 'foo/actions.png')
    candidate.sponsor_covenant.scanned_covenant = ScannedImage.new(filename: 'foo/actions.png')
    expect(CandidateImport.image_filepath_export(candidate, 'temp_dir', 'scanned_certificate', candidate.baptismal_certificate.scanned_certificate)).to eq('temp_dir/vickikristoff_scanned_certificate_actions.png')
    expect(CandidateImport.image_filepath_export(candidate, 'temp_dir', 'scanned_retreat', candidate.retreat_verification.scanned_retreat)).to eq('temp_dir/vickikristoff_scanned_retreat_actions.png')
    expect(CandidateImport.image_filepath_export(candidate, 'temp_dir', 'scanned_eligibility', candidate.sponsor_covenant.scanned_eligibility)).to eq('temp_dir/vickikristoff_scanned_eligibility_actions.png')
    expect(CandidateImport.image_filepath_export(candidate, 'temp_dir', 'scanned_covenant', candidate.sponsor_covenant.scanned_covenant)).to eq('temp_dir/vickikristoff_scanned_covenant_actions.png')
  end

  it 'should remove any directories in the filename' do
    expect(CandidateImport.image_filename_import('temp/vickikristoff_actions.png')).to eq('vickikristoff_actions.png')
    expect(CandidateImport.image_filename_import('temp_dir/vickikristoff_actions.png')).to eq('vickikristoff_actions.png')
  end
end

describe 'start new year' do
  it 'should start a new year will clean out candidates and all its associations' do
    FactoryBot.create(:admin, email: 'paul@kristoffs.com', name: 'Paul')
    AppFactory.add_confirmation_events

    expect(Admin.all.size).to eq(1)

    cand_assoc = {Address: 0,
                  BaptismalCertificate: 0,
                  Candidate: 0,
                  CandidateEvent: 0,
                  CandidateSheet: 0,
                  ChristianMinistry: 0,
                  ConfirmationEvent: 9,
                  PickConfirmationName: 0,
                  RetreatVerification: 0,
                  SponsorCovenant: 0,
                  ScannedImage: 0,
                  ToDo: 0}

    expect_table_rows(Candidate, cand_assoc)

    candidate_import = CandidateImport.new
    # candidate_import.load_zip_file(fixture_file_upload('export with images.zip'))

    c0 = FactoryBot.create(:candidate, add_candidate_events: false)
    AppFactory.add_candidate_events(c0)
    c0.baptismal_certificate.scanned_certificate=create_scanned_image
    c0.sponsor_covenant.scanned_eligibility=create_scanned_image
    c0.sponsor_covenant.scanned_covenant=create_scanned_image
    c0.retreat_verification.scanned_retreat=create_scanned_image
    c0.save

    c1 = FactoryBot.create(:candidate, account_name: 'c1', add_candidate_events: false)
    AppFactory.add_candidate_events(c1)
    c1.save

    c2 = FactoryBot.create(:candidate, account_name: 'c2', add_candidate_events: false)
    AppFactory.add_candidate_events(c2)
    c2.save

    expect(Admin.all.size).to eq(1)

    cand_assoc = {Address: 6,
                  BaptismalCertificate: 3,
                  Candidate: 3,
                  CandidateEvent: 27,
                  CandidateSheet: 3,
                  ChristianMinistry: 3,
                  ConfirmationEvent: 9,
                  PickConfirmationName: 3,
                  RetreatVerification: 3,
                  SponsorCovenant: 3,
                  ScannedImage: 4,
                  ToDo: 27}

    expect_table_rows(Candidate, cand_assoc)

    candidate_import.start_new_year

    expect(Admin.all.size).to eq(1)

    cand_assoc = {Address: 2,
                  BaptismalCertificate: 1,
                  Candidate: 1,
                  CandidateEvent: 9,
                  CandidateSheet: 1,
                  ChristianMinistry: 1,
                  ConfirmationEvent: 9,
                  PickConfirmationName: 1,
                  RetreatVerification: 1,
                  SponsorCovenant: 1,
                  ScannedImage: 0,
                  ToDo: 9}

    expect_table_rows(Candidate, cand_assoc)
  end

  def create_scanned_image
    content = ''
    File.open(File.join('spec/fixtures/actions.png'), 'rb') do |f|
      content = f.read
    end
    ScannedImage.new(
        filename: 'actions.png',
        content_type: 'image/png',
        content: content
    )

  end

  it 'start a new year will clean up dangling references the DB' do
    FactoryBot.create(:admin, email: 'paul@kristoffs.com', name: 'Paul')
    AppFactory.add_confirmation_events

    expect(Admin.all.size).to eq(1)

    cand_assoc = {Address: 0,
                  BaptismalCertificate: 0,
                  Candidate: 0,
                  CandidateEvent: 0,
                  CandidateSheet: 0,
                  ChristianMinistry: 0,
                  ConfirmationEvent: 9,
                  PickConfirmationName: 0,
                  RetreatVerification: 0,
                  SponsorCovenant: 0,
                  ScannedImage: 0,
                  ToDo: 0}

    expect_table_rows(Candidate, cand_assoc)

    # create orphaned records - TODO: use get_association_classes
    FactoryBot.create(:address)
    FactoryBot.create(:baptismal_certificate)
    FactoryBot.create(:candidate_event)
    FactoryBot.create(:candidate_sheet)
    FactoryBot.create(:christian_ministry)
    FactoryBot.create(:pick_confirmation_name)
    FactoryBot.create(:retreat_verification)
    FactoryBot.create(:sponsor_covenant)
    FactoryBot.create(:to_do)
    FactoryBot.create(:scanned_image)

    candidate_import = CandidateImport.new

    c0 = FactoryBot.create(:candidate, add_candidate_events: false)
    AppFactory.add_candidate_events(c0)
    c0.save
    c1 = FactoryBot.create(:candidate, account_name: 'c1', add_candidate_events: false)
    AppFactory.add_candidate_events(c1)
    c1.baptismal_certificate.scanned_certificate=create_scanned_image
    c1.save
    c2 = FactoryBot.create(:candidate, account_name: 'c2', add_candidate_events: false)
    AppFactory.add_candidate_events(c2)
    c2.save

    expect(Admin.all.size).to eq(1)
    expect(ConfirmationEvent.all.size).to eq(9)
    expect(Candidate.all.size).to eq(3)

    cand_assoc = {Address: 9,
                  BaptismalCertificate: 4,
                  Candidate: 3,
                  CandidateEvent: 28,
                  CandidateSheet: 4,
                  ChristianMinistry: 4,
                  ConfirmationEvent: 9,
                  PickConfirmationName: 4,
                  RetreatVerification: 4,
                  SponsorCovenant: 4,
                  ScannedImage: 4,
                  ToDo: 28}

    expect_table_rows(Candidate, cand_assoc)

    candidate_import.start_new_year

    expect(Admin.all.size).to eq(1)
    expect(ConfirmationEvent.all.size).to eq(9)
    expect(Candidate.all.size).to eq(1) #vickikristoff the seed

    cand_assoc = {Address: 2,
                  BaptismalCertificate: 1,
                  Candidate: 1,
                  CandidateEvent: 9,
                  CandidateSheet: 1,
                  ChristianMinistry: 1,
                  ConfirmationEvent: 9,
                  PickConfirmationName: 1,
                  RetreatVerification: 1,
                  SponsorCovenant: 1,
                  ScannedImage: 0,
                  ToDo: 9}

    expect_table_rows(Candidate, cand_assoc)
  end

end

def add_baptismal_certificate_image(candidate)
  filename = 'actions.png'
  baptismal_certificate = candidate.baptismal_certificate
  candidate.baptismal_certificate.build_scanned_certificate
  baptismal_certificate.scanned_certificate.filename = filename
  baptismal_certificate.scanned_certificate.content_type = 'image/png'
  File.open(File.join('spec/fixtures/', filename), 'rb') do |f|
    baptismal_certificate.scanned_certificate.content = f.read
  end
  candidate.save
end

def add_retreat_verification_image(candidate)
  filename = 'actions.png'
  retreat_verification = candidate.retreat_verification
  candidate.retreat_verification.build_scanned_retreat
  retreat_verification.scanned_retreat.filename = filename
  retreat_verification.scanned_retreat.content_type = 'image/png'
  File.open(File.join('spec/fixtures/', filename), 'rb') do |f|
    retreat_verification.scanned_retreat.content = f.read
  end
  candidate.save
end

def add_sponsor_covenant_image(candidate)
  filename = 'actions.png'
  sponsor_covenant = candidate.sponsor_covenant
  candidate.sponsor_covenant.build_scanned_covenant
  sponsor_covenant.scanned_covenant.filename = filename
  sponsor_covenant.scanned_covenant.content_type = 'image/png'
  File.open(File.join('spec/fixtures/', filename), 'rb') do |f|
    sponsor_covenant.scanned_covenant.content = f.read
  end
  candidate.save
end

def add_sponsor_eligibility_image(candidate)
  filename = 'actions.png'
  sponsor_covenant = candidate.sponsor_covenant
  candidate.sponsor_covenant.build_scanned_eligibility
  sponsor_covenant.scanned_eligibility.filename = filename
  sponsor_covenant.scanned_eligibility.content_type = 'image/png'
  File.open(File.join('spec/fixtures/', filename), 'rb') do |f|
    sponsor_covenant.scanned_eligibility.content = f.read
  end
  candidate.save
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
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.middle_name')].value).to eq('Saraha')
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.last_name')].value).to eq('Agusta')
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.candidate_email')].value).to eq('candiate@example.com')
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.parent_email_1')].value).to eq('test@example.com')
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.parent_email_2')].value).to eq('')
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.grade')].value).to eq(10)
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.attending')].value).to eq(I18n.t('model.candidate.attending_the_way'))
  expect(c1_row.cells[find_cell_offset(header_row, 'baptized_at_stmm')].value).to eq(0)
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
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.scanned_certificate')].value).to eq('actions.png:::png:::temp/c1_scanned_certificate_actions.png')

  expect(c1_row.cells[find_cell_offset(header_row, 'retreat_verification.retreat_held_at_stmm')].value).to eq(0)
  expect(c1_row.cells[find_cell_offset(header_row, 'retreat_verification.start_date')].value).to eq(nil)
  expect(c1_row.cells[find_cell_offset(header_row, 'retreat_verification.end_date')].value).to eq(nil)
  expect(c1_row.cells[find_cell_offset(header_row, 'retreat_verification.who_held_retreat')].value).to eq(nil)
  expect(c1_row.cells[find_cell_offset(header_row, 'retreat_verification.where_held_retreat')].value).to eq(nil)
  expect(c1_row.cells[find_cell_offset(header_row, 'retreat_verification.scanned_retreat')].value).to eq(nil)


  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_events.0.completed_date')].value).to eq(nil)
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_events.0.verified')].value).to eq(0)

  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_events.1.completed_date')].value).to eq(nil)
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_events.1.verified')].value).to eq(0)

  # TODO: add other 31 tests
  expect(c1_row.size).to eq(72)

  expect(c2_row.cells[0].value).to eq('c2')

  expect(c3_row.cells[0].value).to eq('c3')
end

def expect_candidates_empty(ws, candidate_import)
  header_row = ws.rows[0]
  candidate_import.xlsx_columns.each_with_index do |column_name, index|
    # puts "#{index}:#{header_row.cells[index].value}"
    expect(header_row.cells[index].value).to eq(column_name)
  end
  c1_row = ws.rows[1]
  (1..ws.rows.size-1).each do |i|
    account_name = ws.rows[i].cells[find_cell_offset(header_row, 'account_name')].value
    # puts account_name
    c1_row = ws.rows[i] if account_name === 'c1'
  end

  expect(c1_row.cells[find_cell_offset(header_row, 'account_name')].value).to eq('c1')
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.first_name')].value).to eq('Paul')
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.middle_name')].value).to eq('')
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.last_name')].value).to eq('George')
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.candidate_email')].value).to eq('')
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.parent_email_1')].value).to eq('')
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.parent_email_2')].value).to eq('')
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.grade')].value).to eq(10)
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.attending')].value).to eq(I18n.t('model.candidate.attending_the_way'))
  expect(c1_row.cells[find_cell_offset(header_row, 'baptized_at_stmm')].value).to eq(0)
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.address.street_1')].value).to eq('')
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.address.street_2')].value).to eq('')
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.address.city')].value).to eq('Apex')
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.address.state')].value).to eq('NC')
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.address.zip_code')].value).to eq(27502)
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.birth_date')].value.to_s).to eq('')
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.baptismal_date')].value.to_s).to eq('')
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.church_name')].value).to eq(nil)
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.church_address.street_1')].value).to eq('')
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.church_address.street_2')].value).to eq('')
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.church_address.city')].value).to eq('Apex')
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.church_address.state')].value).to eq('NC')
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.church_address.zip_code')].value).to eq(27502)
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.father_first')].value).to eq(nil)
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.father_middle')].value).to eq(nil)
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.father_last')].value).to eq(nil)
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.mother_first')].value).to eq(nil)
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.mother_middle')].value).to eq(nil)
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.mother_maiden')].value).to eq(nil)
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.mother_last')].value).to eq(nil)
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.scanned_certificate')].value).to eq(nil)

  expect(c1_row.cells[find_cell_offset(header_row, 'retreat_verification.retreat_held_at_stmm')].value).to eq(0)
  expect(c1_row.cells[find_cell_offset(header_row, 'retreat_verification.start_date')].value).to eq(nil)
  expect(c1_row.cells[find_cell_offset(header_row, 'retreat_verification.end_date')].value).to eq(nil)
  expect(c1_row.cells[find_cell_offset(header_row, 'retreat_verification.who_held_retreat')].value).to eq(nil)
  expect(c1_row.cells[find_cell_offset(header_row, 'retreat_verification.where_held_retreat')].value).to eq(nil)
  expect(c1_row.cells[find_cell_offset(header_row, 'retreat_verification.scanned_retreat')].value).to eq(nil)

  (0..ConfirmationEvent.all.length-1).each do |index|
    expect(c1_row.cells[find_cell_offset(header_row, "candidate_events.#{index}.completed_date")].value).to eq(nil)
    expect(c1_row.cells[find_cell_offset(header_row, "candidate_events.#{index}.verified")].value).to eq(0)
  end
  expect(c1_row.size).to eq(72)
end

def expect_confirmation_events_empty(ws, candidate_import)
  header_row = ws.rows[0]
  expect(header_row.cells.size).to eq(5)
  candidate_import.xlsx_conf_event_columns.each_with_index do |column_name, index|
    expect(header_row.cells[index].value).to eq(column_name)
  end
  events_in_order = ConfirmationEvent.order(:name)
  expect(ws.rows.size).to eq(events_in_order.size+1)

  events_in_order.each_with_index do |event, index|

    row = ws.rows[index+1]
    expect(row.cells.size).to eq(5)
    # puts row.cells[0].value
    expect(row.cells[0].value).to eq(event.name)
    expect(row.cells[1].value).to eq(index)
    expect(row.cells[2].value.to_s).to eq(Date.today.to_s)
    expect(row.cells[3].value.to_s).to eq(Date.today.to_s)
    expect(row.cells[4].value.to_s).to eq('')

  end
end

def expect_confirmation_events(ws, candidate_import)
  header_row = ws.rows[0]
  expect(header_row.cells.size).to eq(5)
  candidate_import.xlsx_conf_event_columns.each_with_index do |column_name, index|
    expect(header_row.cells[index].value).to eq(column_name)
  end
  events_in_order = ConfirmationEvent.order(:name)
  expect(ws.rows.size).to eq(events_in_order.size+1)

  events_in_order.each_with_index do |confirmation_event, index|

    row = ws.rows[index+1]
    expect(row.cells.size).to eq(5)
    # puts row.cells[0].value
    expect(row.cells[0].value).to eq(confirmation_event.name)
    expect(row.cells[1].value).to eq(index)
    expect(row.cells[2].value.to_s).to eq(confirmation_event.the_way_due_date.to_s)
    expect(row.cells[3].value.to_s).to eq(confirmation_event.chs_due_date.to_s)
    expect(row.cells[4].value.to_s).to eq(confirmation_event.instructions)

  end
end

def expect_import_with_events
  expect_confirmation_event(I18n.t('events.parent_meeting'), '2016-06-30', '2016-06-03')
  expect_confirmation_event(I18n.t('events.retreat_verification'), '2016-05-31', '2016-05-03')
  expect_confirmation_event(I18n.t('events.candidate_covenant_agreement'), '2016-07-31', '2016-07-13')
  expect_confirmation_event(I18n.t('events.candidate_information_sheet'), '2016-02-29', '2016-02-16')
  expect_confirmation_event(I18n.t('events.baptismal_certificate'), '2016-08-31', '2016-08-12')
  expect_confirmation_event(I18n.t('events.sponsor_covenant'), '2016-10-31', '2016-10-15')
  expect_confirmation_event(I18n.t('events.confirmation_name'), '2016-11-30', '2016-11-20')
  expect_confirmation_event(I18n.t('events.sponsor_agreement'), '2016-12-31', '2016-12-15')
  expect_confirmation_event(I18n.t('events.christian_ministry'), '2017-01-31', '2017-01-22')

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

def expect_table_rows(clazz, expected_sizes, checked=[], do_not_include=[Admin])
  top = checked === []
  class_sym = clazz.to_s.to_sym
  unless checked.include?(class_sym) || do_not_include.include?(clazz)
    checked << class_sym
    expect(clazz.all.size).to eq(expected_sizes[class_sym]), "Association(#{clazz}) size #{clazz.all.size} does mot match expected size #{expected_sizes[class_sym]}"
    clazz.reflect_on_all_associations.each do |assoc_reflect|
      assoc_class = assoc_reflect.klass
      expect_table_rows(assoc_class, expected_sizes, checked)
    end
  end
  if top
    unless checked.size === expected_sizes.size
      puts checked
      puts expected_sizes
    end
    expect(checked.size).to eq(expected_sizes.size)
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
          middle_name: 'baz',
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
           name: I18n.t('events.retreat_verification'),
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
          middle_name: 'Richard',
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
          {name: I18n.t('events.retreat_verification'),
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
          middle_name: 'Anne',
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
           name: I18n.t('events.retreat_verification'),
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

def clean_dir(dir)
  if Dir.exists?(dir)
    Dir.foreach(dir) do |entry|
      unless entry === '.' or entry === '..'
        filename = "#{dir}/#{entry}"
        if File.file?(filename)
          File.delete filename
        else
          clean_dir(filename)
        end
      end
    end
    Dir.rmdir(dir)
  end
end

def expect_image_values(candidate, image_column_mapping_key, image_filename)
  value_methods = @image_column_mappings[image_column_mapping_key]
  expect(image_column_value(candidate, "#{value_methods}.filename")).to eq(image_filename)
  expect(image_column_value(candidate, "#{value_methods}.content_type")).to eq('image/png')
  expect(image_column_value(candidate, "#{value_methods}.content")).not_to eq(nil)
end

def save(candidate_import, uploaded_file)
  import_result = candidate_import.load_initial_file(uploaded_file)
  candidate_import.errors.each do |candidate|
    puts "Errors:  #{candidate[1]}"
  end
  import_result
end

def save_zip(candidate_import, uploaded_file_zip)
  import_result = candidate_import.load_zip_file(uploaded_file_zip)
  candidate_import.errors.each do |candidate|
    puts "Errors:  #{candidate[1]}"
  end
  import_result
end

def expect_no_orphaned_associations
  candidate_import = CandidateImport.new
  candidate_import.add_orphaned_table_rows
  orphaned_table_rows = candidate_import.orphaned_table_rows
  orphaned_table_rows.each do |key, orphan_ids|
    expect(orphan_ids).to be_empty
  end
end
