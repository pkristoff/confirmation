# frozen_string_literal: true

shared_context 'baptismal_certificate' do
  include ViewsHelpers
  before(:each) do
    Visitor.visitor('St. Mary Magdalene', 'replace me - home', 'replace me - about', 'replace me - contaclt')
    AppFactory.add_confirmation_event(BaptismalCertificate.event_key)
    @today = Time.zone.today
  end

  it 'should show baptismal_certificate for the candidate.' do
    expect(@candidate.baptismal_certificate).not_to eq(nil)

    put :event_with_picture, params: { id: @candidate.id, event_route: Event::Route::BAPTISMAL_CERTIFICATE }

    # expect(response).to render_template('event_with_picture')
    expect(controller.candidate).to eq(@candidate)
    expect(@request.fullpath).to eq("/#{@dev}event_with_picture/#{@candidate.id}/baptismal_certificate")

    expect(controller.candidate.baptismal_certificate).not_to eq(nil)
  end

  it 'show should update the candidate baptismal_certificate info and update Candidate event.' do
    candidate = Candidate.find(@candidate.id)
    candidate.baptismal_certificate = BaptismalCertificate.new
    candidate_event = candidate.get_candidate_event(BaptismalCertificate.event_key)
    expect(candidate_event.completed_date).to eq(nil)

    put :event_with_picture_update,
        params: { id: candidate.id,
                  event_route: Event::Route::BAPTISMAL_CERTIFICATE,
                  candidate: { baptismal_certificate_attributes: { baptized_at_home_parish: '1', show_empty_radio: 1 } } }

    candidate = Candidate.find(@candidate.id)
    candidate_event = candidate.get_candidate_event(BaptismalCertificate.event_key)
    expect(response.status).to eq(200)
    expect(@request.fullpath).to eq("/#{@dev}event_with_picture/#{candidate.id}/baptismal_certificate")
    expect(candidate.baptismal_certificate.baptized_at_home_parish).to eq(true)
    expect(candidate_event.completed_date).to eq(@today)
  end

  it 'show should illegal parameter.' do
    candidate = Candidate.find(@candidate.id)
    candidate.baptismal_certificate = BaptismalCertificate.new
    candidate_event = candidate.get_candidate_event(BaptismalCertificate.event_key)
    expect(candidate_event.completed_date).to eq(nil)
    expect(candidate.baptismal_certificate.baptized_at_home_parish).to eq(false)

    put :event_with_picture_update, params: { id: candidate.id, event_route: Event::Route::BAPTISMAL_CERTIFICATE }

    candidate = Candidate.find(@candidate.id)
    candidate_event = candidate.get_candidate_event(BaptismalCertificate.event_key)
    expect(response.status).to eq(200)
    expect(@request.fullpath).to eq("/#{@dev}event_with_picture/#{candidate.id}/baptismal_certificate")
    expect(candidate.baptismal_certificate.baptized_at_home_parish).to eq(false)
    expect(candidate_event.completed_date).to eq(nil)

    # expect(response).to render_template('candidates/event_with_picture')
    expect(flash[:alert]).to eq('Unknown Parameter: candidate')
  end

  it 'should show illegal parameter.' do
    candidate = Candidate.find(@candidate.id)
    candidate_event = candidate.get_candidate_event(BaptismalCertificate.event_key)
    expect(candidate_event.completed_date).to eq(nil)

    put :event_with_picture_update,
        params: { id: candidate.id,
                  event_route: Event::Route::BAPTISMAL_CERTIFICATE,
                  candidate: { baptismal_certificate_attributes: { baptized_at_home_parish: '0' } } }

    candidate = Candidate.find(@candidate.id)
    candidate_event = candidate.get_candidate_event(BaptismalCertificate.event_key)
    # expect(response).to redirect_to(baptismal_certificate_update_path(candidate.id))

    expect(response.status).to eq(200)
    expect(@request.fullpath).to eq("/#{@dev}event_with_picture/#{candidate.id}/baptismal_certificate")
    expect(candidate.baptismal_certificate.baptized_at_home_parish).to eq(false)
    expect(candidate.baptismal_certificate).not_to eq(nil)
    expect(candidate_event.completed_date.to_s).to eq('')

    # expect(response).to render_template('candidates/event_with_picture')
    # expect(assigns(:candidate).errors.empty?).not_to be true
  end

  it 'User fills in all info and updates' do
    candidate = Candidate.find(@candidate.id)

    vps = valid_parameters_bc(candidate.baptismal_certificate.id)
    vps[:certificate_picture] = fixture_file_upload('Baptismal Certificate.png', 'image/png')
    # cannot do an add & remove aat same time
    vps[:remove_certificate_picture] = nil
    put :event_with_picture_update,
        params: { id: candidate.id,
                  event_route: Event::Route::BAPTISMAL_CERTIFICATE,
                  candidate: { baptismal_certificate_attributes: vps } }

    expect(response.status).to eq(200)
    expect(flash[:notice]).to eq(I18n.t('messages.updated', cand_name: 'Sophia Agusta'))
  end

  [I18n.t('views.common.update'), I18n.t('views.common.update_verify'), I18n.t('views.common.un_verify')].each do |commit_value|
    it "Admin removes baptismal picture and undoes events completed state.  commit = #{commit_value}" do
      candidate = Candidate.find(@candidate.id)
      baptismal_certificate = make_valid_bc(candidate)

      update_event(candidate, @today, false, BaptismalCertificate.event_key)
      candidate.save

      expect(baptismal_certificate.scanned_certificate).to_not be_nil

      cand_bc_params = valid_parameters_bc(baptismal_certificate.id)

      put :event_with_picture_update,
          params: { id: candidate.id,
                    commit: commit_value,
                    event_route: Event::Route::BAPTISMAL_CERTIFICATE,
                    candidate: { baptismal_certificate_attributes: cand_bc_params } }

      candidate = Candidate.find(@candidate.id)
      baptismal_certificate = candidate.baptismal_certificate
      expect(baptismal_certificate.scanned_certificate).to be_nil unless commit_value == I18n.t('views.common.un_verify')
      expect(baptismal_certificate.scanned_certificate).to_not be_nil if commit_value == I18n.t('views.common.un_verify')
      candidate_event = candidate.get_candidate_event(BaptismalCertificate.event_key)
      expect(candidate_event.completed_date).to be_nil unless commit_value == I18n.t('views.common.un_verify')
      expect(candidate_event.completed_date).to eq(@today) if commit_value == I18n.t('views.common.un_verify')
      expect(candidate_event.verified).to be(false)
    end

    it 'Admin removes baptismal picture and undoes events completed state and verified state' do
      candidate = Candidate.find(@candidate.id)
      baptismal_certificate = make_valid_bc(candidate)

      update_event(candidate, @today, true, BaptismalCertificate.event_key)
      candidate.save

      expect(baptismal_certificate.scanned_certificate).to_not be_nil

      cand_bc_params = valid_parameters_bc(baptismal_certificate.id)

      put :event_with_picture_update,
          params: { id: candidate.id,
                    event_route: Event::Route::BAPTISMAL_CERTIFICATE,
                    candidate: { baptismal_certificate_attributes: cand_bc_params } }

      candidate = Candidate.find(@candidate.id)
      baptismal_certificate = candidate.baptismal_certificate
      expect(baptismal_certificate.scanned_certificate).to be_nil unless commit_value == I18n.t('views.common.un_verify')
      expect(baptismal_certificate.scanned_certificate).to be_nil if commit_value == I18n.t('views.common.un_verify')
      candidate_event = candidate.get_candidate_event(BaptismalCertificate.event_key)
      expect(candidate_event.completed_date).to be_nil
      expect(candidate_event.verified).to be(false)
    end
  end

  def valid_parameters_bc(id)
    {
      baptized_at_home_parish: '0',
      birth_date: '2000-07-01',
      baptismal_date: '2000-09-27',
      church_name: 'St. Paul',
      church_address_attributes: {
        street_1: 'St. Paul Way',
        street_2: 'Apt. 5',
        city: 'Holy Smoke',
        state: 'KS',
        zip_code: '55555'
      },
      father_first: 'Moses',
      father_middle: 'Cane',
      father_last: 'Abel',
      mother_first: 'Mary',
      mother_middle: 'Middle',
      mother_maiden: 'Maiden',
      mother_last: 'Maiden',
      remove_certificate_picture: 'Remove',
      id: id.to_s
    }
  end

  def make_valid_bc(candidate)
    baptismal_certificate = candidate.baptismal_certificate
    baptismal_certificate.baptized_at_home_parish = false
    baptismal_certificate.birth_date = @today
    baptismal_certificate.baptismal_date = @today
    baptismal_certificate.church_name = 'St. me'
    baptismal_certificate.father_first = 'Paul'
    baptismal_certificate.father_middle = 'R'
    baptismal_certificate.father_last = 'K'
    baptismal_certificate.mother_first = 'Vicki'
    baptismal_certificate.mother_middle = 'A'
    baptismal_certificate.mother_maiden = 'K'
    baptismal_certificate.mother_last = 'K'
    baptismal_certificate.church_address.street_1 = 'street_1'
    baptismal_certificate.church_address.city = 'city'
    baptismal_certificate.church_address.state = 'state'
    baptismal_certificate.church_address.zip_code = '99999'
    baptismal_certificate.scanned_certificate = FactoryBot.create(:scanned_image,
                                                                  filename: 'actions.png',
                                                                  content_type: 'image/png',
                                                                  content: 'vvv')
    baptismal_certificate
  end
