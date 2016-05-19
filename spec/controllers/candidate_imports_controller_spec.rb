
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

end