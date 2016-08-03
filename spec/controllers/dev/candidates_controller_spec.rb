describe Dev::CandidatesController do
  before(:each) do
    @login_candidate = login_candidate
  end

  it 'should NOT have a current_candidate' do
    expect(subject.current_candidate).to eq(@login_candidate)
  end

  describe 'index' do

    it 'index does not exist for a candidate' do
      begin
        get :index
        expect(false).to eq(true) # should never be executed.
      rescue ActionController::UrlGenerationError => err
        expect(err.message).to eq('No route matches {:action=>"index", :controller=>"dev/candidates"}')
      end
    end

  end

  describe 'edit' do

    it 'should not edit candidate' do
      begin
        get :edit, id: @login_candidate.id
        expect(false).to eq(true) # should never be executed.
      rescue ActionController::UrlGenerationError => err
        expect(err.message).to eq("No route matches {:action=>\"edit\", :controller=>\"dev/candidates\", :id=>\"#{@login_candidate.id}\"}")
      end
    end

  end

  describe 'show' do

    it 'show should not rediect if admin is logged in.' do

      get :show, id: @login_candidate.id
      expect(response).to render_template('show')
      expect(controller.candidate).to eq(@login_candidate)
      expect(@request.fullpath).to eq("/show/#{@login_candidate.id}")
    end

  end

  describe 'fill_out_candidate_sheet' do

    it 'should show fill_out_candidate_sheet for the candidate.' do

      get :candidate_sheet, id: @login_candidate.id

      expect(response).to render_template('candidate_sheet')
      expect(controller.candidate).to eq(@login_candidate)
      expect(@request.fullpath).to eq("/candidate_sheet.#{@login_candidate.id}")
    end

    it 'show should update the candidate to fill out candidate sheet and update Candidate event.' do

      AppFactory.add_confirmation_event(I18n.t('events.fill_out_candidate_sheet'))

      candidate = Candidate.find(@login_candidate.id)
      candidate_event = candidate.candidate_events.find { |ce| ce.name == I18n.t('events.fill_out_candidate_sheet') }
      expect(candidate_event.completed_date).to eq(nil)

      put :candidate_sheet_update, id: candidate.id, candidate: {first_name: 'Paul'}

      candidate = Candidate.find(@login_candidate.id)
      candidate_event = candidate.candidate_events.find { |ce| ce.name == I18n.t('events.fill_out_candidate_sheet') }
      expect(response).to redirect_to(event_candidate_registration_path(candidate.id))
      expect(@request.fullpath).to eq("/candidate_sheet.#{candidate.id}?candidate%5Bfirst_name%5D=Paul")
      expect(candidate.first_name).to eq('Paul')
      expect(candidate_event.completed_date).to eq(Date.today)
    end

  end

  describe 'sign_agreement' do
    before(:each) do
      @candidate = @login_candidate
      @dev = 'dev/'
    end

    it_behaves_like 'sign_agreement'

  end

  describe 'baptismal_certificate' do
    before(:each) do
      @candidate = @login_candidate
      @dev = 'dev/'
      @dev_registration = 'dev/registrations/'
    end

    it_behaves_like 'upload_baptismal_certificate'

  end

end