# frozen_string_literal: true

describe 'candidates/registrations/new.html.erb' do
  include DeviseHelpers
  include ViewsHelpers
  it 'Form layout' do
    @resource_class = Candidate

    render

    expect_edit_and_new_view(rendered, @resource, '/dev/candidates.candidate', I18n.t('views.top_bar.sign_up'), true, true)
  end
end
