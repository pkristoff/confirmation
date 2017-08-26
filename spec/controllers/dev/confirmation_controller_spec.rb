describe Dev::ConfirmationsController do

  describe 'show' do

    it 'should show an error message that the token is invalid' do
      candidate = FactoryGirl.create(:candidate)
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
      candidate = FactoryGirl.create(:candidate, should_confirm: false)

      @request.env["devise.mapping"] = Devise.mappings[:candidate]

      token = candidate.confirmation_token

      get :show, confirmation_token: token, id: candidate.id

      candidate = Candidate.find(candidate.id)
      expect(candidate.confirmed?).to be true
      expect(response).to redirect_to("/my_candidate_confirmation/#{candidate.id}/noerrors")
      expect(@request.fullpath).to eq("/dev/candidates/confirmation?confirmation_token=#{token}&id=#{candidate.id}")
    end

  end
end