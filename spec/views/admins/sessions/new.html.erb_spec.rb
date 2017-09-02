include DeviseHelpers
describe 'admins/sessions/new.html.erb' do
  before do

    @resource_class = Admin

  end
  it 'Form layout' do

    render

    expect(rendered).to have_selector('h2', text: I18n.t('views.top_bar.sign_in', name: 'admin'))

    expect(rendered).to have_selector('form[id=new_admin][action="/admins/sign_in"]')

    expect(rendered).to have_field(I18n.t('views.common.email'), with: '', type: 'email')
    expect(rendered).to have_field(I18n.t('views.common.password'), type: 'password')
    expect(rendered).to have_unchecked_field('Remember me')
    expect(rendered).to have_button(I18n.t('views.top_bar.sign_in', name: 'admin'))

  end
end