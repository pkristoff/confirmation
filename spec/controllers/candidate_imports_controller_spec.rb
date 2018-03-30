# frozen_string_literal: true

describe CandidateImportsController do
  describe 'new' do
    it 'should fail authentication' do
      login_candidate
      get :new
      expect(response).to redirect_to(new_admin_session_path)
      expect(controller.candidate_import).to eq(nil)
    end

    it 'should create a new CandidateImport' do
      login_admin
      get :new
      expect(response).to render_template('new')
      expect(response.status).to eq(200)
      expect(controller.candidate_import).not_to eq(nil)
    end
  end

  describe 'create' do
    it 'should fail authentication' do
      login_candidate
      get :create
      expect(response).to redirect_to(new_admin_session_path)
      expect(controller.candidate_import).to eq(nil)
    end

    it 'should import candidates with valid excel file' do
      login_admin
      uploaded_file = fixture_file_upload('Small.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      get :create, ActionController::Parameters.new(candidate_import: ActionController::Parameters.new(file: uploaded_file))
      expect(response).to redirect_to(root_url)
      expect(controller.candidate_import).not_to eq(nil)
      expect(controller.candidate_import.errors.size).to eq(0)
    end

    it 'should import candidates with invalid excel file' do
      login_admin
      uploaded_file = fixture_file_upload('Invalid.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      get :create, ActionController::Parameters.new(candidate_import: ActionController::Parameters.new(file: uploaded_file))
      expect(response).to render_template('new')
      expect(controller.candidate_import).not_to eq(nil)
      expect(controller.candidate_import.errors.size).to eq(4)
    end
  end

  describe 'start_new_year' do
    it 'should remove all candidates, changes due date to today, and adds a seed candidate' do
      expect(Candidate.all.size).to eq(0)
      FactoryBot.create(:candidate, account_name: 'a1')
      FactoryBot.create(:candidate, account_name: 'a2')
      FactoryBot.create(:candidate, account_name: 'a3')
      expect(Candidate.all.size).to eq(3)
      login_admin

      post :start_new_year

      expect(response).to redirect_to(root_url)
      expect(Candidate.find_by(account_name: 'vickikristoff')).not_to be(nil), 'Could not find candidate seed: vickikristoff'
      expect(Candidate.all.size).to eq(1), "Should only have the candidate seed: #{Candidate.all.size}"
      expect(ConfirmationEvent.all.size).not_to eq(0)
      ConfirmationEvent.all.each do |ce|
        expect(ce.chs_due_date).to eq(Date.today)
        expect(ce.the_way_due_date).to eq(Date.today)
      end
    end
  end

  describe 'reset_database' do
    it 'should reset database' do
      expect(Candidate.all.size).to eq(0)
      FactoryBot.create(:candidate, account_name: 'a1')
      FactoryBot.create(:candidate, account_name: 'a2')
      FactoryBot.create(:candidate, account_name: 'a3')
      expect(Candidate.all.size).to eq(3)
      login_admin

      expect(Admin.all.size).to eq(1)
      FactoryBot.create(:admin, email: 'paul@kristoffs.com', name: 'Paul')
      expect(Admin.all.size).to eq(2)

      post :reset_database

      expect(response).to redirect_to(root_url)
      candidates = Candidate.all
      expect(candidates.size).to eq(1)

      candidate = candidates.first
      expect(candidate.account_name).to eq('vickikristoff')
      candidate_sheets = CandidateSheet.all
      expect(candidate_sheets.size).to eq(1)
      expect(candidate.candidate_sheet).to eq(candidate_sheets.first)
      expect_event_association(candidate.baptismal_certificate)
      expect_event_association(candidate.candidate_sheet)
      expect_event_association(candidate.sponsor_covenant)
      expect_event_association(candidate.pick_confirmation_name)
      expect_event_association(candidate.christian_ministry)
      expect_event_association(candidate.retreat_verification)
      expect_event_association(candidate.sponsor_covenant)

      expect(Admin.all.size).to eq(1)
    end
  end

  describe 'export_to_excel' do
    it 'should download an excel spreadsheet.' do
      login_admin

      FactoryBot.create(:candidate, account_name: 'a1')
      FactoryBot.create(:candidate, account_name: 'a2')
      FactoryBot.create(:candidate, account_name: 'a3')

      post :export_to_excel, commit: I18n.t('views.imports.excel'), format: 'xlsx'

      expect(controller.headers['Content-Transfer-Encoding']).to eq('binary')
      expect(response.header['Content-Type']).to eq('application/zip')
      expect(response.status).to eq(200)
    end
  end

  def expect_event_association(assoc_from_candidate)
    event_assoc = assoc_from_candidate.class.all
    expect(event_assoc.size).to eq(1)
    expect(assoc_from_candidate).to eq(event_assoc.first)
  end
end
