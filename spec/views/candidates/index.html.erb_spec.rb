include ViewsHelpers
describe 'candidates/index.html.erb' do

  before(:each) do

    candidate1 = create_candidate('Vicki', 'Anne', 'Kristoff')
    candidate2 = create_candidate('Paul', 'Richard', 'Kristoff')

    AppFactory.add_confirmation_events

    # have to re-look up canduidates because local is diff object than db onstance
    @candidates = [Candidate.find_by_account_name(candidate1.account_name),
                   Candidate.find_by_account_name(candidate2.account_name)]
    @candidate_info = PluckCan.pluck_candidates

  end


  it 'display the list of candidates' do

    render

    expect_sorting_candidate_list(
        candidates_columns,
        @candidates,
        rendered)

  end

end