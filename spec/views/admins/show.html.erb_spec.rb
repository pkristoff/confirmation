# frozen_string_literal: true

describe 'admins/show.html.erb' do
  before(:each) do
    assign(:admin, FactoryBot.create(:admin))
  end

  it 'display @admin' do
    render

    expect(rendered).to have_selector('p', text: "#{I18n.t('views.common.name')}: Admin Candidate")
    expect(rendered).to have_selector('p', text: "#{I18n.t('views.admins.email')}: test@example.com")
    expect(rendered).to have_selector('p', text: "#{I18n.t('label.admin.contact_name')}: Vicki Kristoff")
    expect(rendered).to have_selector('p', text: "#{I18n.t('label.admin.contact_phone')}: 919-249-5629")
    expect(rendered).to have_selector('p', count: 4)
  end
end
