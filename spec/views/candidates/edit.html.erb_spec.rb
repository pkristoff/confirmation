# frozen_string_literal: true

describe 'candidates/edit.html.erb' do
  include DeviseHelpers
  include ViewsHelpers
  before(:each) do
    @resource_class = Candidate

    @resource = FactoryBot.create(:candidate)
  end

  # http://stackoverflow.com/questions/10503802/how-can-i-check-that-a-form-field-is-prefilled-correctly-using-capybara
  # https://gist.github.com/steveclarke/2353100

  it 'Form layout' do
    render

    expect_edit_and_new_view(rendered, @resource, "/event/#{@resource.id}", I18n.t('views.common.update'), false, false)
  end
end
