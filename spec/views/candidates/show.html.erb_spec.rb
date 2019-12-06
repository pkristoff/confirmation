# frozen_string_literal: true

describe 'candidates/show.html.erb' do
  before(:each) do
    assign(:candidate, FactoryBot.create(:candidate))
  end

  it 'display @candidate' do
    render

    expect(rendered).to have_selector('p', count: 10)
    expect(rendered).to have_selector('p', text: 'Id: sophiaagusta')
    expect(rendered).to have_selector('p', text: 'First name: Sophia')
    expect(rendered).to have_selector('p', text: 'Middle name: Saraha')
    expect(rendered).to have_selector('p', text: 'Last name: Agusta')
    expect(rendered).to have_selector('p', text: "Attending: #{I18n.t('views.candidates.attending_the_way')}")
    expect(rendered).to have_selector('p', text: 'Grade: 10')
    expect(rendered).to have_selector('p', text: 'Program Year: 2')
    expect(rendered).to have_selector('p', text: 'Candidate email: ')
    expect(rendered).to have_selector('p', text: 'Parent email 1: test@example.com')
    expect(rendered).to have_selector('p', text: 'Parent email 2: ')
  end
end
