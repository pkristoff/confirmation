include Warden::Test::Helpers
Warden.test_mode!

feature 'Candidate event', :devise do

  before(:each) do
    @candidate = FactoryGirl.create(:candidate)
    login_as(@candidate, scope: :candidate)
  end

  after(:each) do
    Warden.test_reset!
  end

  scenario 'candidate logs in, selects sign agreement, has not signed agreetment previsouly' do
    @candidate.signed_agreement=false
    visit sign_agreement_path(@candidate.id)
    expect_form_layout(@candidate.signed_agreement)
  end

  scenario 'candidate logs in, selects sign agreement, has signed agreetment previsouly' do
    @candidate.signed_agreement=true
    visit sign_agreement_path(@candidate.id)
    expect_form_layout(@candidate.signed_agreement)
  end

  scenario 'candidate signs agreement' do

    AppFactory.add_confirmation_event(I18n.t('events.sign_agreement'))
    @candidate.signed_agreement=false

    visit sign_agreement_path(@candidate.id)
    check('Signed agreement')
    click_button('Update')

    expect_message(:flash_notice, 'Updated')
    expect(page).to have_selector('div[id=candidate_event_2_verified]', text: false)
    expect(page).to have_selector('div[id=candidate_event_2_completed_date]', text: Date.today)
  end

  def expect_form_layout(signed_agreement)

    expect(page).to have_selector("form[id=edit_candidate][action=\"/sign_agreement.#{@candidate.id}\"]")

    expect(page).to have_selector('code', text: I18n.t('views.candidates.convenant_agreement'))

    if signed_agreement
      expect(page).to have_checked_field('Signed agreement')
    else
      expect(page).not_to have_checked_field('Signed agreement')
    end

    expect(page).to have_button(I18n.t('views.common.update'))
  end

end
