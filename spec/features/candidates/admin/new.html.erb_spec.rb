# frozen_string_literal: true

Warden.test_mode!

require 'constants'

describe 'Orphan removal', :devise do
  include Warden::Test::Helpers

  before do
    FactoryBot.create(:visitor)
    admin = FactoryBot.create(:admin)
    login_as(admin, scope: :admin)
    @orphaneds = Orphaneds.new
  end

  after do
    Warden.test_reset!
  end

  context 'when orphaned check' do
    it 'Check with no orphans' do
      expect(Visitor.visitor.home_parish).to eq('St. Mary Magdalene')
      visit orphaneds_check_path
      click_button I18n.t('views.orphaneds.check_orphaned_table_rows')

      expect_message(:flash_notice, I18n.t('messages.orphaneds.check.no_orphans_found'))
    end

    it 'Check with orphans' do
      expected_orphans
      visit orphaneds_check_path
      click_button I18n.t('views.orphaneds.check_orphaned_table_rows')

      expect_message(:flash_notice, I18n.t('messages.orphaneds.check.orphans_found'))
      expect(page).to have_selector('li[id=BaptismalCertificate]', text: 'BaptismalCertificate: 1')
      expect(page).to have_selector('li[id=CandidateSheet]', text: 'CandidateSheet: 1')
      expect(page).to have_selector('li[id=ChristianMinistry]', text: 'ChristianMinistry: 1')
      expect(page).to have_selector('li[id=PickConfirmationName]', text: 'PickConfirmationName: 1')
      expect(page).to have_selector('li[id=RetreatVerification]', text: 'RetreatVerification: 1')
      expect(page).to have_selector('li[id=SponsorCovenant]', text: 'SponsorCovenant: 1')
      expect(page).to have_selector('li[id=SponsorEligibility]', text: 'SponsorEligibility: 1')
      expect(page).to have_selector('li[id=ScannedImage]', text: 'ScannedImage: 1')
      expect(page).to have_selector('li[id=Address]', text: 'Address: 1')
      expect(page).to have_selector('li[id=ToDo]', text: 'ToDo: 1')
    end

    describe 'Remove' do
      it 'Remove with no orphans' do
        visit orphaneds_check_path
        click_button I18n.t('views.orphaneds.remove_orphaned_table_rows')
        expect_message(:flash_notice, I18n.t('messages.orphaneds.check.no_orphans_found'))
      end

      it 'Remove with orphans' do
        expected_orphans
        visit orphaneds_check_path
        click_button I18n.t('views.orphaneds.remove_orphaned_table_rows')
        expect_message(:flash_notice, I18n.t('messages.orphaneds.check.no_orphans_found'))
      end
    end
  end
end

private

def expected_orphans
  {
    # Candidate associations
    BaptismalCertificate: FactoryBot.create(:baptismal_certificate, skip_address_replacement: true),
    CandidateSheet: FactoryBot.create(:candidate_sheet),
    ChristianMinistry: FactoryBot.create(:christian_ministry),
    PickConfirmationName: FactoryBot.create(:pick_confirmation_name),
    RetreatVerification: FactoryBot.create(:retreat_verification),
    SponsorCovenant: FactoryBot.create(:sponsor_covenant),
    SponsorEligibility: FactoryBot.create(:sponsor_eligibility),
    # # other associations
    ScannedImage: FactoryBot.create(:scanned_image),
    Address: FactoryBot.create(:address),
    ToDo: FactoryBot.create(:to_do, confirmation_event_id: nil, candidate_event_id: nil)
  }
end
