include DeviseHelpers
describe 'admins/registrations/edit.html.erb' do
  before do

    @resource_class = Admin
    @resource = FactoryGirl.create(:admin)

  end
  it 'Form layout' do

    render

    expect(rendered).to have_selector('form[id=edit_admin][action="/admins"]')

    expect(rendered).to have_field(I18n.t('views.common.email'), with: 'test@example.com', type: 'email')
    expect(rendered).to have_field(I18n.t('views.common.password'), type: 'password')
    expect(rendered).to have_field(I18n.t('views.common.password_confirmation'), type: 'password')
    expect(rendered).to have_field(I18n.t('views.admins.current_password'), type: 'password')
    expect(rendered).to have_button(I18n.t('views.common.update'))

  end
end