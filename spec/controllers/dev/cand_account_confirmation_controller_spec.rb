# frozen_string_literal: true

describe Dev::CandAccountConfirmationsController do
  describe 'show' do
    it 'should show an error message that the token is invalid' do
      candidate = FactoryBot.create(:candidate)
      token = 'xxx'
      candidate.confirmed_at = nil
      candidate.confirmation_token = token
      candidate.confirmation_sent_at = Time.zone.today
      @request.env['devise.mapping'] = Devise.mappings[:candidate]

      get :show, params: { confirmation_token: token, id: candidate.id }

      expect(candidate.confirmed_at).to be_nil
      expect(response).to redirect_to('/cand_account_confirmation/-1/Confirmation%20token%20is%20invalid')
      expect(@request.fullpath).to eq("/dev/candidates/confirmation?confirmation_token=#{token}&id=#{candidate.id}")
    end

    it 'should confirm the candidate and show a message on cand_account_confirmation.html.erb' do
      candidate = FactoryBot.create(:candidate, should_confirm: false)

      @request.env['devise.mapping'] = Devise.mappings[:candidate]

      token = candidate.confirmation_token

      get :show, params: { confirmation_token: token, id: candidate.id }

      candidate = Candidate.find(candidate.id)
      expect(candidate.confirmed?).to be true
      expect(response).to redirect_to("/cand_account_confirmation/#{candidate.id}/noerrors")
      expect(@request.fullpath).to eq("/dev/candidates/confirmation?confirmation_token=#{token}&id=#{candidate.id}")
    end

    it 'should fail confirmation because of expired token' do
      candidate = FactoryBot.create(:candidate, should_confirm: false)

      @request.env['devise.mapping'] = Devise.mappings[:candidate]

      token = candidate.confirmation_token

      get :show, params: { confirmation_token: token, id: candidate.id }
      get :show, params: { confirmation_token: token, id: candidate.id }

      candidate = Candidate.find(candidate.id)
      expect(candidate.confirmed?).to be true
      # rubocop:disable Layout/LineLength
      expect(response).to redirect_to("/cand_account_confirmation/#{candidate.id}/Email%20%20-%20Your%20account%20was%20already%20confirmed,%20you%20should%20have%20received%20a%20second%20email%20with%20a%20link%20to%20setup%20your%20password")
      # rubocop:enable Layout/LineLength
      expect(@request.fullpath).to eq("/dev/candidates/confirmation?confirmation_token=#{token}&id=#{candidate.id}")
    end
  end
end
