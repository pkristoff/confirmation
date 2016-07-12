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

  describe 'sign_agreement' do

    it 'show should show setup the candidate.' do

      get :sign_agreement, id: @login_candidate.id
      expect(response).to render_template('sign_agreement')
      expect(controller.candidate).to eq(@login_candidate)
      expect(@request.fullpath).to eq("/sign_agreement.#{@login_candidate.id}")
    end

    it 'show should update the candidate to signing the confirmation agreement and update Candidate event.' do

      AppFactory.add_confirmation_event(I18n.t('events.sign_agreement'))

      candidate = Candidate.find(@login_candidate.id)
      candidate_event = candidate.candidate_events.find {|ce| ce.name == I18n.t('events.sign_agreement')}
      expect(candidate_event.completed_date).to eq(nil)

      put :sign_agreement_update, id: candidate.id, candidate: {signed_agreement: 1}

      candidate = Candidate.find(@login_candidate.id)
      candidate_event = candidate.candidate_events.find {|ce| ce.name == I18n.t('events.sign_agreement')}
      expect(response).to redirect_to(event_candidate_registration_path(candidate.id))
      expect(@request.fullpath).to eq("/sign_agreement.#{candidate.id}?candidate%5Bsigned_agreement%5D=1")
      expect(candidate.signed_agreement).to eq(true)
      expect(candidate_event.completed_date).to eq(Date.today)
    end

  end

end