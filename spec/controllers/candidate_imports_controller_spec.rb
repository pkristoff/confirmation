# frozen_string_literal: true

describe CandidateImportsController do
  before do
    AppFactory.generate_default_status
  end

  describe 'new' do
    it 'fail authentication' do
      login_candidate
      get :new
      expect(response).to redirect_to(new_admin_session_path)
      expect(controller.candidate_import).to be_nil
    end

    it 'create a new CandidateImport' do
      login_admin
      get :new
      # expect(response).to render_template('new')
      expect(response.status).to eq(200)
      expect(controller.candidate_import).not_to be_nil
    end

    it 'the spread sheet reflect what the candidate has input - sponsor - 0' do
      c1 = FactoryBot.create(:candidate, account_name: 'a1')
      c1.sponsor_covenant.sponsor_name = 'Baz'
      c1.sponsor_eligibility.sponsor_attends_home_parish = true
      c1.sponsor_covenant.scanned_covenant = ScannedImage.new
      c1.save

      candidate_import = CandidateImport.new
      excel = candidate_import.to_xlsx('dir', from_spec: true)

      excel.workbook do |wb|
        ['Confirmation Events', 'Candidates with events'].each_with_index do |expected_name, index|
          expect(wb.worksheets[index].name).to eq(expected_name)
        end

        worksheet = wb.worksheets[1]
        a1_row = worksheet.rows[1]
        expect(value_for_header(wb.worksheets[1], 'account_name', a1_row)).to eq('a1')
        expect(value_for_header(wb.worksheets[1], 'sponsor_covenant.sponsor_name', a1_row)).to eq('Baz')
        expect(value_for_header(wb.worksheets[1], 'sponsor_covenant.scanned_covenant', a1_row)).to eq(1)
        expect(value_for_header(wb.worksheets[1], 'sponsor_eligibility.sponsor_attends_home_parish', a1_row)).to eq(1)
        expect(value_for_header(wb.worksheets[1], 'sponsor_eligibility.sponsor_church', a1_row)).to eq('')
        expect(value_for_header(wb.worksheets[1], 'sponsor_eligibility.scanned_eligibility', a1_row)).to eq(0)
      end
    end

    it 'the spread sheet reflect what the candidate has input - sponsor - 1' do
      c1 = FactoryBot.create(:candidate, account_name: 'a1')
      c1.sponsor_covenant.sponsor_name = 'Baz'
      c1.sponsor_eligibility.sponsor_attends_home_parish = false
      c1.sponsor_covenant.scanned_covenant = ScannedImage.new
      c1.sponsor_eligibility.sponsor_church = 'St. George'
      c1.sponsor_eligibility.scanned_eligibility = ScannedImage.new
      c1.save

      candidate_import = CandidateImport.new
      excel = candidate_import.to_xlsx('dir', from_spec: true)

      excel.workbook do |wb|
        ['Confirmation Events', 'Candidates with events'].each_with_index do |expected_name, index|
          expect(wb.worksheets[index].name).to eq(expected_name)
        end

        worksheet = wb.worksheets[1]
        a1_row = worksheet.rows[1]
        expect(value_for_header(wb.worksheets[1], 'account_name', a1_row)).to eq('a1')
        expect(value_for_header(wb.worksheets[1], 'sponsor_covenant.sponsor_name', a1_row)).to eq('Baz')
        expect(value_for_header(wb.worksheets[1], 'sponsor_covenant.scanned_covenant', a1_row)).to eq(1)
        expect(value_for_header(wb.worksheets[1], 'sponsor_eligibility.sponsor_attends_home_parish', a1_row)).to eq(0)
        expect(value_for_header(wb.worksheets[1], 'sponsor_eligibility.sponsor_church', a1_row)).to eq('St. George')
        expect(value_for_header(wb.worksheets[1], 'sponsor_eligibility.scanned_eligibility', a1_row)).to eq(1)
      end
    end

    private

    def value_for_header(worksheet, header, row)
      index = worksheet.rows.first.index { |el| el.value == header }
      row[index].value
    end
  end

  describe 'create' do
    it 'fail authentication' do
      login_candidate
      post :import_candidates
      expect(response).to redirect_to(new_admin_session_path)
      expect(controller.candidate_import).to be_nil
    end

    it 'import candidates with valid excel file' do
      login_admin
      uploaded_file = fixture_file_upload('Small.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      post :import_candidates, params: { candidate_import: { file: uploaded_file } }
      expect(controller.candidate_import).not_to be_nil
      expect(controller.candidate_import.errors.size).to eq(0)
    end

    it 'import candidates with invalid excel file: last name can\'t be blank' do
      login_admin
      uploaded_file = fixture_file_upload('/Import candidates tests/Invalid.xlsx',
                                          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      post :import_candidates, params: { candidate_import: { file: uploaded_file } }
      expect(controller.candidate_import).not_to be_nil
      expect(controller.flash[:alert]).to eq('Validation failed: Last name can\'t be blank')
      expect(controller.candidate_import.errors.size).to eq(0)
    end

    it 'import candidates with invalid excel file: illegal attending' do
      login_admin
      uploaded_file = fixture_file_upload('/Import candidates tests/Test upload illegal attending.xlsx',
                                          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      post :import_candidates, params: { candidate_import: { file: uploaded_file } }
      expect(controller.candidate_import).not_to be_nil
      expect(controller.flash[:alert]).to eq('donethpeyton Illegal Attending value: The foo')
      expect(controller.candidate_import.errors.size).to eq(0)
    end

    it 'import candidates with invalid excel file: illegal grade' do
      login_admin
      uploaded_file = fixture_file_upload('/Import candidates tests/Test upload illegal grade.xlsx',
                                          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      post :import_candidates, params: { candidate_import: { file: uploaded_file } }
      expect(controller.candidate_import).not_to be_nil
      expect(controller.flash[:alert]).to eq('donethpeyton Illegal grade=5.  It should be between 9 & 12')
      expect(controller.candidate_import.errors.size).to eq(0)
    end

    it 'import candidates with invalid excel file: illegal program year' do
      login_admin
      uploaded_file = fixture_file_upload('/Import candidates tests/Test upload Illegal program year.xlsx',
                                          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      post :import_candidates, params: { candidate_import: { file: uploaded_file } }
      expect(controller.candidate_import).not_to be_nil
      expect(controller.flash[:alert]).to eq('donethpeyton program year should be 1 or 2 : 3')
      expect(controller.candidate_import.errors.size).to eq(0)
    end

    it 'import candidates with invalid excel file: illegal status' do
      login_admin
      uploaded_file = fixture_file_upload('/Import candidates tests/Test upload illegal status.xlsx',
                                          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      post :import_candidates, params: { candidate_import: { file: uploaded_file } }
      expect(controller.candidate_import).not_to be_nil
      expect(controller.flash[:alert]).to eq('donethpeyton Illegal status: Foo')
      expect(controller.candidate_import.errors.size).to eq(0)
    end

    it 'import candidates with invalid excel file: missing email' do
      login_admin
      uploaded_file = fixture_file_upload('/Import candidates tests/Test upload missing email.xlsx',
                                          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      post :import_candidates, params: { candidate_import: { file: uploaded_file } }
      expect(controller.candidate_import).not_to be_nil
      error_message = 'Row 2: Candidate email at least one email must be supplied.'
      expect(controller.candidate_import.errors.full_messages[0]).to eq(error_message)
      expect(controller.candidate_import.errors.size).to eq(1)
    end

    it 'import candidates with invalid excel file: missing first name' do
      login_admin
      uploaded_file = fixture_file_upload('/Import candidates tests/Test upload missing first name.xlsx',
                                          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      post :import_candidates, params: { candidate_import: { file: uploaded_file } }
      expect(controller.candidate_import).not_to be_nil
      expect(controller.flash[:alert]).to eq('Validation failed: First_name can\'t be blank')
      expect(controller.candidate_import.errors.size).to eq(0)
    end

    it 'import candidates with invalid excel file: missing grade' do
      login_admin
      uploaded_file = fixture_file_upload('/Import candidates tests/Test upload missing grade.xlsx',
                                          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      post :import_candidates, params: { candidate_import: { file: uploaded_file } }
      expect(controller.candidate_import).not_to be_nil
      expect(controller.flash[:alert]).to eq('donethpeyton: Grade should be between 9 & 12')
      expect(controller.candidate_import.errors.size).to eq(0)
    end

    it 'import candidates with invalid excel file: missing last name' do
      login_admin
      uploaded_file = fixture_file_upload('/Import candidates tests/Test upload missing last name.xlsx',
                                          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      post :import_candidates, params: { candidate_import: { file: uploaded_file } }
      expect(controller.candidate_import).not_to be_nil
      expect(controller.flash[:alert]).to eq('Validation failed: Last name can\'t be blank')
      expect(controller.candidate_import.errors.size).to eq(0)
    end

    it 'import candidates with invalid excel file: missing program year' do
      login_admin
      uploaded_file = fixture_file_upload('/Import candidates tests/Test upload missing program year.xlsx',
                                          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      post :import_candidates, params: { candidate_import: { file: uploaded_file } }
      expect(controller.candidate_import).not_to be_nil
      expect(controller.flash[:alert]).to eq('donethpeyton program year cannot blank')
      expect(controller.candidate_import.errors.size).to eq(0)
    end

    it 'import candidates with invalid excel file: missing status' do
      login_admin
      uploaded_file = fixture_file_upload('/Import candidates tests/Test upload missing status.xlsx',
                                          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      post :import_candidates, params: { candidate_import: { file: uploaded_file } }
      expect(controller.candidate_import).not_to be_nil
      expect(controller.flash[:alert]).to eq('donethpeyton Status cannot be blank.')
      expect(controller.candidate_import.errors.size).to eq(0)
    end

    it 'import candidates existing middle_name' do
      cand = FactoryBot.create(:candidate)
      expect(cand.candidate_sheet.middle_name).to eq('Saraha')
      login_admin
      uploaded_file = fixture_file_upload('/Import candidates tests/Existing Middle name.xlsx',
                                          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      post :import_candidates, params: { candidate_import: { file: uploaded_file } }
      expect(controller.candidate_import).not_to be_nil
      expect(controller.candidate_import.errors.size).to eq(0)
      cand = Candidate.first
      expect(cand.candidate_sheet.middle_name).to eq('Saraha')
    end
  end

  describe 'export_to_excel' do
    it 'bad commit.' do
      login_admin

      FactoryBot.create(:candidate, account_name: 'a1')
      FactoryBot.create(:candidate, account_name: 'a2')
      FactoryBot.create(:candidate, account_name: 'a3')

      post :export_to_excel, params: { commit: 'bad commit', format: 'xlsx' }

      expect(response.body).to have_link('', href: 'http://test.host/candidate_imports/new')
    end
  end
end
