# frozen_string_literal: true

describe 'admins/registrations/edit.html.erb' do
  include DeviseHelpers
  before do
    @resource_class = Admin
    @resource = FactoryBot.create(:admin)
  end
  it 'Form layout' do
    render

    expect(rendered).to have_selector('form[id=edit_admin][action="/admins"]')

    expect(rendered).to have_field(I18n.t('label.admin.contact_name'), with: 'Vicki Kristoff', type: 'text')
    expect(rendered).to have_field(I18n.t('views.admins.email'), with: 'test@example.com', type: 'email')
    expect(rendered).to have_field(I18n.t('label.admin.contact_phone'), with: '919-249-5629', type: 'text')
    expect(rendered).to have_field(I18n.t('views.common.password'), type: 'password')
    expect(rendered).to have_field(I18n.t('views.common.password_confirmation'), type: 'password')
    expect(rendered).to have_field(I18n.t('views.admins.current_password'), type: 'password')
    expect(rendered).to have_button(I18n.t('views.common.update'))
  end
end
