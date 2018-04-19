# frozen_string_literal: true

describe 'admins/index.html.erb' do
  before(:each) do
    @admin1 = FactoryBot.create(:admin)
    @admin2 = FactoryBot.create(:admin,
                                name: 'Other Admin',
                                email: 'other@test.com')
  end

  it 'display @admins 0' do
    assign(:admins, [])

    render

    expect(rendered).to have_selector('tr', count: 0)
  end

  it 'display @admins 1' do
    assign(:admins, [@admin2])

    render

    expect(rendered).to have_selector('tr', count: 1)

    expect_admin(rendered, @admin2)
  end

  it 'display @admins 2' do
    assign(:admins, [@admin1, @admin2])

    render

    expect(rendered).to have_selector('tr', count: 2)

    expect_admin(rendered, @admin1)
    expect_admin(rendered, @admin2)
  end

  private

  def expect_admin(rendered, admin)
    expect(rendered).to have_link("delete_#{admin.id}", text: 'Delete')
    expect(rendered).to have_link("edit_#{admin.id}", text: admin.name)
    expect(rendered).to have_selector("td[id='email_#{admin.id}']", text: admin.email)
  end
end
