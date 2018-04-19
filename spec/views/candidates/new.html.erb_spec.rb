# frozen_string_literal: true

describe 'candidates/new.html.erb' do
  include DeviseHelpers
  include ViewsHelpers
  it 'Form layout' do
    @resource_class = Candidate

    render

    expect(rendered).to have_selector('p', text: 'This has been turned off')
  end
end
