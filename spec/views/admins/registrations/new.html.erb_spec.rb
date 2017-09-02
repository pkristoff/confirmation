include DeviseHelpers
describe 'admins/registrations/new.html.erb' do
  before do

    @resource_class = Admin

  end
  it 'Form layout' do

    render

    expect(rendered).to have_selector('form[id=new_admin][action="/admins"]')

    expect(rendered).to have_field(I18n.t('views.common.name'), type: 'text')
    expect(rendered).to have_field(I18n.t('views.common.email'), with: '', type: 'email')
    expect(rendered).to have_field(I18n.t('views.common.password'), type: 'password')
    expect(rendered).to have_field(I18n.t('views.common.password_confirmation'), type: 'password')
    expect(rendered).to have_button(I18n.t('views.top_bar.sign_up'))

  end
end