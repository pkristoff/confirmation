include ViewsHelpers

describe 'admins/adhoc_mailing.html.erb' do

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

    render

    expect_adhoc_mailing_html(@candidates)

  end

  def expect_adhoc_mailing_html(candidates)

    expect(rendered).to have_css "form[action='/adhoc_mailing_update']"

    expect(rendered).to have_css("input[type='submit'][value='#{I18n.t('email.adhoc_mail')}']", count: 2)

    expect(rendered).to have_css("input[id='top-update'][type='submit'][value='#{I18n.t('email.adhoc_mail')}']")
puts rendered
    expect(rendered).to have_field(I18n.t('email.subject_label'), text: I18n.t('email.subject_initial_text'))

    expect(rendered).to have_field(I18n.t('email.body_label'), text: '')

    expect_sorting_candidate_list(get_columns_helpers,
                                  candidates,
                                  rendered)

    expect(rendered).to have_css("input[id='bottom-update'][type='submit'][value='#{I18n.t('email.adhoc_mail')}']")
  end

end