# frozen_string_literal: true

describe 'admins/monthly_mass_mailing.html.erb' do
  include ViewsHelpers
  before(:each) do
    candidate1 = create_candidate('Vicki', 'Anne', 'Kristoff')
    candidate2 = create_candidate('Paul', 'Richard', 'Kristoff')

    AppFactory.add_confirmation_events

    # have re-lookup candidates because local a diff instance
    @candidates = [Candidate.find_by(account_name: candidate1.account_name),
                   Candidate.find_by(account_name: candidate2.account_name)]
    @candidate_info = PluckCan.pluck_candidates
  end

  it 'display the list of candidates' do
    @subject = MailPart.new('subject', t('email.subject_initial_input'))
    @pre_late_input = MailPart.new('pre_late_input', t('email.late_initial_input'))
    @pre_coming_due_input = MailPart.new('pre_coming_due_input', t('email.coming_due_initial_input'))
    @completed_awaiting_input = MailPart.new('completed_awaiting_input', t('email.completed_awaiting_initial_input'))
    @completed_input = MailPart.new('completed_input', t('email.completed_initial_input'))
    @closing_input = MailPart.new('closing_input', t('email.closing_initial_input'))
    @salutation_input = MailPart.new('salutation_input', t('email.salutation_initial_input'))
    @from_input = MailPart.new('from_input', t('email.from_initial_input_html'))

    render

    expect_mass_mailing_html(@candidates, rendered)
  end
end
