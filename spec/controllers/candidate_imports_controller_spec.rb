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

    it 'import candidates with invalid excel file' do
      login_admin
      uploaded_file = fixture_file_upload('Invalid.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      post :import_candidates, params: { candidate_import: { file: uploaded_file } }
      expect(controller.candidate_import).not_to be_nil
      expect(controller.flash[:alert]).to eq('annunziatarobert: Grade should be between 9 & 12')
      expect(controller.candidate_import.errors.size).to eq(0)
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

  private

  def expect_event_association_local(assoc_from_candidate)
    event_assoc = assoc_from_candidate.class.all
    expect(event_assoc.size).to eq(1)
    expect(assoc_from_candidate).to eq(event_assoc.first)
  end
end
