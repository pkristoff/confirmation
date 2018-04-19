# frozen_string_literal: true

describe 'visitors/candidate_confirmation.html.erb' do
  it 'candidate is confirmed.' do
    @candidate = FactoryBot.create(:candidate)
    @errors = 'noerrors'

    render

    expect(rendered).to have_selector('div[id=confirmed] p', count: 2)
    expect(rendered).to have_selector('div[id=confirmed] p', text: "Congratulations on confirming your account: #{@candidate.account_name}")
    expect(rendered).to have_selector('div[id=confirmed] p', text: 'The next step is to change your password. You should have gotten another e-mail to do this.')
  end

  it 'candidate not confirmed.' do
    @candidate = FactoryBot.create(:candidate)
    @errors = 'this is an error message'

    render

    expect(rendered).to have_selector('div[id=confirm-failed] p', count: 1)
    expect(rendered).to have_selector('div[id=confirm-failed] p', text: @errors)
  end
end
