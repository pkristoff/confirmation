# frozen_string_literal: true

# rubocop:disable RSpec/ContextWording
shared_context 'orphaned_scanned_image' do
  # rubocop:enable RSpec/ContextWording
  include ViewsHelpers
  before do
    FactoryBot.create(:visitor)
    @today = Time.zone.today
  end

  describe 'baptismal_certificate' do
    before do
      AppFactory.add_confirmation_event(BaptismalCertificate.event_key)
      candidate = Candidate.find_by(id: @candidate.id)
      bc = candidate.baptismal_certificate
      bc.scanned_certificate = FactoryBot.create(:scanned_image,
                                                 filename: 'actions.png',
                                                 content_type: 'image/png',
                                                 content: 'vvv')
      candidate.save
    end

    it 'remove the scanned image for a baptismal_certificate' do
      remove_scanned_image(Candidate.find_by(id: @candidate.id),
                           Event::Route::BAPTISMAL_CERTIFICATE,
                           { baptismal_certificate_attributes: { baptized_at_home_parish: '0', show_empty_radio: 0,
                                                                 remove_certificate_picture: 'Remove',
                                                                 id: @candidate.baptismal_certificate.id } })
    end
  end

  describe 'retreat_verification' do
    before do
      AppFactory.add_confirmation_event(RetreatVerification.event_key)
      candidate = Candidate.find_by(id: @candidate.id)
      rv = candidate.retreat_verification
      rv.scanned_retreat = FactoryBot.create(:scanned_image,
                                             filename: 'actions.png',
                                             content_type: 'image/png',
                                             content: 'vvv')
      candidate.save
    end

    it 'remove the scanned image for a retreat_verification' do
      remove_scanned_image(Candidate.find_by(id: @candidate.id),
                           Event::Route::RETREAT_VERIFICATION,
                           { retreat_verification_attributes: { remove_retreat_verification_picture: 'Remove',
                                                                id: @candidate.retreat_verification.id } })
    end
  end

  describe 'sponsor_covenant' do
    before do
      AppFactory.add_confirmation_event(SponsorCovenant.event_key)
      candidate = Candidate.find_by(id: @candidate.id)
      sc = candidate.sponsor_covenant
      sc.scanned_covenant = FactoryBot.create(:scanned_image,
                                              filename: 'actions.png',
                                              content_type: 'image/png',
                                              content: 'vvv')
      candidate.save
    end

    it 'remove the scanned image for a sponsor_covenant' do
      remove_scanned_image(Candidate.find_by(id: @candidate.id),
                           Event::Route::SPONSOR_COVENANT,
                           { sponsor_covenant_attributes: { remove_sponsor_covenant_picture: 'Remove',
                                                            id: @candidate.sponsor_covenant.id } })
    end
  end

  describe 'sponsor_eligibility' do
    before do
      AppFactory.add_confirmation_event(SponsorEligibility.event_key)
      AppFactory.add_confirmation_event(SponsorCovenant.event_key)
      candidate = Candidate.find_by(id: @candidate.id)
      se = candidate.sponsor_eligibility
      se.sponsor_attends_home_parish = false
      se.scanned_eligibility = FactoryBot.create(:scanned_image,
                                                 filename: 'actions.png',
                                                 content_type: 'image/png',
                                                 content: 'vvv')
      candidate.save
    end

    it 'remove the scanned image for a sponsor_covenant' do
      remove_scanned_image(Candidate.find_by(id: @candidate.id),
                           Event::Route::SPONSOR_ELIGIBILITY,
                           { sponsor_eligibility_attributes: { remove_sponsor_eligibility_picture: 'Remove',
                                                               id: @candidate.sponsor_eligibility.id } })
    end
  end
end

private

def remove_scanned_image(candidate, route, attributes)
  expect(ScannedImage.all.size).to eq(1)
  put :event_with_picture_update,
      params: { id: candidate.id,
                event_route: route,
                candidate: attributes }
  candidate = Candidate.find_by(id: candidate.id)
  expect(candidate.get_event_association(route).scanned_image).to be_nil
  # ignoring this fact for now
  # expect(candidate.get_event_association(route).scanned_image_id).to be_nil
  expect(ScannedImage.all.size).to eq(0)
end
