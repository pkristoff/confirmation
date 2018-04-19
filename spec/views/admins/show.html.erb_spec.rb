# frozen_string_literal: true

describe 'admins/show.html.erb' do
  before(:each) do
    assign(:admin, FactoryBot.create(:admin))
  end

  it 'display @admin' do
    render

    expect(rendered).to have_selector('p', count: 2)
    expect(rendered).to have_selector('p', text: "#{I18n.t('views.common.name')}: Admin Candidate")
    expect(rendered).to have_selector('p', text: "#{I18n.t('views.common.email')}: test@example.com")
  end
end
