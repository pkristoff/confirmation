include DeviseHelpers
include ViewsHelpers
describe 'candidates/new.html.erb' do
  it 'Form layout' do

    @resource_class = Candidate

    render

    expect_edit_and_new_view(rendered, nil, '/create', I18n.t('views.common.sign_up'), false, true)

  end
end