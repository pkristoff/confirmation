# frozen_string_literal: true

describe VisitorsController do
  it 'NOT have a current_candidate' do
    expect(subject.current_candidate).to be_nil
  end

  it 'renders the index template' do
    get :index
    # TODO: add expects for basic visitor layout.
  end

  describe 'Login as candidate' do
    before do
      @candidate = login_candidate
    end

    it 'have a current_candidate' do
      expect(subject.current_candidate).to eq(@candidate)
    end

    it 'redirects to candidates show' do
      get :index
      expect(response).to redirect_to("http://test.host/show/#{@candidate.id}")
    end
  end

  describe 'Login as admin' do
    before do
      @admin = login_admin
    end

    it 'have a current_admin' do
      admin = @admin
      expect(subject.current_admin).to eq(admin)
    end

    it 'redirects to candidates show' do
      get :index
      admin_id = @admin.id
      expect(response).to redirect_to("http://test.host/admins/#{admin_id}")
    end
  end

  describe 'cand_account_confirmation' do
    # see cand_account_confirmation_controller_spec.rb - this causes this condition
    it 'error' do
      get :cand_account_confirmation, params: { id: -1, errors: 'Confirmation token is invalid' }
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'VisitorsController.validate_email(email)' do
    it 'No email' do
      expect(VisitorsController.validate_email('')).to be_falsey
    end

    it 'Bad email form' do
      expect(VisitorsController.validate_email('foo')).to be_falsey
      expect(VisitorsController.validate_email('@bbb.com')).to be_falsey
      expect(VisitorsController.validate_email('bbb.com')).to be_falsey
    end

    it 'Good email form' do
      expect(VisitorsController.validate_email('foo@ccc.com')).to be_truthy
      expect(VisitorsController.validate_email('foo@gmail.com')).to be_truthy
    end
  end
end
