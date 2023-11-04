# frozen_string_literal: true

describe 'admins/index.html.erb' do
  include Warden::Test::Helpers

  before do
    FactoryBot.create(:visitor)
    @admin2 = FactoryBot.create(:admin,
                                account_name: 'DaminO',
                                name: 'Other Admin',
                                email: 'other@test.com')
  end

  after do
    Warden.test_reset!
  end

  it 'display @admins 0' do
    assign(:admins, [])

    render

    expect_index_page(rendered, [], nil)
  end

  it 'display @admins 1' do
    assign(:admins, [@admin2])
    sign_in @admin2

    render

    admins = [@admin2]
    expect_index_page(rendered, admins, @admin2)
    expect(rendered).to have_selector('tr', count: admins.size + 1)
  end

  it 'display @admins 2' do
    @admin1 = FactoryBot.create(:admin)
    assign(:admins, [@admin1, @admin2])
    sign_in @admin2

    render

    admins = [@admin1, @admin2]
    expect_index_page(rendered, admins, @admin2)
    expect(rendered).to have_selector('tr', count: admins.size + 1)
  end

  private

  def expect_index_page(rendered, admins, signed_in_admin)
    expect(rendered).to have_selector('h3', text: I18n.t('views.admins.heading.index'), count: 1)
    expect(rendered).to have_selector('tr', count: admins.size + 1)
    admins.each { |admin| expect_admin(rendered, admin, delete_link: Admin.count == 1 || admin.id == signed_in_admin.id) }
    expect(rendered).to have_link('create-admin', text: I18n.t('views.admins.label.create'))
  end

  def expect_admin(rendered, admin, delete_link: true)
    expect(rendered).to have_selector("tr[id=admin-#{admin.id}]", count: 1)
    if delete_link
      expect(rendered).to have_selector("p[id=delete-#{admin.id}]")
    else
      expect(rendered).to have_selector("input[id='submit-delete-#{admin.id}'][value=#{I18n.t('views.common.delete')}]")
    end
    expect(rendered).to have_link("edit-#{admin.id}", text: admin.name)
    expect(rendered).to have_selector("td[id='contact_name-#{admin.id}']", text: admin.contact_name)
    expect(rendered).to have_selector("td[id='contact_phone-#{admin.id}']", text: admin.contact_phone)
    expect(rendered).to have_selector("td[id='email-#{admin.id}']", text: admin.email)
  end
end
