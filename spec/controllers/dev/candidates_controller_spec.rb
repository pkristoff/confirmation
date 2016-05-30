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

end