include DeviseHelpers
include ViewsHelpers
describe 'candidates/registrations/new.html.erb' do
  it 'Form layout' do

    @resource_class = Candidate

    render

    expect_edit_and_new_view(rendered, @resource, '/dev/candidates.candidate', I18n.t('views.top_bar.sign_up'), true, true)

  end
end