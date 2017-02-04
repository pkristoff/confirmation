shared_context 'sign_an_agreement_html_erb' do

  before(:each) do
    AppFactory.all_i18n_confirmation_event_names.each do | i18n_name |
      AppFactory.add_confirmation_event(I18n.t(i18n_name))
    end
  end

  scenario 'user(candidate or admin) logs in, selects signing an agreement, has not signed agreement previsouly' do
    @candidate.sponsor_agreement=false
    visit @path

    expect_form_layout(@candidate.send(@sign_agreement_getter))
  end

  scenario 'user(candidate or admin) logs in, selects signing an agreement, has signed agreement previously' do
    @candidate.sponsor_agreement=true
    @candidate.save
    visit @path
    expect_form_layout(@candidate.send(@sign_agreement_getter))
  end

  scenario 'user(candidate or admin) logs in, signs agreement' do

    @candidate.send(@sign_agreement_setter, false)
    @candidate.save

    visit @path
    check(@field_name)
    click_button('bottom-update')

    expect_message(:flash_notice, I18n.t('messages.updated'))
    if @dev.empty?
      # make sure Candidate list is showing
      expect(page).to have_selector("tr[id=candidate_list_tr_#{@candidate.id}]")
    else
      expect(page).to have_selector("div[id=candidate_event_#{@event_offset}_verified]", text: false)
      expect(page).to have_selector("div[id=candidate_event_#{@event_offset}_completed_date]", text: Date.today)
    end
  end

  scenario 'candidate unsigns agreement' do

    @candidate.send(@sign_agreement_setter, true)
    @candidate.save

    visit @path
    uncheck(@field_name)
    click_button('bottom-update')

    expect_message(:flash_notice, I18n.t('messages.updated'))
    if @dev.empty?
      # make sure Candidate list is showing
      expect(page).to have_selector("tr[id=candidate_list_tr_#{@candidate.id}]")
    else
      expect(page).to have_selector("div[id=candidate_event_#{@event_offset}_verified]", text: false)
      expect(page).to have_selector("div[id=candidate_event_#{@event_offset}_completed_date]", text: nil)
    end
  end

  def expect_form_layout(sponsor_agreement)

    expect(page).to have_selector(@form_action)

    if sponsor_agreement
      expect(page).to have_checked_field(@field_name)
    else
      expect(page).not_to have_checked_field(@field_name)
    end

    expect(page).to have_button('bottom-update')
    expect_download_button(@documant_key)
  end

end
