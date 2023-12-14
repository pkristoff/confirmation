# frozen_string_literal: true

describe Dev::PasswordsController do
  before do
    FactoryBot.create(:visitor)
    AppFactory.generate_default_status
  end

  describe 'edit' do
    it 'error if token has expired' do
      admin = login_admin

      candidate = FactoryBot.create(:candidate)
      token = 'xxx'
      candidate.confirmed_at = nil
      candidate.confirmation_token = token
      candidate.confirmation_sent_at = Time.zone.today
      candidate.save

      @request.env['devise.mapping'] = Devise.mappings[:candidate]

      get :edit, params: { reset_password_token: token }

      expect(response).to redirect_to('/dev/candidates/sign_in')
      expect(flash[:alert]).to eq(I18n.t('messages.password.token_expired', email: admin.email))
    end

    it 'bring up then the edit password pane if token ok' do
      admin = login_admin
      candidate = FactoryBot.create(:candidate)
      token = candidate.send_reset_password_instructions(admin)
      candidate.save

      @request.env['devise.mapping'] = Devise.mappings[:candidate]

      get :edit, params: { reset_password_token: token }

      expect(response.status).to eq(200)
    end
  end

  describe 'update' do
    it 'reset password' do
      admin = login_admin
      candidate = FactoryBot.create(:candidate, should_confirm: true)
      expect(candidate.account_confirmed?).to be(true)
      token = candidate.send_reset_password_instructions(admin)
      candidate.save

      @request.env['devise.mapping'] = Devise.mappings[:candidate]

      put :update, params:
        { candidate: { reset_password_token: token, password: 'therainin', password_confirmation: 'therainin' } }

      candidate = Candidate.find(candidate.id)
      expect(response.status).to eq(302)
      expect(response).to redirect_to(event_candidate_registration_path(candidate))
      expect(candidate.valid_password?('therainin')).to be(true)
    end

    it 'reset password and confirm candidate account' do
      admin = login_admin
      candidate = FactoryBot.create(:candidate, should_confirm: false)
      expect(candidate.account_confirmed?).to be(false)
      token = candidate.send_reset_password_instructions(admin)
      candidate.save

      @request.env['devise.mapping'] = Devise.mappings[:candidate]

      put :update, params: {
        candidate: { reset_password_token: token, password: 'therainin', password_confirmation: 'therainin' }
      }

      candidate = Candidate.find(candidate.id)
      expect(response.status).to eq(302)
      expect(response).to redirect_to(event_candidate_registration_path(candidate))
      expect(flash[:notice]).to eq(I18n.t('messages.password.reset_and_confirmed', name: candidate.account_name))
      expect(candidate.valid_password?('therainin')).to be(true)
      expect(candidate.account_confirmed?).to be(true)
    end
  end
end
