# frozen_string_literal: true

describe Dev::PasswordsController do
  before(:each) do
    Visitor.visitor('St. Mary Magdalene', 'replace me - home', 'replace me - about', 'replace me - contaclt')
  end

  describe 'edit' do
    it 'should error if token has expired' do
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

    it 'should bring up then the edit password pane if token ok' do
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
    it 'should reset password' do
      admin = login_admin
      candidate = FactoryBot.create(:candidate, should_confirm: true)
      expect(candidate.account_confirmed?).to eq(true)
      token = candidate.send_reset_password_instructions(admin)
      candidate.save

      @request.env['devise.mapping'] = Devise.mappings[:candidate]

      put :update, params:
        { candidate: { reset_password_token: token, password: 'therainin', password_confirmation: 'therainin' } }

      candidate = Candidate.find(candidate.id)
      expect(response.status).to eq(302)
      expect(response).to redirect_to(event_candidate_registration_path(candidate))
      expect(candidate.valid_password?('therainin')).to eq(true)
    end

    it 'should reset password and confirm candidate account' do
      admin = login_admin
      candidate = FactoryBot.create(:candidate, should_confirm: false)
      expect(candidate.account_confirmed?).to eq(false)
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
      expect(candidate.valid_password?('therainin')).to eq(true)
      expect(candidate.account_confirmed?).to eq(true)
    end
  end
end
