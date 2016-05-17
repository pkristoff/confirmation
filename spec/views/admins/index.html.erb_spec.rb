
describe 'admins/index.html.erb' do

  before(:each) do

    @admin1 = FactoryGirl.create(:admin)
    @admin2 = FactoryGirl.create(:admin, {
        name: 'Other Admin',
        email: 'other@test.com'})

  end

  it 'display @admins 0' do

    assign(:admins, [])

    render

    expect(rendered).to have_css('table#admins_table tr', :count => 0)
  end

  it 'display @admins 1' do

    assign(:admins, [@admin2])

    render

    expect(rendered).to have_css('table#admins_table tr', :count => 1)

    expect_admin(rendered, 1, @admin2)
  end

  it 'display @admins 2' do

    assign(:admins, [@admin1, @admin2])

    render

    expect(rendered).to have_css('table#admins_table tr', :count => 2)

    expect_admin(rendered, 1, @admin1)
    expect_admin(rendered, 2, @admin2)
  end

  private

  def expect_admin (rendered, row, admin)

    expect(rendered).to have_css("table#admins_table tbody tr:nth-of-type(#{row}) td", :count => 2)
    expect(rendered).to have_selector("table#admins_table tbody tr:nth-of-type(#{row}) td:nth-of-type(1)", text: admin.name)
    expect(rendered).to have_selector("table#admins_table tbody tr:nth-of-type(#{row}) td:nth-of-type(2)", text: admin.email)
  end
end