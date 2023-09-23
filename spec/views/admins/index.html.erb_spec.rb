# frozen_string_literal: true

describe 'admins/index.html.erb' do
  before do
    @admin1 = FactoryBot.create(:admin)
    @admin2 = FactoryBot.create(:admin,
                                account_name: 'DaminO',
                                name: 'Other Admin',
                                email: 'other@test.com')
  end

  it 'display @admins 0' do
    assign(:admins, [])

    render
    expect_index_page(rendered, [])
  end

  it 'display @admins 1' do
    assign(:admins, [@admin2])

    render

    admins = [@admin2]
    expect_index_page(rendered, admins)
    expect(rendered).to have_selector('tr', count: admins.size + 1)

    expect_admin(rendered, @admin2)
  end

  it 'display @admins 2' do
    assign(:admins, [@admin1, @admin2])

    render

    admins = [@admin1, @admin2]
    expect_index_page(rendered, admins)
    expect(rendered).to have_selector('tr', count: admins.size + 1)

    expect_admin(rendered, @admin1)
    expect_admin(rendered, @admin2)
  end

  private

  def expect_index_page(rendered, admins)
    expect(rendered).to have_selector('h3', text: I18n.t('views.admins.heading.index'), count: 1)
    expect(rendered).to have_selector('tr', count: admins.size + 1)
    admins.each { |admin| expect_admin(rendered, admin) }
    expect(rendered).to have_link('create-admin', text: I18n.t('views.admins.label.create'))
  end

  def expect_admin(rendered, admin)
    expect(rendered).to have_selector("tr[id=admin-#{admin.id}]", count: 1)
    expect(rendered).to have_link("delete-#{admin.id}", text: I18n.t('views.common.delete'))
    expect(rendered).to have_link("edit-#{admin.id}", text: admin.name)
    expect(rendered).to have_selector("td[id='contact_name-#{admin.id}']", text: admin.contact_name)
    expect(rendered).to have_selector("td[id='contact_phone-#{admin.id}']", text: admin.contact_phone)
    expect(rendered).to have_selector("td[id='email-#{admin.id}']", text: admin.email)
  end
end
