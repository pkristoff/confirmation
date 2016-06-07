include DeviseHelpers
describe 'candidates/sessions/new.html.erb' do
  before do

    @resource_class = Candidate

  end
  it 'Form layout' do

    render

    expect(rendered).to have_selector('h2', text: I18n.t('views.common.sign_in', name: ''))
    expect(rendered).not_to have_selector('h2', text: '%{name}')

    expect(rendered).to have_selector('form[id=new_candidate][action="/dev/candidates/sign_in"]')

    expect(rendered).to have_field(I18n.t('views.candidates.account_name'), with: '', type: 'text')
    expect(rendered).to have_field(I18n.t('views.candidates.password'), type: 'password')
    expect(rendered).to have_unchecked_field('Remember me')
    expect(rendered).to have_button(I18n.t('views.common.sign_in', name: ''))

  end
end