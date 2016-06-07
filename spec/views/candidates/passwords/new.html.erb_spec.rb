include DeviseHelpers
describe 'candidates/passwords/new.html.erb' do
  before do

    @resource_class = Candidate

  end
  it 'Form layout' do

    render

    expect(rendered).to have_selector('form[id=new_candidate][action="/dev/candidates/password"]')

    expect(rendered).to have_field('Account name', type: 'text')
    expect(rendered).to have_button(I18n.t('views.common.reset_password'))

  end
end