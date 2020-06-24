# frozen_string_literal: true

# spec/jobs/email_job_spec.rb
require 'spec_helper'

describe CandidateImport do
  include ViewsHelpers
  include ActionDispatch::TestProcess
  include FileHelper

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
      every_event_names = AppFactory.add_confirmation_events

      filename = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
      uploaded_file = fixture_file_upload('Confirmation 2018 Group The Way test.xlsx', filename)
      candidate_import = CandidateImport.new
      success = candidate_import.load_initial_file(uploaded_file)
      unless success
        candidate_import.errors.messages.each do |error|
          puts error
        end
      end
      expect(success).to eq(true)

      expect_db(85, 0)

      the_way_candidates = Candidate.all.select do |c|
        c.candidate_sheet.attending == I18n.t('views.candidates.attending_the_way')
      end
      expect(the_way_candidates.size).to eq(83)
      chs_candidates = Candidate.all.select do |c|
        i18n = I18n.t('views.candidates.attending_catholic_high_school')
        c.candidate_sheet.attending == i18n
      end
      expect(chs_candidates.size).to eq(2)

      the_way_candidate = Candidate.find_by(account_name: 'dawannie')
      expect(the_way_candidate.candidate_sheet.first_name).to eq('Annie')
      expect(the_way_candidate.candidate_sheet.last_name).to eq('Daw')
      expect(the_way_candidate.candidate_sheet.grade).to eq(10)
      expect(the_way_candidate.candidate_sheet.program_year).to eq(2)
      expect(the_way_candidate.candidate_sheet.candidate_email).to eq('financial@kristoffs.com')
      expect(the_way_candidate.candidate_sheet.parent_email_1).to eq('retail@kristoffs.com')
      expect(the_way_candidate.candidate_sheet.parent_email_2).to eq('')
      expect(the_way_candidate.candidate_sheet.attending).to eq(I18n.t('views.candidates.attending_the_way'))

      chs_candidate = Candidate.find_by(account_name: 'clavijoabbie')
      expect(chs_candidate.candidate_sheet.first_name).to eq('Abbie')
      expect(chs_candidate.candidate_sheet.last_name).to eq('Clavijo')
      expect(chs_candidate.candidate_sheet.grade).to eq(10)
      expect(chs_candidate.candidate_sheet.program_year).to eq(2)
      expect(the_way_candidate.candidate_sheet.candidate_email).to eq('financial@kristoffs.com')
      expect(chs_candidate.candidate_sheet.parent_email_1).to eq('retail@kristoffs.com')
      expect(chs_candidate.candidate_sheet.parent_email_2).to eq('stmm-confirmation@kristoffs.com')
      expect(chs_candidate.candidate_sheet.attending).to eq(I18n.t('views.candidates.attending_catholic_high_school'))

      expect(the_way_candidates[0].candidate_events.size).to eq(every_event_names.size)
    end

    it 'import invalid spreadsheet will not update database' do
      uploaded_file = fixture_file_upload('Invalid.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      candidate_import = CandidateImport.new
      expect(candidate_import.load_initial_file(uploaded_file)).to eq(false)
      error_messages = [
        'Row 2: Last name can\'t be blank',
        'Row 3: First name can\'t be blank',
        'Row 5: Parent email 1 is an invalid email: @nc.rr.com',
        'Row 5: Parent email 2 is an invalid email: rannunz',
        'Row 6: Candidate email at least one email must be supplied.'
      ]
      candidate_import.errors.each_with_index do |candidate, index|
        expect(candidate[1]).to eq(error_messages[index])
      end
      expect(candidate_import.errors.size).to eq(5)
    end

    def image_column_value(candidate, columns)
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
      FactoryBot.create(:admin, account_name: 'AdminV', email: 'paul@kristoffs.com', name: 'Paul')
      FactoryBot.create(:admin, account_name: 'AdminP', email: 'vicki@kristoffs.com', name: 'Vicki')
      expect(Admin.all.size).to eq(2)

      CandidateImport.new.reset_database

      expect(Candidate.all.size).to eq(1)
      expect(Candidate.find_by(account_name: 'vickikristoff')).not_to eq(nil)
      expect(Admin.all.size).to eq(1)
      expect(Admin.find_by(email: Admin.first.email)).not_to eq(nil)
    end
  end

  describe 'orphaned associations errors' do
    it 'login should not cause orphaned associations' do
      FactoryBot.create(:candidate)
      expect_no_orphaned_associations
    end
  end

  describe 'orphaned associations' do
    it 'No orphaned associations' do
      FactoryBot.create(:candidate)
      expect_no_orphaned_associations
    end
    it 'orphaned associations' do
      orphans = expected_orphans

      FactoryBot.create(:candidate)
      candidate_import = CandidateImport.new
      # create orphans
      expect_ophans(candidate_import, orphans)
    end
    it 'destroy orphaned associations' do
      orphans = expected_orphans

      FactoryBot.create(:candidate)
      candidate_import = CandidateImport.new

      expect_ophans(candidate_import, orphans)

      candidate_import.remove_orphaned_table_rows
      candidate_import.add_orphaned_table_rows
      orphaned_table_rows = candidate_import.orphaned_table_rows

      orphaned_table_rows.each do |key, orphan_ids|
        expect(orphan_ids.size).to be(0), "There should be no orphaned rows for '#{key}': #{orphan_ids}"
      end
    end
  end

  it 'what do things look like when empty' do
    candidate = FactoryBot.create(:candidate, account_name: 'c1', password: 'asdfgthe')
    candidate.candidate_sheet.first_name = 'Paul'
    candidate.candidate_sheet.last_name = 'George'
    succ = candidate.save
    Rails.logger.info("succ=#{succ}")

    AppFactory.add_confirmation_events

    candidate_import = CandidateImport.new
    dir_name = 'temp'
    delete_dir(dir_name)
    begin
      Dir.mkdir(dir_name)
      package = candidate_import.to_xlsx(dir_name, true)
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

def expect_ophans(candidate_import, orphans)
  candidate_import.add_orphaned_table_rows
  orphaned_table_rows = candidate_import.orphaned_table_rows
  orphaned_table_rows.each do |key, orphan_ids|
    expect(orphan_ids.size).to be(1), "There should be only one orphaned row for '#{key}': #{orphan_ids}"
    expect(orphan_ids[0]).to be(orphans[key].id), "Id mismatch for '#{key}' orphan:#{orphan_ids[0]} expected:#{orphans[key].id}"
  end
end

def expected_orphans
  {
    # Candidate associations
    BaptismalCertificate: FactoryBot.create(:baptismal_certificate, skip_address_replacement: true),
    CandidateSheet: FactoryBot.create(:candidate_sheet),
    ChristianMinistry: FactoryBot.create(:christian_ministry),
    PickConfirmationName: FactoryBot.create(:pick_confirmation_name),
    RetreatVerification: FactoryBot.create(:retreat_verification),
    SponsorCovenant: FactoryBot.create(:sponsor_covenant),
    SponsorEligibility: FactoryBot.create(:sponsor_eligibility),
    # # other associations
    ScannedImage: FactoryBot.create(:scanned_image),
    Address: FactoryBot.create(:address),
    ToDo: FactoryBot.create(:to_do, confirmation_event_id: nil, candidate_event_id: nil)
  }
end

def expect_confirmation_event(event_key, way_date, chs_date)
  confirmation_event = ConfirmationEvent.find_by(event_key: event_key)
  expect(confirmation_event.the_way_due_date.to_s).to eq(way_date)
  expect(confirmation_event.chs_due_date.to_s).to eq(chs_date)
end

def expect_initial_conf_events
  today = Time.zone.today.to_s

  expect_confirmation_event(Candidate.parent_meeting_event_key, today, today)
  expect_confirmation_event(RetreatVerification.event_key, today, today)
  expect_confirmation_event(Candidate.covenant_agreement_event_key, today, today)
  expect_confirmation_event(CandidateSheet.event_key, today, today)
  expect_confirmation_event(BaptismalCertificate.event_key, today, today)
  expect_confirmation_event(SponsorCovenant.event_key, today, today)
  expect_confirmation_event(SponsorEligibility.event_key, today, today)
  expect_confirmation_event(PickConfirmationName.event_key, today, today)
  expect_confirmation_event(ChristianMinistry.event_key, today, today)

  return unless ConfirmationEvent.all.size != 9

  ConfirmationEvent.all.each { |x| puts x.name }
  expect(ConfirmationEvent.all.size).to eq(9), '"Wrong number of Confirmation Events" '
end

describe 'combinations' do
  it 'initial import followed by initial import should update and add' do
    FactoryBot.create(:admin)
    file_name = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    uploaded_file = fixture_file_upload('Initial candidates.xlsx', file_name)
    candidate_import = CandidateImport.new
    candidate_import.reset_database

    expect(save(candidate_import, uploaded_file)).to eq(true)

    expect_initial_conf_events
    expect(Candidate.all.size).to eq(4) # vicki + 3 import

    uploaded_file_updated = fixture_file_upload('Initial candidates update.xlsx', file_name)

    expect(save(candidate_import, uploaded_file_updated)).to eq(true)

    expect_initial_conf_events
    expect(Candidate.all.size).to eq(6) # vicki + 3 old import + 2 new from update
    expect_candidate(
      account_name: 'corganmakenzie',
      candidate_sheet: {
        first_name: 'Makenzie',
        last_name: 'Corgan',
        grade: 10,
        program_year: 2,
        attending: I18n.t('model.candidate.attending_catholic_high_school')
      }
    )
    expect_candidate(
      account_name: 'barrerocarlos',
      candidate_sheet: {
        first_name: 'Carlos',
        last_name: 'Barrero',
        grade: 11,
        program_year: 2,
        attending: I18n.t('model.candidate.attending_the_way')
      }
    )
    expect_candidate(
      account_name: 'agiusjulia',
      candidate_sheet: {
        first_name: 'Julia',
        last_name: 'Agius',
        grade: 10,
        program_year: 2,
        attending: I18n.t('model.candidate.attending_the_way')
      }
    )
    expect_candidate(
      account_name: 'brixeynoah',
      candidate_sheet: {
        first_name: 'Noah',
        last_name: 'Brixey',
        grade: 11,
        program_year: 2,
        attending: I18n.t('model.candidate.attending_catholic_high_school')
      }
    )
    expect_candidate(
      account_name: 'baronemaddy',
      candidate_sheet: {
        first_name: 'Maddy',
        last_name: 'Barone',
        grade: 10,
        program_year: 2,
        attending: I18n.t('model.candidate.attending_catholic_high_school')
      }
    )
  end
end

describe 'check_events' do
  include ViewsHelpers
  it 'should show "Sponsor Covenant" is missing.' do
    candidate_import = CandidateImport.new
    candidate_import.start_new_year
    setup_unknown_missing_events

    candidate_import.check_events

    expect(candidate_import.missing_confirmation_events.length).to be(1)
    expect(candidate_import.missing_confirmation_events[0]).to eq(SponsorCovenant.event_key)
    expect(candidate_import.found_confirmation_events.length).to be(AppFactory.all_i18n_confirmation_event_keys.length - 1)
    expect(candidate_import.unknown_confirmation_events.length).to be(1)
    expect(candidate_import.unknown_confirmation_events[0]).to eq('unknown event')
  end

  it 'should add "Sponsor Covenant".' do
    candidate_import = CandidateImport.new
    candidate_import.start_new_year
    setup_unknown_missing_events
    sponsor_covenant_event_key = SponsorCovenant.event_key

    candidate_import.add_missing_events([sponsor_covenant_event_key])

    expect(ConfirmationEvent.find_by(event_key: sponsor_covenant_event_key).event_key).to eq(sponsor_covenant_event_key)

    expect(candidate_import.missing_confirmation_events.length).to be(0)
    expect(candidate_import.found_confirmation_events.length).to be(AppFactory.all_i18n_confirmation_event_keys.length)
    expect(candidate_import.unknown_confirmation_events.length).to be(1)
    expect(candidate_import.unknown_confirmation_events[0]).to eq('unknown event')
  end
end

describe 'image_filename' do
  before(:each) do
    FactoryBot.create(:admin)
    CandidateImport.new.reset_database
    candidate = Candidate.first
    add_baptismal_certificate_image(candidate)
    add_retreat_verification_image(candidate)
    add_sponsor_covenant_image(candidate)
    add_sponsor_eligibility_image(candidate)
  end

  it 'should concat a file path for the scanned in file' do
    candidate = Candidate.find_by(account_name: 'vickikristoff')
    scanned_certificate = candidate.baptismal_certificate.scanned_certificate
    expected_msg = 'temp_dir/vickikristoff_scanned_certificate_actions.png'
    expect(CandidateImport.image_filepath_export(candidate,
                                                 'temp_dir',
                                                 'scanned_certificate',
                                                 scanned_certificate)).to eq(expected_msg)
    scanned_retreat = candidate.retreat_verification.scanned_retreat
    expected_msg = 'temp_dir/vickikristoff_scanned_retreat_actions.png'
    expect(CandidateImport.image_filepath_export(candidate, 'temp_dir', 'scanned_retreat', scanned_retreat)).to eq(expected_msg)
    scanned_eligibility = candidate.sponsor_eligibility.scanned_eligibility
    expected_msg = 'temp_dir/vickikristoff_scanned_eligibility_actions.png'
    candidate_import_image_filepath_export = CandidateImport.image_filepath_export(
      candidate, 'temp_dir', 'scanned_eligibility', scanned_eligibility
    )
    expect(candidate_import_image_filepath_export).to eq(expected_msg)
    expected_msg = 'temp_dir/vickikristoff_scanned_covenant_actions.png'
    scanned_covenant = candidate.sponsor_covenant.scanned_covenant
    expect(CandidateImport.image_filepath_export(candidate, 'temp_dir', 'scanned_covenant', scanned_covenant)).to eq(expected_msg)
  end

  it 'should handle filename being nil.' do
    candidate = Candidate.find_by(account_name: 'vickikristoff')
    candidate.baptismal_certificate.scanned_certificate = nil
    candidate.retreat_verification.scanned_retreat = nil
    candidate.sponsor_eligibility.scanned_eligibility = nil
    candidate.sponsor_covenant.scanned_covenant = nil
    expected_msg = 'temp_dir/vickikristoff_scanned_certificate_'
    expect(CandidateImport.image_filepath_export(candidate, 'temp_dir', 'scanned_certificate', nil)).to eq(expected_msg)
    expected_msg = 'temp_dir/vickikristoff_scanned_retreat_'
    expect(CandidateImport.image_filepath_export(candidate, 'temp_dir', 'scanned_retreat', nil)).to eq(expected_msg)
    expected_msg = 'temp_dir/vickikristoff_scanned_eligibility_'
    expect(CandidateImport.image_filepath_export(candidate, 'temp_dir', 'scanned_eligibility', nil)).to eq(expected_msg)
    expected_msg = 'temp_dir/vickikristoff_scanned_covenant_'
    expect(CandidateImport.image_filepath_export(candidate, 'temp_dir', 'scanned_covenant', nil)).to eq(expected_msg)
  end

  it 'should concat a file path for the scanned in file removing unnecessary directories from the filename' do
    candidate = Candidate.find_by(account_name: 'vickikristoff')
    candidate.baptismal_certificate.scanned_certificate = ScannedImage.new(filename: 'foo/actions.png')
    candidate.retreat_verification.scanned_retreat = ScannedImage.new(filename: 'foo/actions.png')
    candidate.sponsor_eligibility.scanned_eligibility = ScannedImage.new(filename: 'foo/actions.png')
    candidate.sponsor_covenant.scanned_covenant = ScannedImage.new(filename: 'foo/actions.png')
    expected = 'temp_dir/vickikristoff_scanned_certificate_actions.png'
    expect(CandidateImport.image_filepath_export(candidate, 'temp_dir', 'scanned_certificate',
                                                 candidate.baptismal_certificate.scanned_certificate)).to eq(expected)
    expected_msg = 'temp_dir/vickikristoff_scanned_retreat_actions.png'
    expect(CandidateImport.image_filepath_export(candidate, 'temp_dir', 'scanned_retreat',
                                                 candidate.retreat_verification.scanned_retreat)).to eq(expected_msg)
    expected_msg = 'temp_dir/vickikristoff_scanned_eligibility_actions.png'
    expect(CandidateImport.image_filepath_export(candidate, 'temp_dir', 'scanned_eligibility',
                                                 candidate.sponsor_eligibility.scanned_eligibility)).to eq(expected_msg)
    expected_msg = 'temp_dir/vickikristoff_scanned_covenant_actions.png'
    expect(CandidateImport.image_filepath_export(candidate, 'temp_dir', 'scanned_covenant',
                                                 candidate.sponsor_covenant.scanned_covenant)).to eq(expected_msg)
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

    cand_assoc = { Address: 0,
                   BaptismalCertificate: 0,
                   Candidate: 0,
                   CandidateEvent: 0,
                   CandidateSheet: 0,
                   ChristianMinistry: 0,
                   ConfirmationEvent: 9,
                   PickConfirmationName: 0,
                   RetreatVerification: 0,
                   SponsorCovenant: 0,
                   SponsorEligibility: 0,
                   ScannedImage: 0,
                   ToDo: 0 }

    expect_table_rows(Candidate, cand_assoc)

    candidate_import = CandidateImport.new

    c0 = FactoryBot.create(:candidate, add_new_confirmation_events: false)
    AppFactory.add_candidate_events(c0)
    c0.baptismal_certificate.scanned_certificate = create_scanned_image
    c0.retreat_verification.scanned_retreat = create_scanned_image
    c0.sponsor_covenant.scanned_covenant = create_scanned_image
    c0.sponsor_eligibility.scanned_eligibility = create_scanned_image
    c0.save

    c1 = FactoryBot.create(:candidate, account_name: 'c1', add_new_confirmation_events: false)
    AppFactory.add_candidate_events(c1)
    c1.save

    c2 = FactoryBot.create(:candidate, account_name: 'c2', add_new_confirmation_events: false)
    AppFactory.add_candidate_events(c2)
    c2.save

    expect(Admin.all.size).to eq(1)

    cand_assoc = { Address: 6,
                   BaptismalCertificate: 3,
                   Candidate: 3,
                   CandidateEvent: 27,
                   CandidateSheet: 3,
                   ChristianMinistry: 3,
                   ConfirmationEvent: 9,
                   PickConfirmationName: 3,
                   RetreatVerification: 3,
                   SponsorCovenant: 3,
                   SponsorEligibility: 3,
                   ScannedImage: 4,
                   ToDo: 27 }

    expect_table_rows(Candidate, cand_assoc)

    candidate_import.start_new_year

    expect(Admin.all.size).to eq(1)

    cand_assoc = { Address: 2,
                   BaptismalCertificate: 1,
                   Candidate: 1,
                   CandidateEvent: 9,
                   CandidateSheet: 1,
                   ChristianMinistry: 1,
                   ConfirmationEvent: 9,
                   PickConfirmationName: 1,
                   RetreatVerification: 1,
                   SponsorCovenant: 1,
                   SponsorEligibility: 1,
                   ScannedImage: 0,
                   ToDo: 9 }

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

    cand_assoc = { Address: 0,
                   BaptismalCertificate: 0,
                   Candidate: 0,
                   CandidateEvent: 0,
                   CandidateSheet: 0,
                   ChristianMinistry: 0,
                   ConfirmationEvent: 9,
                   PickConfirmationName: 0,
                   RetreatVerification: 0,
                   SponsorCovenant: 0,
                   SponsorEligibility: 0,
                   ScannedImage: 0,
                   ToDo: 0 }

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
    FactoryBot.create(:sponsor_eligibility)
    FactoryBot.create(:to_do)
    FactoryBot.create(:scanned_image)

    candidate_import = CandidateImport.new

    c0 = FactoryBot.create(:candidate, add_new_confirmation_events: false)
    AppFactory.add_candidate_events(c0)
    c0.save
    c1 = FactoryBot.create(:candidate, account_name: 'c1', add_new_confirmation_events: false)
    AppFactory.add_candidate_events(c1)
    c1.baptismal_certificate.scanned_certificate = create_scanned_image
    c1.save
    c2 = FactoryBot.create(:candidate, account_name: 'c2', add_new_confirmation_events: false)
    AppFactory.add_candidate_events(c2)
    c2.save

    expect(Admin.all.size).to eq(1)
    expect(ConfirmationEvent.all.size).to eq(9)
    expect(Candidate.all.size).to eq(3)

    cand_assoc = { Address: 9,
                   BaptismalCertificate: 4,
                   Candidate: 3,
                   CandidateEvent: 28,
                   CandidateSheet: 4,
                   ChristianMinistry: 4,
                   ConfirmationEvent: 9,
                   PickConfirmationName: 4,
                   RetreatVerification: 4,
                   SponsorCovenant: 4,
                   SponsorEligibility: 4,
                   ScannedImage: 4,
                   ToDo: 28 }

    expect_table_rows(Candidate, cand_assoc)

    candidate_import.start_new_year

    expect(Admin.all.size).to eq(1)
    expect(ConfirmationEvent.all.size).to eq(9)
    expect(Candidate.all.size).to eq(1) # vickikristoff the seed

    cand_assoc = { Address: 2,
                   BaptismalCertificate: 1,
                   Candidate: 1,
                   CandidateEvent: 9,
                   CandidateSheet: 1,
                   ChristianMinistry: 1,
                   ConfirmationEvent: 9,
                   PickConfirmationName: 1,
                   RetreatVerification: 1,
                   SponsorCovenant: 1,
                   SponsorEligibility: 1,
                   ScannedImage: 0,
                   ToDo: 9 }

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
  sponsor_eligibility = candidate.sponsor_eligibility
  sponsor_eligibility.build_scanned_eligibility
  sponsor_eligibility.scanned_eligibility.filename = filename
  sponsor_eligibility.scanned_eligibility.content_type = 'image/png'
  File.open(File.join('spec/fixtures/', filename), 'rb') do |f|
    sponsor_eligibility.scanned_eligibility.content = f.read
  end
  candidate.save
end

def expect_candidate(values)
  candidate = Candidate.find_by(account_name: values[:account_name])
  values.each_key do |key|
    value = values[key]
    if value.is_a? Hash
      candidate_sub = candidate.send(key)
      expect_keys(candidate_sub, value)
    elsif value.is_a? Array
      candidate_subs = candidate.send(key)
      expect(candidate_subs.size).to eq(value.size)
      value.each_with_index do |sub_values, index|
        # puts "Name: #{candidate_subs[index].confirmation_event.event_key}"
        expect_keys(candidate_subs[index], sub_values)
      end
    else
      expect(candidate.send(key)).to eq(value)
    end
  end
  expect(candidate.candidate_events.size).to eq(all_event_keys.size)
end

def expect_candidates(wks, candidate_import)
  header_row = wks.rows[0]
  candidate_import.xlsx_columns.each_with_index do |column_name, index|
    # puts "#{index}:#{header_row.cells[index].value}"
    expect(header_row.cells[index].value).to eq(column_name)
  end
  c1_row = wks.rows[1]
  c2_row = wks.rows[2]
  c3_row = wks.rows[3]
  (1..wks.rows.size - 1).each do |i|
    account_name = wks.rows[i].cells[find_cell_offset(header_row, 'account_name')].value
    # puts account_name
    c1_row = wks.rows[i] if account_name == 'c1'
    c2_row = wks.rows[i] if account_name == 'c2'
    c3_row = wks.rows[i] if account_name == 'c3'
  end

  expect(c1_row.cells[find_cell_offset(header_row, 'account_name')].value).to eq('c1')
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.first_name')].value).to eq('Sophia')
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.middle_name')].value).to eq('Saraha')
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.last_name')].value).to eq('Agusta')
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.candidate_email')].value).to eq('candiate@example.com')
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.parent_email_1')].value).to eq('test@example.com')
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.parent_email_2')].value).to eq('')
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.grade')].value).to eq(10)
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.program_year')].value).to eq(2)
  expected_msg = I18n.t('model.candidate.attending_the_way')
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.attending')].value).to eq(expected_msg)
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.address.street_1')].value).to eq('2120 Frissell Ave.')
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.address.street_2')].value).to eq('Apt. 456')
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.address.city')].value).to eq('Apex')
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.address.state')].value).to eq('NC')
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.address.zip_code')].value).to eq(27_502)

  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.birth_date')].value.to_s).to eq('1983-08-20')
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.baptismal_date')].value.to_s).to eq('1983-10-20')
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.church_name')].value).to eq('St. Francis')
  column_name = 'baptismal_certificate.church_address.street_1'
  expect(c1_row.cells[find_cell_offset(header_row, column_name)].value).to eq('1313 Magdalene Way')
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.church_address.street_2')].value).to eq('Apt. 456')
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.church_address.city')].value).to eq('Apex')
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.church_address.state')].value).to eq('NC')
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.church_address.zip_code')].value).to eq(27_502)
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.father_first')].value).to eq('George')
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.father_middle')].value).to eq('Paul')
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.father_last')].value).to eq('Smith')
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.mother_first')].value).to eq('Georgette')
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.mother_middle')].value).to eq('Paula')
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.mother_maiden')].value).to eq('Kirk')
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.mother_last')].value).to eq('Smith')
  expected_msg = 'actions.png:::png:::temp/c1_scanned_certificate_actions.png'
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.scanned_certificate')].value).to eq(expected_msg)
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.first_comm_at_home_parish')].value).to eq(0)
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.show_empty_radio')].value).to eq(0)

  expect(c1_row.cells[find_cell_offset(header_row, 'retreat_verification.retreat_held_at_home_parish')].value).to eq(0)
  expect(c1_row.cells[find_cell_offset(header_row, 'retreat_verification.start_date')].value).to eq(nil)
  expect(c1_row.cells[find_cell_offset(header_row, 'retreat_verification.end_date')].value).to eq(nil)
  expect(c1_row.cells[find_cell_offset(header_row, 'retreat_verification.who_held_retreat')].value).to eq(nil)
  expect(c1_row.cells[find_cell_offset(header_row, 'retreat_verification.where_held_retreat')].value).to eq(nil)
  expect(c1_row.cells[find_cell_offset(header_row, 'retreat_verification.scanned_retreat')].value).to eq(nil)

  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_events.0.completed_date')].value).to eq(nil)
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_events.0.verified')].value).to eq(0)

  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_events.1.completed_date')].value).to eq(nil)
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_events.1.verified')].value).to eq(0)

  expect(c1_row.size).to eq(68)

  expect(c2_row.cells[0].value).to eq('c2')

  expect(c3_row.cells[0].value).to eq('c3')
end

def expect_candidates_empty(wks, candidate_import)
  header_row = wks.rows[0]
  candidate_import.xlsx_columns.each_with_index do |column_name, index|
    # puts "#{index}:#{header_row.cells[index].value}"
    expect(header_row.cells[index].value).to eq(column_name)
  end
  trans_col = CandidateImport.transient_columns
  header_row.cells.each do |cell|
    expect(trans_col.include?(cell.value)).to eq(false), "Should not find transient column: #{cell.value}"
  end
  c1_row = wks.rows[1]
  (1..wks.rows.size - 1).each do |i|
    account_name = wks.rows[i].cells[find_cell_offset(header_row, 'account_name')].value
    # puts account_name
    c1_row = wks.rows[i] if account_name == 'c1'
  end

  expect(c1_row.cells[find_cell_offset(header_row, 'account_name')].value).to eq('c1')
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_note')].value).to eq('Admin note')
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.first_name')].value).to eq('Paul')
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.middle_name')].value).to eq('Saraha')
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.last_name')].value).to eq('George')
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.candidate_email')].value).to eq('')
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.parent_email_1')].value).to eq('test@example.com')
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.parent_email_2')].value).to eq('')
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.grade')].value).to eq(10)
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.program_year')].value).to eq(2)
  expected_msg = I18n.t('model.candidate.attending_the_way')
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.attending')].value).to eq(expected_msg)
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.address.street_1')].value).to eq('2120 Frissell Ave.')
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.address.street_2')].value).to eq('Apt. 456')
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.address.city')].value).to eq('Apex')
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.address.state')].value).to eq('NC')
  expect(c1_row.cells[find_cell_offset(header_row, 'candidate_sheet.address.zip_code')].value).to eq(27_502)
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.birth_date')].value.to_s).to eq('')
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.baptismal_date')].value.to_s).to eq('')
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.church_name')].value).to eq(nil)
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.church_address.street_1')].value).to eq('')
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.church_address.street_2')].value).to eq('')
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.church_address.city')].value).to eq('')
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.church_address.state')].value).to eq('')
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.church_address.zip_code')].value).to eq('')
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.father_middle')].value).to eq(nil)
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.father_last')].value).to eq(nil)
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.mother_first')].value).to eq(nil)
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.mother_middle')].value).to eq(nil)
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.mother_maiden')].value).to eq(nil)
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.mother_last')].value).to eq(nil)
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.scanned_certificate')].value).to eq(0)
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.baptized_at_home_parish')].value).to eq(0)
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.first_comm_at_home_parish')].value).to eq(0)
  expect(c1_row.cells[find_cell_offset(header_row, 'baptismal_certificate.show_empty_radio')].value).to eq(0)

  expect(c1_row.cells[find_cell_offset(header_row, 'retreat_verification.retreat_held_at_home_parish')].value).to eq(0)
  expect(c1_row.cells[find_cell_offset(header_row, 'retreat_verification.start_date')].value).to eq(nil)
  expect(c1_row.cells[find_cell_offset(header_row, 'retreat_verification.end_date')].value).to eq(nil)
  expect(c1_row.cells[find_cell_offset(header_row, 'retreat_verification.who_held_retreat')].value).to eq(nil)
  expect(c1_row.cells[find_cell_offset(header_row, 'retreat_verification.where_held_retreat')].value).to eq(nil)
  expect(c1_row.cells[find_cell_offset(header_row, 'retreat_verification.scanned_retreat')].value).to eq(0)

  (0..ConfirmationEvent.all.length - 1).each do |index|
    expect(c1_row.cells[find_cell_offset(header_row, "candidate_events.#{index}.completed_date")].value).to eq(nil)
    expect(c1_row.cells[find_cell_offset(header_row, "candidate_events.#{index}.verified")].value).to eq(0)
  end
  expect(c1_row.size).to eq(74)
end

def expect_confirmation_events_empty(wks, candidate_import)
  header_row = wks.rows[0]
  expect(header_row.cells.size).to eq(5)
  candidate_import.xlsx_conf_event_columns.each_with_index do |column_name, index|
    expect(header_row.cells[index].value).to eq(column_name)
  end
  events_in_order = ConfirmationEvent.order(:event_key)
  expect(wks.rows.size).to eq(events_in_order.size + 1)

  events_in_order.each_with_index do |event, index|
    row = wks.rows[index + 1]
    expect(row.cells.size).to eq(5)
    # puts row.cells[0].value
    expect(row.cells[0].value).to eq(event.event_key)
    expect(row.cells[1].value).to eq(index)
    expect(row.cells[2].value.to_s).to eq(Time.zone.today.to_s)
    expect(row.cells[3].value.to_s).to eq(Time.zone.today.to_s)
    expect(row.cells[4].value.to_s).to eq('')
  end
end

def expect_confirmation_events(wks, candidate_import)
  header_row = wks.rows[0]
  expect(header_row.cells.size).to eq(5)
  candidate_import.xlsx_conf_event_columns.each_with_index do |column_name, index|
    expect(header_row.cells[index].value).to eq(column_name)
  end
  events_in_order = ConfirmationEvent.order(:name)
  expect(wks.rows.size).to eq(events_in_order.size + 1)

  events_in_order.each_with_index do |confirmation_event, index|
    row = wks.rows[index + 1]
    expect(row.cells.size).to eq(5)
    # puts row.cells[0].value
    expect(row.cells[0].value).to eq(confirmation_event.event_key)
    expect(row.cells[1].value).to eq(index)
    expect(row.cells[2].value.to_s).to eq(confirmation_event.the_way_due_date.to_s)
    expect(row.cells[3].value.to_s).to eq(confirmation_event.chs_due_date.to_s)
    expect(row.cells[4].value.to_s).to eq(confirmation_event.instructions)
  end
end

def expect_import_with_events
  expect_confirmation_event(Candidate.parent_meeting_event_key, '2016-06-30', '2016-06-03')
  expect_confirmation_event(RetreatVerification.event_key, '2016-05-31', '2016-05-03')
  expect_confirmation_event(Candidate.covenant_agreement_event_key, '2016-07-31', '2016-07-13')
  expect_confirmation_event(CandidateSheet.event_key, '2016-02-29', '2016-02-16')
  expect_confirmation_event(BaptismalCertificate.event_key, '2016-08-31', '2016-08-12')
  expect_confirmation_event(SponsorCovenant.event_key, '2016-10-31', '2016-10-15')
  expect_confirmation_event(SponsorEligibility.event_key, '2016-10-31', '2016-10-15')
  expect_confirmation_event(PickConfirmationName.event_key, '2016-11-30', '2016-11-20')
  expect_confirmation_event(ChristianMinistry.event_key, '2017-01-31', '2017-01-22')

  ConfirmationEvent.all.each { |x| puts x.name } if ConfirmationEvent.all.size != 9

  expect(ConfirmationEvent.all.size).to eq(9)

  confirmation_event2 = ConfirmationEvent.find_by(name: RetreatVerification.event_key)
  expect(confirmation_event2.the_way_due_date.to_s).to eq('2016-05-31')
  expect(confirmation_event2.chs_due_date.to_s).to eq('2016-05-03')
  expected_msg = "<h1>a heading</h1>\n<ul>\n<li>step 1</li>\n<li>step 2</li>\n</ul>\n<p> </p>\n<p> </p>"
  expect(confirmation_event2.instructions).to eq(expected_msg)

  expect(Candidate.all.size).to eq(3)
  expect_candidate(vicki_kristoff)
  expect_candidate(paul_kristoff)
  expect_candidate(foo_bar)
end

def expect_keys(obj, attributes)
  attributes.each_key do |sub_key|
    # puts obj.class
    # puts "#{obj.first_name}" if obj.class.to_s == 'CandidateSheet'
    # puts "#{obj.confirmation_event.event_key}:#{sub_key}" if obj.class.to_s == 'CandidateSheet'
    if attributes[sub_key].is_a?(Hash)
      expect_keys(obj.send(sub_key), attributes[sub_key])
    else
      expect(obj.send(sub_key).to_s).to eq(attributes[sub_key].to_s)
    end
  end
end

def expect_table_rows(clazz, expected_sizes, checked = [], do_not_include = [Admin])
  top = checked == []
  class_sym = clazz.to_s.to_sym
  unless checked.include?(class_sym) || do_not_include.include?(clazz)
    checked << class_sym
    expected = "Association(#{clazz}) size #{clazz.all.size} does mot match expected size #{expected_sizes[class_sym]}"
    expect(clazz.all.size).to eq(expected_sizes[class_sym]), expected
    clazz.reflect_on_all_associations.each do |assoc_reflect|
      assoc_class = assoc_reflect.klass
      expect_table_rows(assoc_class, expected_sizes, checked)
    end
  end
  return unless top

  unless checked.size == expected_sizes.size
    puts checked
    puts expected_sizes
  end
  expect(checked.size).to eq(expected_sizes.size)
end

def find_cell_offset(header_row, column_name)
  index = -1
  header_row.find do |cell|
    index += 1
    cell.value == column_name
  end
  index
end

def all_event_keys
  config = YAML.load_file('config/locales/en.yml')
  every_event_keys = []
  config['en']['events'].each do |event_key_entry|
    every_event_keys << "events.#{event_key_entry[0]}"
  end
  every_event_keys
end

def foo_bar
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
      program_year: 2,
      attending: I18n.t('model.candidate.attending_the_way'),
      address: {
        street_1: '',
        street_2: 'street 2',
        city: 'Clarksville',
        state: 'IN',
        zip_code: '47129'
      }
    },
    candidate_events_sorted: [
      { completed_date: '', # Fill Out Candidate Information Sheet 2/29/16
        name: CandidateSheet.event_key,
        due_date: '2016-02-29',
        verified: false },
      { completed_date: '', # Attend Retreat 5/31/16
        name: RetreatVerification.event_key,
        due_date: '2016-05-31',
        verified: false },
      { completed_date: '', # Parent Information Meeting 6/30/16
        name: Candidate.parent_meeting_event_key,
        due_date: '2016-06-30',
        verified: false },
      { completed_date: '', # Sign Agreement 7/31/2016
        name: Candidate.covenant_agreement_event_key,
        due_date: '2016-07-31',
        verified: false },
      { completed_date: '', # Baptismal Certificate 8/31/16
        name: BaptismalCertificate.event_key,
        due_date: '2016-08-31',
        verified: false },
      { completed_date: '', # Christian Ministry Awareness 1/31/17
        name: ChristianMinistry.event_key,
        due_date: '2017-01-31',
        verified: false },
      { completed_date: '2017-01-01', # Sponsor Covenant 10/31/16
        name: SponsorCovenant.event_key,
        due_date: '2016-10-31',
        verified: false },
      { completed_date: '2017-01-01', # Sponsor Eligibility 10/31/16
        name: SponsorEligibility.event_key,
        due_date: '2016-10-31',
        verified: false },
      { completed_date: '2016-12-25', # Confirmation Name
        name: PickConfirmationName.event_key,
        due_date: '2016-11-30',
        verified: true }
    ]
  }
