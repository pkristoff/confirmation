describe CandidatesController do
  before(:each) do
    @admdin = login_admin
  end

  it 'should NOT have a current_candidate' do
    expect(subject.current_candidate).to eq(nil)
  end

  describe 'index' do

    it 'should show list of candidates' do
      candidate = FactoryGirl.create(:candidate)
      get :index
      expect(response).to render_template('index')
      expect(response.status).to eq(200)
      expect(controller.candidates.size).to eq(1)
      expect(controller.candidates[0]).to eq(candidate)
    end

  end

  describe 'show' do

    it 'show should show candidate.' do
      candidate = FactoryGirl.create(:candidate)
      get :show, {id: candidate.id}
      expect(response).to render_template('show')
      expect(controller.candidate).to eq(candidate)
      expect(@request.fullpath).to eq("/candidates/#{candidate.id}")
    end

  end

end