describe Dev::RegistrationsController do

  it 'should take you back to the home page' do

    candidate = FactoryBot.create(:candidate)

    get :event, id: candidate.id

    expect(response).to redirect_to (root_path)

    expect(response.body).to have_css("a[href='#{root_url}']", text='redirected')

  end

end