end

shared_context 'sign_agreement' do
  before(:each) do
    @today = Time.zone.today
  end

  it 'should show sign_agreement for the candidate.' do
    get :sign_agreement, params: { id: @candidate.id }

    # expect(response).to render_template('sign_agreement')
    expect(controller.candidate).to eq(@candidate)
    expect(@request.fullpath).to eq("/#{@dev}sign_agreement.#{@candidate.id}")
  end

  it 'show should update the candidate to signing the confirmation agreement and update Candidate event.' do
    AppFactory.add_confirmation_event(Candidate.covenant_agreement_event_key)

    candidate = Candidate.find(@candidate.id)
    candidate_event = candidate.get_candidate_event(Candidate.covenant_agreement_event_key)
    expect(candidate_event.completed_date).to eq(nil)

    put :sign_agreement_update, params: { id: candidate.id, candidate: { signed_agreement: 1 } }

    candidate = Candidate.find(@candidate.id)
    candidate_event = candidate.get_candidate_event(Candidate.covenant_agreement_event_key)

    expect(response.status).to eq(200)
    expect(@request.fullpath).to eq("/#{@dev}sign_agreement.#{candidate.id}")
    expect(candidate.signed_agreement).to eq(true)
    expect(candidate_event.completed_date).to eq(@today)
  end
