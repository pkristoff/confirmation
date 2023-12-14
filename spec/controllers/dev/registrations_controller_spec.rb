# frozen_string_literal: true

describe Dev::RegistrationsController do
  it 'take you back to the home page' do
    AppFactory.generate_default_status
    candidate = FactoryBot.create(:candidate)

    get :event, params: { id: candidate.id }

    expect(response).to redirect_to root_path

    expect(response.body).to have_css("a[href='#{root_url}']", text: 'redirected')
  end

  describe 'delete admin' do
    it 'cannot delete the only admin' do
      FactoryBot.create(:admin)
      expect(Admin.count).to be(1)
      # delete
    end
  end
end
