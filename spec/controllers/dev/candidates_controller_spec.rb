# frozen_string_literal: true

describe Dev::CandidatesController do
  before do
    @login_candidate = login_candidate
  end

  it 'NOT have a current_candidate' do
    expect(subject.current_candidate).to eq(@login_candidate)
  end

  describe 'index' do
    it 'index does not exist for a candidate' do
      get :index
      RuntimeError('never executed')
    rescue ActionController::UrlGenerationError => e
      expect(e.message).to eq('No route matches {:action=>"index", :controller=>"dev/candidates"}')
    end
  end

  describe 'edit' do
    it 'not edit candidate' do
      begin
        rescue_called = false
        get :edit, params: { id: @login_candidate.id }
        RuntimeError('never executed')
      rescue ActionController::UrlGenerationError => e
        rescue_called = true
        expect = "No route matches {:action=>\"edit\", :controller=>\"dev/candidates\", :id=>#{@login_candidate.id}}"
        expect(e.message).to eq(expect)
      end
      expect(rescue_called).to be(true)
    end
  end

  describe 'show' do
    it 'show not redirect if admin is logged in.' do
      get :show, params: { id: @login_candidate.id }
      # expect(response).to render_template('show')
      expect(controller.candidate).to eq(@login_candidate)
      expect(@request.fullpath).to eq("/show/#{@login_candidate.id}")
    end
  end

  describe 'behaves like' do
    before do
      @candidate = @login_candidate
      @dev = 'dev/'
      @dev_registration = 'dev/registrations/'
    end

    describe 'sign_agreement' do
      it_behaves_like 'sign_agreement'
    end

    describe 'candidate_information_sheet' do
      it_behaves_like 'candidate_information_sheet'
    end

    describe 'baptismal_certificate' do
      it_behaves_like 'baptismal_certificate'
    end
  end
end