end

shared_context 'retreat_verification' do
  before(:each) do
    AppFactory.add_confirmation_event(RetreatVerification.event_key)
    @today = Time.zone.today
  end

  [I18n.t('views.common.update'), I18n.t('views.common.update_verify'), I18n.t('views.common.un_verify')].each do |commit_value|
    it "Admin removes retreat verification picture and undoes events completed state.  commit = #{commit_value}" do
      candidate = Candidate.find(@candidate.id)
      retreat_verification = make_valid_rv(candidate)

      update_event(candidate, @today, false, RetreatVerification.event_key)
      candidate.save

      expect(retreat_verification.scanned_retreat).to_not be_nil

      cand_rv_params = valid_parameters_rv(retreat_verification.id)

      put :event_with_picture_update,
          params: { id: candidate.id,
                    commit: commit_value,
                    event_route: Event::Route::RETREAT_VERIFICATION,
                    candidate: { retreat_verification_attributes: cand_rv_params } }

      candidate = Candidate.find(@candidate.id)
      retreat_verification = candidate.retreat_verification
      expect(retreat_verification.scanned_retreat).to be_nil unless commit_value == I18n.t('views.common.un_verify')
      expect(retreat_verification.scanned_retreat).to_not be_nil if commit_value == I18n.t('views.common.un_verify')
      candidate_event = candidate.get_candidate_event(RetreatVerification.event_key)
      expect(candidate_event.completed_date).to be_nil unless commit_value == I18n.t('views.common.un_verify')
      expect(candidate_event.completed_date).to eq(@today) if commit_value == I18n.t('views.common.un_verify')
      expect(candidate_event.verified).to be(false)
    end

    it "Admin removes retreat picture and undoes events completed state and verified state. commit = #{commit_value}" do
      candidate = Candidate.find(@candidate.id)
      retreat_verification = make_valid_rv(candidate)

      update_event(candidate, @today, true, RetreatVerification.event_key)
      candidate.save

      expect(retreat_verification.scanned_retreat).to_not be_nil

      cand_bc_params = valid_parameters_rv(retreat_verification.id)

      put :event_with_picture_update,
          params: { id: candidate.id,
                    event_route: Event::Route::RETREAT_VERIFICATION,
                    candidate: { retreat_verification_attributes: cand_bc_params } }

      candidate = Candidate.find(@candidate.id)
      retreat_verification = candidate.retreat_verification
      expect(retreat_verification.scanned_retreat).to be_nil unless commit_value == I18n.t('views.common.un_verify')
      expect(retreat_verification.scanned_retreat).to be_nil if commit_value == I18n.t('views.common.un_verify')
      candidate_event = candidate.get_candidate_event(RetreatVerification.event_key)
      expect(candidate_event.completed_date).to be_nil
      expect(candidate_event.verified).to be(false)
    end
  end

  def valid_parameters_rv(id)
    {
      retreat_held_at_home_parish: '0',
      start_date: @today.to_s,
      end_date: @today.to_s,
      who_held_retreat: 'c',
      where_held_retreat: 'St. Paul',
      remove_retreat_verification_picture: 'Remove',
      id: id.to_s
    }
  end

  def make_valid_rv(candidate)
    retreat_verification = candidate.retreat_verification
    retreat_verification.retreat_held_at_home_parish = false
    retreat_verification.start_date = @today
    retreat_verification.end_date = @today
    retreat_verification.who_held_retreat = 'St. Paul'
    retreat_verification.where_held_retreat = 'St. Paul'
    retreat_verification.scanned_retreat = FactoryBot.create(:scanned_image,
                                                             filename: 'actions.png',
                                                             content_type: 'image/png',
                                                             content: 'vvv')
    retreat_verification
  end
