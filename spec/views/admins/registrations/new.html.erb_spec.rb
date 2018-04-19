# frozen_string_literal: true

describe 'admins/registrations/new.html.erb' do
  include DeviseHelpers
  before do
    @resource_class = Admin
  end
  it 'Form layout' do
    render

    expect(rendered).to have_selector('p', text: 'This is turned off')
  end
end
