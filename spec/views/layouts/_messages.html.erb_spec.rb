# frozen_string_literal: true

describe 'layouts/_messages.html.erb' do
  before do
    allow(view).to receive_messages(flash: [%w[notice nnn'], %w[error errormessage], %w[error errormessage2]])
  end

  it 'Form layout' do
    render

    expect(rendered).to have_selector('div[id=flash_notice]', text: 'nnn')
    expect(rendered).to have_selector('div[id=flash_error]', text: 'errormessage')
    expect(rendered).to have_selector('div[id=flash_error]', text: 'errormessage2')
  end
end