end

shared_context 'sponsor_covenant' do
  before(:each) do
    AppFactory.add_confirmation_event(SponsorCovenant.event_key)
    @today = Time.zone.today
  end
  [I18n.t('views.common.update'), I18n.t('views.common.update_verify'), I18n.t('views.common.un_verify')].each do |commit_value|
    it "Admin removes sponsor covenant picture and undoes events completed state.  commit = #{commit_value}" do
      candidate = Candidate.find(@candidate.id)
      sponsor_covenant = make_valid_sc(candidate)

      update_event(candidate, @today, false, SponsorCovenant.event_key)
      candidate.save

      expect(sponsor_covenant.scanned_covenant).to_not be_nil

      cand_sc_params = valid_parameters_sc(sponsor_covenant.id)

      put :event_with_picture_update,
          params: { id: candidate.id,
                    commit: commit_value,
                    event_route: Event::Route::SPONSOR_COVENANT,
                    candidate: { sponsor_covenant_attributes: cand_sc_params } }

      candidate = Candidate.find(@candidate.id)
      sponsor_covenant = candidate.sponsor_covenant
      expect(sponsor_covenant.scanned_covenant).to be_nil unless commit_value == I18n.t('views.common.un_verify')
      expect(sponsor_covenant.scanned_covenant).to_not be_nil if commit_value == I18n.t('views.common.un_verify')
      candidate_event = candidate.get_candidate_event(SponsorCovenant.event_key)
      expect(candidate_event.completed_date).to be_nil unless commit_value == I18n.t('views.common.un_verify')
      expect(candidate_event.completed_date).to eq(@today) if commit_value == I18n.t('views.common.un_verify')
      expect(candidate_event.verified).to be(false)
    end

    it 'Admin removes sponsor covenant picture and undoes events completed state and verified state' do
      candidate = Candidate.find(@candidate.id)
      sponsor_covenant = make_valid_sc(candidate)

      update_event(candidate, @today, true, SponsorCovenant.event_key)
      candidate.save

      expect(sponsor_covenant.scanned_covenant).to_not be_nil

      cand_sc_params = valid_parameters_sc(sponsor_covenant.id)

      put :event_with_picture_update,
          params: { id: candidate.id,
                    event_route: Event::Route::SPONSOR_COVENANT,
                    candidate: { sponsor_covenant_attributes: cand_sc_params } }

      candidate = Candidate.find(@candidate.id)
      sponsor_covenant = candidate.sponsor_covenant
      expect(sponsor_covenant.scanned_covenant).to be_nil unless commit_value == I18n.t('views.common.un_verify')
      expect(sponsor_covenant.scanned_covenant).to be_nil if commit_value == I18n.t('views.common.un_verify')
      candidate_event = candidate.get_candidate_event(SponsorCovenant.event_key)
      expect(candidate_event.completed_date).to be_nil
      expect(candidate_event.verified).to be(false)
    end
  end

  def valid_parameters_sc(id)
    {
      sponsor_name: 'youyoou',
      remove_sponsor_covenant_picture: 'Remove',
      id: id.to_s
    }
  end

  def make_valid_sc(candidate)
    sponsor_covenant = candidate.sponsor_covenant
    sponsor_covenant.sponsor_name = 'meme'
    sponsor_covenant.scanned_covenant = FactoryBot.create(:scanned_image,
                                                          filename: 'actions.png',
                                                          content_type: 'image/png',
                                                          content: 'vvv')
    sponsor_covenant
  end
