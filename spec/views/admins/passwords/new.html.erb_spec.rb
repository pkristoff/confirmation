# frozen_string_literal: true

include DeviseHelpers

describe 'admins/passwords/new.html.erb' do
  before do
    @resource_class = Admin
  end

  it 'Form layout' do
    expect(resource).not_to be_nil
    render

    expect(rendered).to have_selector('form[id=new_admin][action="/admins/password"]')

    expect(rendered).to have_field(I18n.t('views.common.email'), with: '', type: 'email')
    expect(rendered).to have_button(I18n.t('views.common.reset_password'))
  end
end
