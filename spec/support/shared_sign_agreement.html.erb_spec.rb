shared_context 'Sign Agreement' do

  scenario 'candidate logs in, selects sign agreement, has not signed agreetment previsouly' do
    @candidate.signed_agreement=false
    visit @path
    expect_form_layout(@candidate.signed_agreement)
  end

  scenario 'candidate logs in, selects sign agreement, has signed agreement previously' do
    @candidate.signed_agreement=true
    @candidate.save
    visit @path
    expect_form_layout(@candidate.signed_agreement)
  end

  scenario 'candidate signs agreement' do

    AppFactory.add_confirmation_event(I18n.t('events.sign_agreement'))
    @candidate.signed_agreement=false
    @candidate.save

    visit @path
    check('Signed agreement')
    click_button('Update')

    expect_message(:flash_notice, 'Updated')
    expect(page).to have_selector('div[id=candidate_event_2_verified]', text: false)
    if @dev.empty?
      expect(page).to have_field("candidate_candidate_events_attributes_2_completed_date", with: Date.today.to_s.strip)
    else
      expect(page).to have_selector('div[id=candidate_event_2_completed_date]', text: Date.today)
    end
  end

  scenario 'candidate unsigns agreement' do

    AppFactory.add_confirmation_event(I18n.t('events.sign_agreement'))
    @candidate.signed_agreement=true
    @candidate.save

    visit @path
    uncheck('Signed agreement')
    click_button('Update')

    expect_message(:flash_notice, 'Updated')
    expect(page).to have_selector('div[id=candidate_event_2_verified]', text: false)
    if @dev.empty?
      expect(page).to have_field("candidate_candidate_events_attributes_2_completed_date")
    else
      expect(page).to have_selector('div[id=candidate_event_2_completed_date]', text: nil)
    end
  end

  def expect_form_layout(signed_agreement)

    expect(page).to have_selector("form[id=edit_candidate][action=\"/#{@dev}sign_agreement.#{@candidate.id}\"]")

    # expect(page).to have_selector('code', text: I18n.t('views.candidates.convenant_agreement'))

    if signed_agreement
      expect(page).to have_checked_field('Signed agreement')
    else
      expect(page).not_to have_checked_field('Signed agreement')
    end

    expect(page).to have_button(I18n.t('views.common.update'))
    expect(page).to have_button(I18n.t('views.common.download'))
  end

end