end

shared_context 'sponsor_eligibility' do
  before(:each) do
    AppFactory.add_confirmation_event(SponsorEligibility.event_key)
    @today = Time.zone.today
  end
  [I18n.t('views.common.update'), I18n.t('views.common.update_verify'), I18n.t('views.common.un_verify')].each do |commit_value|
    it "Admin removes sponsor eligibility picture and undoes events completed state.  commit = #{commit_value}" do
      candidate = Candidate.find(@candidate.id)
      sponsor_eligibility = make_valid_se(candidate)

      update_event(candidate, @today, false, SponsorEligibility.event_key)
      candidate.save

      expect(sponsor_eligibility.scanned_eligibility).to_not be_nil

      cand_se_params = valid_parameters_se(sponsor_eligibility.id)

      put :event_with_picture_update,
          params: { id: candidate.id,
                    commit: commit_value,
                    event_route: Event::Route::SPONSOR_ELIGIBILITY,
                    candidate: { sponsor_eligibility_attributes: cand_se_params } }

      candidate = Candidate.find(@candidate.id)
      sponsor_eligibility = candidate.sponsor_eligibility
      expect(sponsor_eligibility.scanned_eligibility).to be_nil unless commit_value == I18n.t('views.common.un_verify')
      expect(sponsor_eligibility.scanned_eligibility).to_not be_nil if commit_value == I18n.t('views.common.un_verify')
      candidate_event = candidate.get_candidate_event(SponsorEligibility.event_key)
      expect(candidate_event.completed_date).to be_nil unless commit_value == I18n.t('views.common.un_verify')
      expect(candidate_event.completed_date).to eq(@today) if commit_value == I18n.t('views.common.un_verify')
      expect(candidate_event.verified).to be(false)
    end

    it 'Admin removes sponsor eligibility picture and undoes events completed state and verified state' do
      candidate = Candidate.find(@candidate.id)
      sponsor_eligibility = make_valid_se(candidate)

      update_event(candidate, @today, true, SponsorEligibility.event_key)
      candidate.save

      expect(sponsor_eligibility.scanned_eligibility).to_not be_nil

      cand_se_params = valid_parameters_se(sponsor_eligibility.id)

      put :event_with_picture_update,
          params: { id: candidate.id,
                    event_route: Event::Route::SPONSOR_ELIGIBILITY,
                    candidate: { sponsor_eligibility_attributes: cand_se_params } }

      candidate = Candidate.find(@candidate.id)
      sponsor_eligibility = candidate.sponsor_eligibility
      expect(sponsor_eligibility.scanned_eligibility).to be_nil unless commit_value == I18n.t('views.common.un_verify')
      expect(sponsor_eligibility.scanned_eligibility).to be_nil if commit_value == I18n.t('views.common.un_verify')
      candidate_event = candidate.get_candidate_event(SponsorEligibility.event_key)
      expect(candidate_event.completed_date).to be_nil
      expect(candidate_event.verified).to be(false)
    end

    it "Admin removes sponsor eligibility picture and undoes events completed state.  commit = #{commit_value}" do
      candidate = Candidate.find(@candidate.id)
      sponsor_eligibility = make_valid_se(candidate)

      update_event(candidate, @today, false, SponsorEligibility.event_key)
      candidate.save

      cand_se_params = valid_parameters_se(sponsor_eligibility.id)

      put :event_with_picture_update,
          params: { id: candidate.id,
                    commit: commit_value,
                    event_route: Event::Route::SPONSOR_ELIGIBILITY,
                    candidate: { sponsor_eligibility_attributes: cand_se_params } }

      candidate = Candidate.find(@candidate.id)
      sponsor_eligibility = candidate.sponsor_eligibility
      expect(sponsor_eligibility.scanned_eligibility).to be_nil unless commit_value == I18n.t('views.common.un_verify')
      expect(sponsor_eligibility.scanned_eligibility).to_not be_nil if commit_value == I18n.t('views.common.un_verify')
      candidate_event = candidate.get_candidate_event(SponsorEligibility.event_key)
      expect(candidate_event.completed_date).to be_nil unless commit_value == I18n.t('views.common.un_verify')
      expect(candidate_event.completed_date).to eq(@today) if commit_value == I18n.t('views.common.un_verify')
      expect(candidate_event.verified).to be(false)
    end
  end

  def valid_parameters_se(id)
    {
      sponsor_attends_home_parish: '0',
      sponsor_church: 'St. youyou',
      remove_sponsor_eligibility_picture: 'Remove',
      id: id.to_s
    }
  end

  def make_valid_se(candidate)
    sponsor_eligibility = candidate.sponsor_eligibility
    sponsor_eligibility.sponsor_attends_home_parish = false
    sponsor_eligibility.sponsor_church = 'St. meme'
    sponsor_eligibility.scanned_eligibility = FactoryBot.create(:scanned_image,
                                                                filename: 'actions.png',
                                                                content_type: 'image/png',
                                                                content: 'lll')
    sponsor_eligibility
  end
