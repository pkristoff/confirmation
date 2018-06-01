# frozen_string_literal: true

include DeviseHelpers

describe 'candidates/registrations/edit.html.erb' do
  include ViewsHelpers

  before(:each) do
    @resource_class = Candidate
  end

  # http://stackoverflow.com/questions/10503802/how-can-i-check-that-a-form-field-is-prefilled-correctly-using-capybara
  # https://gist.github.com/steveclarke/2353100

  it 'Form layout' do
    candidate = login_candidate

    render

    expect_edit_and_new_view(rendered, candidate, "/update/#{candidate.id}", I18n.t('views.common.update'), true, false)
  end
end
