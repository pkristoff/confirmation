# frozen_string_literal: true

describe 'visitors/cand_account_confirmation.html.erb' do
  it 'candidate is confirmed.' do
    @candidate = FactoryBot.create(:candidate)
    @errors = 'noerrors'

    render

    expect(rendered).to have_selector('div[id=confirmed] p', count: 2)
    expect(rendered).to have_selector('div[id=confirmed] p', text: "Congratulations #{@candidate.account_name} on confirming your account.")
    expect(rendered).to have_selector('div[id=confirmed] p', text: 'The next step is to setup your password. Another email was just sent explaining how to do this.')
  end

  it 'candidate not confirmed.' do
    @candidate = FactoryBot.create(:candidate)
    @errors = 'this is an error message'

    render

    expect(rendered).to have_selector('div[id=confirm-failed] p', count: 1)
    expect(rendered).to have_selector('div[id=confirm-failed] p', text: @errors)
  end
end