end

shared_context 'candidate_information_sheet' do
  before(:each) do
    @today = Time.zone.today
  end

  it 'should show information_sheet for the candidate.' do
    get :candidate_sheet, params: { id: @candidate.id }

    # expect(response).to render_template('candidate_sheet')
    expect(controller.candidate).to eq(@candidate)
    expect(@request.fullpath).to eq("/#{@dev}candidate_sheet.#{@candidate.id}")
  end

  it 'show should update the candidate to fill out candidate sheet and update Candidate event.' do
    AppFactory.add_confirmation_event(CandidateSheet.event_key)

    candidate = Candidate.find(@candidate.id)
    candidate_event = candidate.get_candidate_event(CandidateSheet.event_key)
    expect(candidate_event.completed_date).to eq(nil)

    put :candidate_sheet_update,
        params: { id: candidate.id,
                  candidate: {
                    candidate_sheet_attributes:
                      { first_name: 'Paul',
                        middle_name: 'Richard',
                        last_name: 'Foo',
                        grade: 10,
                        program_year: 2,
                        candidate_email: 'foo@bar.com',
                        parent_email_1: 'baz@bar.com',
                        attending: Candidate::THE_WAY,
                        address_attributes: {
                          street_1: 'the way way',
                          city: 'wayville',
                          state: 'WA',
                          zip_code: '27502'
                        } }
                  } }

    candidate = Candidate.find(@candidate.id)
    candidate_event = candidate.get_candidate_event(CandidateSheet.event_key)
    expect(response.status).to eq(200)
    expect(candidate.candidate_sheet.first_name).to eq('Paul')
    expect(candidate.candidate_sheet.middle_name).to eq('Richard')
    expect(candidate.candidate_sheet.address.city).to eq('wayville')
    expect(candidate_event.completed_date).to eq(@today)
  end
end

def update_event(candidate, completed_date, verified, event_key)
  candidate_event = candidate.get_candidate_event(event_key)
  candidate_event.completed_date = completed_date
  candidate_event.verified = verified
end
