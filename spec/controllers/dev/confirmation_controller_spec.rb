describe Dev::ConfirmationsController do

  describe 'show' do

    it 'should show an error message that the token is invalid' do
      candidate = FactoryBot.create(:candidate)
      token = 'xxx'
      candidate.confirmed_at=nil
      candidate.confirmation_token=token
      candidate.confirmation_sent_at=Date.today
      @request.env["devise.mapping"] = Devise.mappings[:candidate]

      get :show, confirmation_token: token, id: candidate.id

      expect(candidate.confirmed_at).to be_nil
      expect(response).to redirect_to("/my_candidate_confirmation/-1/Confirmation%20token%20is%20invalid")
      expect(@request.fullpath).to eq("/dev/candidates/confirmation?confirmation_token=#{token}&id=#{candidate.id}")
    end

    it 'should confirm the candidate and show a message on candidate_confirmation.html.erb' do
      candidate = FactoryBot.create(:candidate, should_confirm: false)

      @request.env['devise.mapping'] = Devise.mappings[:candidate]

      token = candidate.confirmation_token

      get :show, confirmation_token: token, id: candidate.id

      candidate = Candidate.find(candidate.id)
      expect(candidate.confirmed?).to be true
      expect(response).to redirect_to("/my_candidate_confirmation/#{candidate.id}/noerrors")
      expect(@request.fullpath).to eq("/dev/candidates/confirmation?confirmation_token=#{token}&id=#{candidate.id}")
    end

    it 'should fail confirmation because of expired token' do
      candidate = FactoryBot.create(:candidate, should_confirm: false)

      @request.env['devise.mapping'] = Devise.mappings[:candidate]

      token = candidate.confirmation_token

      get :show, confirmation_token: token, id: candidate.id
      get :show, confirmation_token: token, id: candidate.id

      candidate = Candidate.find(candidate.id)
      expect(candidate.confirmed?).to be true
      expect(response).to redirect_to("/my_candidate_confirmation/#{candidate.id}/Email%20was%20already%20confirmed,%20please%20try%20signing%20in")
      expect(@request.fullpath).to eq("/dev/candidates/confirmation?confirmation_token=#{token}&id=#{candidate.id}")
    end

  end
end