include ViewsHelpers

describe 'admins/monthly_mass_mailing.html.erb' do

  before(:each) do

    candidate_1 = create_candidate('Vicki', 'Anne', 'Kristoff')
    candidate_2 = create_candidate('Paul', 'Richard', 'Kristoff')

    AppFactory.add_confirmation_events

    # have re-lookup candidates because local a diff instance
    @candidates = [Candidate.find_by_account_name(candidate_1.account_name),
                   Candidate.find_by_account_name(candidate_2.account_name)]

  end


  it 'display the list of candidates' do

    @subject = t('email.subject_initial_text')
    @pre_late_input = t('email.late_initial_text')
    @pre_coming_due_input = t('email.coming_due_initial_text')
    @completed_awaiting_input = t('email.completed_awaiting_initial_text')
    @completed_input = t('email.completed_initial_text')
    @closing_text = t('email.closing_initial_text')
    @salutation_text = t('email.salutation_initial_text')
    @from_text = t('email.from_initial_text_html')

    render

    expect_mass_mailing_html(@candidates, rendered)

  end

end