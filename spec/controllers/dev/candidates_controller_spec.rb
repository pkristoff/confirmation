describe Dev::CandidatesController do

  skip 'cannot get working in namespace - remove x'

  it 'should NOT have a current_candidate' do
    expect(subject.current_candidate).to eq(nil)
  end

  describe 'index' do

    it 'should fail authentication' do
      login_candidate
      get :index
      expect(@candidates).to eq(nil)
    end

    it 'should pass authentication and set @candidates' do
      login_candidate
      get :index
      puts response.body
      expect(subject.candidates.size).to eq(1)
      expect(response).to render_template('index')
    end

  end

  describe 'edit' do

    it 'show should not rediect if admin' do
      candidate = login_candidate
      get :edit, id: candidate.id
      puts response.body
      expect(response).to render_template('edit')
      expect(controller.candidate).to eq(candidate)
      expect(@request.fullpath).to eq("/candidates/#{candidate.id}")
    end

  end

  describe 'index' do

    it 'show should not rediect if admin' do
      candidate = FactoryGirl.create(:candidate)
      @request.env['HTTP_REFERER'] = 'XXX'
      login_candidate
      get :show, id: candidate.id
      puts response.body
      expect(response).to render_template('show')
      expect(controller.candidate).to eq(candidate)
      expect(@request.fullpath).to eq("/candidates/#{candidate.id}")
    end

  end

  describe 'show' do

    it 'show should not rediect if admin is logged in.' do
      candidate = login_candidate
      @request.env['HTTP_REFERER'] = 'XXX'

      get :show, id: candidate.id
      puts response.body
      expect(response).to render_template('show')
      expect(controller.candidate).to eq(candidate)
      expect(@request.fullpath).to eq("/candidates/#{candidate.id}")
    end

  end

end


# def login_candidate
#   @request.env['devise.mapping'] = Devise.mappings[:candidate]
#   @candidate = FactoryGirl.create(:candidate)
#   sign_in @candidate
#   @candidate
# end
#
# def login_admin
#   @request.env['devise.mapping'] = Devise.mappings[:admin]
#   @admin = FactoryGirl.create(:admin)
#   sign_in @admin
#   @admin
# end