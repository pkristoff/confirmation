# frozen_string_literal: true

describe 'admins/show.html.erb' do
  before do
    assign(:admin, FactoryBot.create(:admin))
  end

  it 'display @admin' do
    render

    expect(rendered).to have_selector('p', text: "#{I18n.t('activerecord.attributes.admin.account_name')}: Admin")
    expect(rendered).to have_selector('p', text: "#{I18n.t('activerecord.attributes.admin.name')}: Admin Candidate")
    expect(rendered).to have_selector('p', text: "#{I18n.t('activerecord.attributes.admin.email')}: test@example.com")
    expect(rendered).to have_selector('p', text: "#{I18n.t('activerecord.attributes.admin.contact_name')}: Vicki Kristoff")
    expect(rendered).to have_selector('p', text: "#{I18n.t('activerecord.attributes.admin.contact_phone')}: 919-249-5629")
    expect(rendered).to have_selector('p', count: 5)
  end
end
