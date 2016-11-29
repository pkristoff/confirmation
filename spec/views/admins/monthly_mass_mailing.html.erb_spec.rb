include ViewsHelpers

describe 'admins/monthly_mass_mailing.html.erb' do

  before(:each) do
    AppFactory.add_confirmation_events

    @candidate_1 = create_candidate('Vicki', 'Kristoff')
    @candidate_2 = create_candidate('Paul', 'Kristoff')
    @candidates = [@candidate_1, @candidate_2]

  end


  it 'display the list of candidates' do

    render

    expect_mass_mailing_html(@candidates, rendered)

  end

end