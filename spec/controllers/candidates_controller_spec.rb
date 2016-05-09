describe CandidatesController do

  it 'should NOT have a current_candidate' do
    expect(subject.current_candidate).to eq(nil)
  end

  describe 'index' do

    it 'should fail authentication' do
      login_admin
      get :index
      expect(@candidates).to eq(nil)
    end

    it 'should pass authentication and set @candidates' do
      login_candidate
      get :index
      expect(subject.candidates.size).to eq(1)
      expect(response).to render_template('index')
    end

  end

  describe 'index' do

    it 'show should not rediect if admin' do
      candidate = FactoryGirl.create(:candidate)
      @request.env['HTTP_REFERER'] = 'XXX'
      login_admin
      get :show, {:id => candidate.id}
      expect(response).to render_template('show')
      expect(controller.candidate).to eq(candidate)
      expect(@request.fullpath).to eq("/candidates/#{candidate.id}")
    end

    it 'show should not rediect if candidate' do
      candidate = login_candidate
      @request.env['HTTP_REFERER'] = 'XXX'
      get :show, {:id => candidate.id}
      expect(response).to render_template('show')
      expect(controller.candidate).to eq(candidate)
      expect(@request.fullpath).to eq("/candidates/#{candidate.id}")
    end

    it 'show should rediect if another use' do
      other = FactoryGirl.create(:candidate, {name: 'other', email: 'abc@xxx.com'})
      login_candidate
      @request.env['HTTP_REFERER'] = 'XXX'
      get :show, {:id => other.id}
      expect(response).not_to render_template('show')
      expect(response).to redirect_to('XXX')
    end

  end

end


def login_candidate
  @request.env['devise.mapping'] = Devise.mappings[:candidate]
  @candidate = FactoryGirl.create(:candidate)
  sign_in @candidate
  @candidate
end

def login_admin
  @request.env['devise.mapping'] = Devise.mappings[:admin]
  @admin = FactoryGirl.create(:admin)
  sign_in @admin
end