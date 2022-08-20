# frozen_string_literal: true

describe 'admins/monthly_mass_mailing.html.erb' do
  include ViewsHelpers
  before do
    @admin = FactoryBot.create(:admin)
    candidate1 = create_candidate('Vicki', 'Anne', 'Kristoff')
    candidate2 = create_candidate('Paul', 'Richard', 'Kristoff')

    AppFactory.add_confirmation_events

    # have re-lookup candidates because local a diff instance
    @candidates = [Candidate.find_by(account_name: candidate1.account_name),
                   Candidate.find_by(account_name: candidate2.account_name)]
    @candidate_info = PluckCan.pluck_candidates
  end

  it 'display the list of candidates' do
    @subject = MailPart.new_subject(t('email.subject_initial_input'))
    @pre_late_input = MailPart.new_pre_late_input(t('email.late_initial_input'))
    @pre_coming_due_input = MailPart.new_pre_coming_due_input(t('email.coming_due_initial_input'))
    @completed_awaiting_input =
      MailPart.new_completed_awaiting_input(t('email.completed_awaiting_initial_input'))
    @completed_input = MailPart.new_completed_input(t('email.completed_initial_input'))
    @closing_input = MailPart.new_closing_input(t('email.closing_initial_input'))
    @salutation_input = MailPart.new_salutation_input(t('email.salutation_initial_input'))
    @from_input = MailPart.new_from_input(t('email.from_initial_input_html',
                                            name: @admin.contact_name,
                                            email: @admin.email,
                                            phone: @admin.contact_phone))

    render

    expect_mass_mailing_html(@candidates, rendered)
  end
end
