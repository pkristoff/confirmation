# frozen_string_literal: true

describe 'candidates/new.html.erb' do
  include DeviseHelpers
  include ViewsHelpers
  it 'Form layout' do
    @resource = AppFactory.create_candidate
    @resource_class = Candidate
    render
    expect_create_candidate(rendered)
  end
end