end

def paul_kristoff
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
      program_year: 1,
      attending: I18n.t('model.candidate.attending_the_way'),
      address: {
        street_1: '2116 Frissell Ave',
        street_2: '',
        city: 'Cary',
        state: 'NC',
        zip_code: '27555'
      }
    },
    candidate_events_sorted: [
      { completed_date: '', # Fill Out Candidate Information Sheet 2/29/16
        name: CandidateSheet.event_key,
        due_date: '2016-02-29',
        verified: false },
      { completed_date: '', # Sign Agreement 7/31/16
        name: Candidate.covenant_agreement_event_key,
        due_date: '2016-07-31',
        verified: false },
      { completed_date: '', #  Baptismal Certificate 8/31/16
        name: BaptismalCertificate.event_key,
        due_date: '2016-08-31',
        verified: false },
      { completed_date: '', # Sponsor Covenant 10/31/16
        name: SponsorCovenant.event_key,
        due_date: '2016-10-31',
        verified: false },
      { completed_date: '', # Sponsor Eligibility 10/31/16
        name: SponsorEligibility.event_key,
        due_date: '2016-10-31',
        verified: false },
      { completed_date: '', # Confirmation Name
        name: PickConfirmationName.event_key,
        due_date: '2016-11-30',
        verified: false },
      { completed_date: '', # Christian Ministry Awareness 1/31/17
        name: ChristianMinistry.event_key,
        due_date: '2017-01-31',
        verified: false },
      { name: RetreatVerification.event_key,
        completed_date: '2016-05-02', # Attend Retreat 5/31/16
        due_date: '2016-05-31',
        verified: true },
      { name: Candidate.parent_meeting_event_key,
        completed_date: '2016-07-07', # Parent Information Meeting 6/30/16
        due_date: '2016-06-30',
        verified: false }
    ]
  }
