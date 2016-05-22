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
      expect(controller.candidate_import.errors.size).to eq(5)
    end
  end

  describe 'remove_all_candidates' do

    it 'should remove all candidates' do
      expect(Candidate.all.size).to eq(0)
      FactoryGirl.create(:candidate, candidate_id: 'a1')
      FactoryGirl.create(:candidate, candidate_id: 'a2')
      FactoryGirl.create(:candidate, candidate_id: 'a3')
      expect(Candidate.all.size).to eq(3)
      login_admin

      post :remove_all_candidates

      expect(response).to redirect_to(root_url)
      expect(Candidate.all.size).to eq(0)

    end
  end

  describe 'reset_database' do

    it 'should reset database' do
      expect(Candidate.all.size).to eq(0)
      FactoryGirl.create(:candidate, candidate_id: 'a1')
      FactoryGirl.create(:candidate, candidate_id: 'a2')
      FactoryGirl.create(:candidate, candidate_id: 'a3')
      expect(Candidate.all.size).to eq(3)
      login_admin

      expect(Admin.all.size).to eq(1)
      FactoryGirl.create(:admin, email: 'paul@kristoffs.com', name: 'Paul')
      expect(Admin.all.size).to eq(2)

      post :reset_database

      expect(response).to redirect_to(root_url)
      expect(Candidate.all.size).to eq(1)
      expect(Admin.all.size).to eq(1)

    end

  end

  describe 'export_to_excel' do

    it 'should download an excel spreadsheet.' do
      login_admin

      FactoryGirl.create(:candidate, candidate_id: 'a1')
      FactoryGirl.create(:candidate, candidate_id: 'a2')
      FactoryGirl.create(:candidate, candidate_id: 'a3')

      post :export_to_excel, format: 'xlsx'

      expect(controller.headers["Content-Transfer-Encoding"]).to eq("binary")
      expect(response.header['Content-Type']).to eq('application/octet-stream')
      expect(response.status).to eq(200)

    end

    it 'should not download an excel spreadsheet if format is wrong' do
      login_admin

      FactoryGirl.create(:candidate, candidate_id: 'a1')
      FactoryGirl.create(:candidate, candidate_id: 'a2')
      FactoryGirl.create(:candidate, candidate_id: 'a3')

      begin
        post :export_to_excel, format: 'xls'
        expect(false).to eq(true) # should never be executed.
      rescue ActionController::UnknownFormat => err
        expect(err.message).to eq('ActionController::UnknownFormat')
      end

    end

  end

end