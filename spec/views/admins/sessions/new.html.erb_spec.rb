# frozen_string_literal: true

describe 'admins/sessions/new.html.erb' do
  include DeviseHelpers
  before do
    @resource_class = Admin
  end

  after(:each) do
    I18n.locale = 'en'
  end

  it 'Form layout Spanish' do
    I18n.locale = 'es'
    run_test
  end

  it 'Form layout English' do
    I18n.locale = 'en'
    run_test
  end

  private

  def run_test
    render

    expect(rendered).to have_selector('h2', text: I18n.t('views.top_bar.sign_in', name: 'admin'))

    expect(rendered).to have_selector('form[id=new_admin][action="/admins/sign_in"]')

    expect(rendered).to have_field(I18n.t('views.admins.account_name'), with: 'Admin', type: 'text')
    expect(rendered).to have_field(I18n.t('views.common.password'), type: 'password')
    expect(rendered).to have_unchecked_field(I18n.t('views.common.remember_me'))
    expect(rendered).to have_button(I18n.t('views.top_bar.sign_in', name: 'admin'))
  end
end