end

def vicki_kristoff
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
      program_year: 2,
      attending: I18n.t('model.candidate.attending_catholic_high_school'),
      address: {
        street_1: '2120 Frissell Ave',
        street_2: '',
        city: 'Apex',
        state: 'NC',
        zip_code: '27502'
      }
    },
    candidate_events_sorted: [
      { completed_date: '', # Fill Out Candidate Information Sheet
        name: CandidateSheet.event_key,
        due_date: '2016-02-16',
        verified: false },
      { completed_date: '', # Attend Retreat
        name: RetreatVerification.event_key,
        due_date: '2016-05-03',
        verified: false },
      { completed_date: '', # Parent Information Meeting
        name: Candidate.parent_meeting_event_key,
        due_date: '2016-06-03',
        verified: false },
      { completed_date: '', # Baptismal Certificate
        name: BaptismalCertificate.event_key,
        due_date: '2016-08-12',
        verified: false },
      { completed_date: '', # Sponsor Covenant
        name: SponsorCovenant.event_key,
        due_date: '2016-10-15',
        verified: false },
      { completed_date: '', # Sponsor Eligibility
        name: SponsorEligibility.event_key,
        due_date: '2016-10-15',
        verified: false },
      { completed_date: '', # Confirmation Name
        name: PickConfirmationName.event_key,
        due_date: '2016-11-20',
        verified: false },
      { completed_date: '', # Christian Ministry Awareness 1/31/17
        name: ChristianMinistry.event_key,
        due_date: '2017-01-22',
        verified: false },
      { completed_date: '2016-06-06', # Sign Agreement
        name: Candidate.covenant_agreement_event_key,
        due_date: '2016-07-13',
        verified: true }
    ]
  }
end

def clean_dir(dir)
  return unless Dir.exist?(dir)

  Dir.foreach(dir) do |entry|
    unless ['.', '..'].include?(entry)
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

def expect_image_values(candidate, image_column_mapping_key, image_filename)
  value_methods = @image_column_mappings[image_column_mapping_key]
  expect(image_column_value(candidate, "#{value_methods}.filename")).to eq(image_filename)
  expect(image_column_value(candidate, "#{value_methods}.content_type")).to eq('image/png')
  expect(image_column_value(candidate, "#{value_methods}.content")).not_to eq(nil)
end

def save(candidate_import, uploaded_file)
  import_result = candidate_import.load_initial_file(uploaded_file)
  candidate_import.errors.each do |candidate|
    raise "Errors:  #{candidate[1]}"
  end
  import_result
end

def expect_no_orphaned_associations
  candidate_import = CandidateImport.new
  candidate_import.add_orphaned_table_rows
  orphaned_table_rows = candidate_import.orphaned_table_rows
  orphaned_table_rows.each do |_key, orphan_ids|
    expect(orphan_ids).to be_empty
  end
end
