# frozen_string_literal: true

describe 'admins/adhoc_mailing.html.erb' do
  include ViewsHelpers
  before do
    AppFactory.generate_default_status
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
    @body = MailPart.new_body('')

    render

    expect_adhoc_mailing_html(@candidates)
  end

  private

  def expect_adhoc_mailing_html(candidates)
    expect(rendered).to have_css "form[action='/adhoc_mailing_update']"

    expect(rendered).to have_css("input[type='submit'][value='#{I18n.t('email.adhoc_mail')}']", count: 2)

    expect(rendered).to have_css("input[id='top-update'][type='submit'][value='#{I18n.t('email.adhoc_mail')}']")

    expect(rendered).to have_field(I18n.t('email.subject_label'), text: I18n.t('email.subject_initial_input'))

    expect(rendered).to have_field(I18n.t('email.body_label'), text: '')
    expect(rendered).to have_css("textarea[id='mail_body_input'][cols=25][rows=10]")

    expect_sorting_candidate_list(common_columns,
                                  candidates,
                                  rendered)

    expect(rendered).to have_css("input[id='bottom-update'][type='submit'][value='#{I18n.t('email.adhoc_mail')}']")
  end
end
