# frozen_string_literal: true

describe CandidatesController do
  before(:each) do
    @admdin = login_admin
    @today = Time.zone.today
  end

  it 'should NOT have a current_candidate' do
    expect(subject.current_candidate).to eq(nil)
  end

  it 'should show sorted list of candidates' do
    c1 = create_candidate('c1')
    c2 = create_candidate('c2')
    c3 = create_candidate('c3')
    get :index
    # expect(response).to render_template('index')
    expect(response.status).to eq(200)
    expect(controller.candidate_info.size).to eq(3)
    expect(controller.candidate_info[0].account_name).to eq(c1.account_name)
    expect(controller.candidate_info[1].account_name).to eq(c2.account_name)
    expect(controller.candidate_info[2].account_name).to eq(c3.account_name)
  end

  it 'should show sorted list of candidates based on first_name' do
    c1 = create_candidate('c1')
    c2 = create_candidate('c2')
    c3 = create_candidate('c3')
    get :index, params: { direction: 'asc', sort: 'candidate_sheets.first_name' }
    # expect(response).to render_template('index')
    expect(response.status).to eq(200)
    # order not important js will do it
    expect(controller.candidate_info.size).to eq(3)
    [c3, c1, c2].each_with_index do |candidate, index|
      expect(controller.candidate_info[index].account_name).to eq(candidate.account_name)
    end
  end

  it 'should show sorted list of candidates based on last_name' do
    c1 = create_candidate('c1')
    c2 = create_candidate('c2')
    c3 = create_candidate('c3')
    get :index, params: { direction: 'asc', sort: 'candidate_sheets.last_name' }
    # expect(response).to render_template('index')
    expect(response.status).to eq(200)
    # order not important js will do it
    expect(controller.candidate_info.size).to eq(3)
    [c2, c3, c1].each_with_index do |candidate, index|
      expect(controller.candidate_info[index].account_name).to eq(candidate.account_name)
    end
  end

  private

  def create_candidate(prefix)
    candidate = FactoryBot.create(:candidate, account_name: prefix)
    case prefix
    when 'c1'
      candidate.candidate_sheet.first_name = 'c2first_name'
      candidate.candidate_sheet.middle_name = 'c1middle_name'
      candidate.candidate_sheet.last_name = 'c3last_name'
    when 'c2'
      candidate.candidate_sheet.first_name = 'c3first_name'
      candidate.candidate_sheet.middle_name = 'c2middle_name'
      candidate.candidate_sheet.last_name = 'c1last_name'
    when 'c3'
      candidate.candidate_sheet.first_name = 'c1first_name'
      candidate.candidate_sheet.middle_name = 'c3middle_name'
      candidate.candidate_sheet.last_name = 'c2last_name'
    else
      raise 'unknown prefix'
    end
    candidate.save
    candidate
  end

  describe 'show' do
    it 'show should show candidate.' do
      candidate = FactoryBot.create(:candidate)
      get :show, params: { id: candidate.id }
      # expect(response).to render_template('show')
      expect(controller.candidate).to eq(candidate)
      expect(@request.fullpath).to eq("/candidates/#{candidate.id}")
    end
  end

  describe 'pick_confirmation_name_verify' do
    before(:each) do
      c1 = create_candidate('c1')
      @c1_id = c1.id
      AppFactory.add_confirmation_event(PickConfirmationName.event_key)
    end

    it 'should set @candidate' do
      get :pick_confirmation_name_verify, params: { id: @c1_id }

      cand = Candidate.find(@c1_id)
      expect(controller.candidate).to eq(cand)
      # expect(response).to render_template('candidates/pick_confirmation_name_verify')
      expect(@request.fullpath).to eq("/pick_confirmation_name_verify.#{cand.id}")
    end

    it 'should stay on pick_confirmation_name_verify, since it should not pass validation' do
      put :pick_confirmation_name_verify_update,
          params: { id: @c1_id,
                    candidate: { pick_confirmation_name_attributes:
                                   { saint_name: '', id: Candidate.find(@c1_id).pick_confirmation_name.id } } }

      cand = Candidate.find(@c1_id)
      expect(controller.candidate).to eq(cand)
      # expect(response).to render_template('candidates/pick_confirmation_name_verify')
      expect(@request.fullpath).to eq("/pick_confirmation_name_verify.#{cand.id}")

      cand_event = cand.get_candidate_event(PickConfirmationName.event_key)
      expect(cand_event.completed_date).to eq(nil)
      expect(cand_event.verified).to eq(false)
    end

    it 'should goes back to mass_edit_candidates_event, updating verified' do
      completed_date = @today - 20
      cand = Candidate.find(@c1_id)
      cand.pick_confirmation_name.saint_name = 'george'
      cand.save

      cand_event = cand.get_candidate_event(PickConfirmationName.event_key)
      cand_event.completed_date = completed_date
      cand.save

      put :pick_confirmation_name_verify_update,
          params: { id: @c1_id,
                    candidate: { pick_confirmation_name_attributes:
                                   { saint_name: 'george', id: Candidate.find(@c1_id).pick_confirmation_name.id } } }

      cand = Candidate.find(@c1_id)
      expect(controller.candidate).to eq(cand)
      # expect(response).to render_template('admins/mass_edit_candidates_event')
      expect(@request.fullpath).to eq("/pick_confirmation_name_verify.#{cand.id}")

      cand_event = cand.get_candidate_event(PickConfirmationName.event_key)
      expect(cand_event.completed_date).to eq(completed_date)
      expect(cand_event.verified).to eq(true)
    end

    it 'should goes back to mass_edit_candidates_event, updating verified when admin fills in missing data' do
      put :pick_confirmation_name_verify_update,
          params: { id: @c1_id,
                    candidate: { pick_confirmation_name_attributes:
                                   { saint_name: 'foo', id: Candidate.find(@c1_id).pick_confirmation_name.id } } }

      cand = Candidate.find(@c1_id)
      expect(cand.pick_confirmation_name.saint_name).to eq('foo')

      expect(controller.candidate).to eq(cand)
      # expect(response).to render_template('admins/mass_edit_candidates_event')
      expect(@request.fullpath).to eq("/pick_confirmation_name_verify.#{cand.id}")

      cand_event = cand.get_candidate_event(PickConfirmationName.event_key)
      expect(cand_event.completed_date).to eq(@today)
      expect(cand_event.verified).to eq(true)
    end
  end

  describe 'sign_agreement_verify' do
    before(:each) do
      c1 = create_candidate('c1')
      @c1_id = c1.id
      AppFactory.add_confirmation_event(Candidate.covenant_agreement_event_key)
    end

    it 'should set @candidate' do
      get :sign_agreement_verify, params: { id: @c1_id }

      cand = Candidate.find(@c1_id)
      expect(controller.candidate).to eq(cand)
      # expect(response).to render_template('candidates/sign_agreement_verify')
      expect(@request.fullpath).to eq("/sign_agreement_verify.#{cand.id}")
    end

    it 'should stay on sign_agreement_verify, since it should not pass validation' do
      put :sign_agreement_verify_update,
          params: { id: @c1_id, candidate: { signed_agreement: '0' } }

      cand = Candidate.find(@c1_id)
      expect(controller.candidate).to eq(cand)
      # expect(response).to render_template('candidates/sign_agreement_verify')
      expect(@request.fullpath).to eq("/sign_agreement_verify.#{cand.id}")

      cand_event = cand.get_candidate_event(Candidate.covenant_agreement_event_key)
      expect(cand_event.completed_date).to eq(nil)
      expect(cand_event.verified).to eq(false)
    end

    it 'should goes back to mass_edit_candidates_event, updating verified' do
      completed_date = @today - 20
      cand = Candidate.find(@c1_id)
      cand.signed_agreement = true
      cand.save

      cand_event = cand.get_candidate_event(Candidate.covenant_agreement_event_key)
      cand_event.completed_date = completed_date
      cand_event.verified = false
      cand.save

      put :sign_agreement_verify_update,
          params: { id: @c1_id, candidate: { signed_agreement: '1' } }

      cand = Candidate.find(@c1_id)
      expect(controller.candidate).to eq(cand)
      # expect(response).to render_template('admins/mass_edit_candidates_event')
      expect(@request.fullpath).to eq("/sign_agreement_verify.#{cand.id}")

      cand_event = cand.get_candidate_event(Candidate.covenant_agreement_event_key)
      expect(cand_event.completed_date).to eq(completed_date)
      expect(cand_event.verified).to eq(true)
    end

    it 'should goes back to mass_edit_candidates_event, updating verified when admin fills in missing data' do
      put :sign_agreement_verify_update,
          params: { id: @c1_id,
                    candidate: { signed_agreement: '1' } }

      cand = Candidate.find(@c1_id)
      expect(cand.signed_agreement).to eq(true)

      expect(controller.candidate).to eq(cand)
      # expect(response).to render_template('admins/mass_edit_candidates_event')
      expect(@request.fullpath).to eq("/sign_agreement_verify.#{cand.id}")

      cand_event = cand.get_candidate_event(Candidate.covenant_agreement_event_key)
      expect(cand_event.completed_date).to eq(@today)
      expect(cand_event.verified).to eq(true)
    end
  end

  describe 'event_with_picture_verify' do
    before(:each) do
      c1 = create_candidate('c1')
      @c1_id = c1.id
      AppFactory.add_confirmation_event(BaptismalCertificate.event_key)
      AppFactory.add_confirmation_event(RetreatVerification.event_key)
      AppFactory.add_confirmation_event(SponsorCovenant.event_key)
      AppFactory.add_confirmation_event(SponsorEligibility.event_key)
    end

    [
      [Event::Route::BAPTISMAL_CERTIFICATE,
       lambda do |candidate|
         bc = candidate.baptismal_certificate
         bc.baptized_at_home_parish = true
         bc.birth_date = Date.parse('1998-04-09')
         bc.baptismal_date = Date.parse('1998-06-09')
         bc.father_first = 'Abe'
         bc.father_middle = 'Abem'
         bc.father_last = 'Smith'
         bc.mother_first = 'Abette'
         bc.mother_middle = 'Abettem'
         bc.mother_maiden = 'Abemaiden'
         bc.mother_last = 'Smith'
         bc.church_name = 'St. V'
         bc.church_address.street_1 = 'CCC Rd.'
         bc.church_address.city = 'CCC'
         bc.church_address.state = 'RI'
         bc.church_address.zip_code = '23456'

         cs = candidate.candidate_sheet
         cs.first_name = 'Candy'
         cs.middle_name = 'Cane'
         cs.last_name = 'Smith'
       end,
       lambda do |candidate|
         bc = candidate.baptismal_certificate
         cs = candidate.candidate_sheet
         {
           candidate_sheet_attributes: {
             first_name: cs.first_name,
             middle_name: cs.middle_name,
             last_name: cs.last_name
           },
           baptismal_certificate_attributes: {
             baptized_at_home_parish: 1,
             show_empty_radio: 1,
             father_first: bc.father_first,
             father_middle: bc.father_middle,
             father_last: bc.father_last,
             mother_first: bc.mother_first,
             mother_middle: bc.mother_middle,
             mother_maiden: bc.mother_maiden,
             mother_last: bc.mother_last,
             church_name: bc.church_name,
             church_address_attributes: {
               street_1: bc.church_address.street_1,
               city: bc.church_address.city,
               state: bc.church_address.state,
               zip_code: bc.church_address.zip_code
             },
             id: bc.id
           }
         }
       end],
      [Event::Route::RETREAT_VERIFICATION,
       lambda do |candidate|
         candidate.retreat_verification.retreat_held_at_home_parish = true
       end,
       lambda do |candidate|
         {
           retreat_verification_attributes: {
             retreat_held_at_home_parish: candidate.retreat_verification.retreat_held_at_home_parish,
             id: candidate.retreat_verification.id
           }
         }
       end],
      [Event::Route::SPONSOR_COVENANT, lambda do |candidate|
        candidate.sponsor_covenant.sponsor_name = 'mmm'
        File.open('spec/fixtures/files/Baptismal Certificate.pdf', 'rb') do |f|
          candidate.sponsor_covenant.scanned_covenant =
            candidate.sponsor_covenant.build_scanned_covenant(
              filename: 'Baptismal Certificate.pdf',
              content_type: 'application/pdf',
              content: f.read
            )
        end
      end,
       lambda do |candidate|
         {
           sponsor_covenant_attributes: {
             sponsor_name: candidate.sponsor_covenant.sponsor_name,
             # sponsor_attends_home_parish: candidate.sponsor_eligibility.sponsor_attends_home_parish,
             id: candidate.sponsor_covenant.id
           }
         }
       end,
       lambda do |candidate|
         {
           sponsor_eligibility_attributes: {
             sponsor_attends_home_parish: candidate.sponsor_eligibility.sponsor_attends_home_parish,
             id: candidate.sponsor_covenant.id
           }
         }
       end],
      [Event::Route::SPONSOR_ELIGIBILITY, lambda do |candidate|
        candidate.sponsor_eligibility.sponsor_attends_home_parish = true
        candidate.sponsor_covenant.sponsor_name = 'george'
      end,
       lambda do |candidate|
         {
           sponsor_eligibility_attributes: {
             sponsor_attends_home_parish: 1,
             id: candidate.id
           }
         }
       end]
    ].each do |event_info|
      event_route = event_info[0]
      valid_setter = event_info[1]
      generate_cand_parms = event_info[2]

      it "should set @candidate: #{event_route}" do
        get :event_with_picture_verify, params: { id: @c1_id, event_route: event_route }

        cand = Candidate.find(@c1_id)
        expect(controller.candidate).to eq(cand)
        # expect(response).to render_template('candidates/event_with_picture_verify')
        expect(@request.fullpath).to eq("/event_with_picture_verify/#{cand.id}/#{event_route}")
      end

      it "should stay on event_with_picture_verify, since it should not pass validation: #{event_route}" do
        put :event_with_picture_verify_update, params: { id: @c1_id, event_route: event_route }

        cand = Candidate.find(@c1_id)
        expect(controller.candidate).to eq(cand)
        # expect(response).to render_template('candidates/event_with_picture_verify')
        expect(@request.fullpath).to eq("/event_with_picture_verify/#{cand.id}/#{event_route}")

        cand_event = cand.get_candidate_event(Candidate.event_key_from_route(event_route))
        expect(cand_event.completed_date).to eq(nil)
        expect(cand_event.verified).to eq(false)
      end

      it "should goes back to mass_edit_candidates_event, updating verified: #{event_route}" do
        completed_date = @today - 20
        cand = Candidate.find(@c1_id)
        valid_setter.call(cand)
        cand.save!

        cand_event = cand.get_candidate_event(Candidate.event_key_from_route(event_route))
        cand_event.completed_date = completed_date
        cand.save!

        cand_parms = generate_cand_parms.call(cand)
        put :event_with_picture_verify_update,
            params: { id: @c1_id,
                      event_route: event_route,
                      candidate: cand_parms }

        cand = Candidate.find(@c1_id)
        expect(controller.candidate).to eq(cand)
        # expect(response).to render_template('admins/mass_edit_candidates_event')
        expect(@request.fullpath).to include("/event_with_picture_verify/#{cand.id}/#{event_route}")

        cand_event = cand.get_candidate_event(Candidate.event_key_from_route(event_route))
        expect(cand_event.completed_date).to eq(completed_date)
        expect(cand_event.verified).to eq(true), "cand event (#{cand_event.confirmation_event.event_key} was verified"
      end
    end
  end

  describe 'christian_ministry_verify' do
    before(:each) do
      c1 = create_candidate('c1')
      @c1_id = c1.id
      AppFactory.add_confirmation_event(ChristianMinistry.event_key)
    end

    it 'should set @candidate' do
      get :christian_ministry_verify, params: { id: @c1_id }

      cand = Candidate.find(@c1_id)
      expect(controller.candidate).to eq(cand)
      # expect(response).to render_template('candidates/christian_ministry_verify')
      expect(@request.fullpath).to eq("/christian_ministry_verify.#{cand.id}")
    end

    it 'should stay on christian_ministry_verify, since it should not pass validation' do
      put :christian_ministry_verify_update,
          params: { id: @c1_id,
                    candidate: { christian_ministry_attributes:
                                   { what_service: '',
                                     where_service: '',
                                     when_service: '',
                                     helped_me: '',
                                     id: Candidate.find(@c1_id).christian_ministry } } }

      cand = Candidate.find(@c1_id)
      expect(controller.candidate).to eq(cand)
      # expect(response).to render_template('candidates/christian_ministry_verify')
      expect(@request.fullpath).to eq("/christian_ministry_verify.#{cand.id}")

      cand_event = cand.get_candidate_event(ChristianMinistry.event_key)
      expect(cand_event.completed_date).to eq(nil)
      expect(cand_event.verified).to eq(false)
    end

    it 'should goes back to mass_edit_candidates_event, updating verified' do
      completed_date = @today - 20
      cand = Candidate.find(@c1_id)
      cand.christian_ministry.what_service = 'xxx'
      cand.christian_ministry.where_service = 'yyy'
      cand.christian_ministry.when_service = 'zzz'
      cand.christian_ministry.helped_me = 'eee'
      cand.save

      cand_event = cand.get_candidate_event(ChristianMinistry.event_key)
      cand_event.completed_date = completed_date
      cand.save

      put :christian_ministry_verify_update,
          params: { id: @c1_id,
                    candidate: { christian_ministry_attributes:
                                   { what_service: 'xxx',
                                     where_service: 'yyy',
                                     when_service: 'zzz',
                                     helped_me: 'eee',
                                     id: Candidate.find(@c1_id).christian_ministry } } }

      cand = Candidate.find(@c1_id)
      expect(controller.candidate).to eq(cand)
      # expect(response).to render_template('admins/mass_edit_candidates_event')
      expect(@request.fullpath).to eq("/christian_ministry_verify.#{cand.id}")

      cand_event = cand.get_candidate_event(ChristianMinistry.event_key)
      expect(cand_event.completed_date).to eq(completed_date)
      expect(cand_event.verified).to eq(true)
    end

    it 'should goes back to mass_edit_candidates_event, updating verified when admin fills in missing data' do
      put :christian_ministry_verify_update,
          params: { id: @c1_id,
                    candidate: { christian_ministry_attributes:
                                   { what_service: 'ccc',
                                     where_service: 'bbb',
                                     when_service: 'aaa',
                                     helped_me: 'qqq' } } }

      cand = Candidate.find(@c1_id)
      expect(cand.christian_ministry.what_service).to eq('ccc')
      expect(cand.christian_ministry.where_service).to eq('bbb')
      expect(cand.christian_ministry.when_service).to eq('aaa')
      expect(cand.christian_ministry.helped_me).to eq('qqq')

      expect(controller.candidate).to eq(cand)
      # expect(response).to render_template('admins/mass_edit_candidates_event')

      expect(@request.fullpath).to eq("/christian_ministry_verify.#{cand.id}")

      cand_event = cand.get_candidate_event(ChristianMinistry.event_key)
      expect(cand_event.completed_date).to eq(@today)
      expect(cand_event.verified).to eq(true)
    end
  end

  describe 'candidate_sheet_verify' do
    before(:each) do
      c0 = FactoryBot.create(:candidate)
      @c0_id = c0.id
      AppFactory.add_confirmation_event(CandidateSheet.event_key)
    end

    it 'should set @candidate' do
      get :candidate_sheet_verify, params: { id: @c0_id }

      cand = Candidate.find(@c0_id)
      expect(controller.candidate).to eq(cand)
      # expect(response).to render_template('candidates/candidate_sheet_verify')
      expect(@request.fullpath).to eq("/candidate_sheet_verify.#{cand.id}")
    end

    it 'should stay on christian_ministry_verify, since it should not pass validation' do
      cand = Candidate.find(@c0_id)
      cand.candidate_sheet.candidate_email = 'm'
      cand.save(validate: false)

      put :candidate_sheet_verify_update,
          params: { id: @c0_id,
                    candidate: { christian_ministry_attributes:
                                   { what_service: '',
                                     where_service: '',
                                     when_service: '',
                                     helped_me: '',
                                     id: cand.christian_ministry_id } } }

      cand = Candidate.find(@c0_id)
      expect(controller.candidate).to eq(cand)
      # expect(response).to render_template('candidates/candidate_sheet_verify')
      expect(@request.fullpath).to eq("/candidate_sheet_verify.#{cand.id}")

      cand_event = cand.get_candidate_event(CandidateSheet.event_key)
      expect(cand_event.completed_date).to eq(nil)
      expect(cand_event.verified).to eq(false)
    end

    it 'should goes back to mass_edit_candidates_event, updating verified' do
      completed_date = @today - 20
      cand = Candidate.find(@c0_id)
      cand.candidate_sheet.candidate_email = 'foo@kristoffs.com'
      cand.save

      cand_event = cand.get_candidate_event(CandidateSheet.event_key)
      cand_event.completed_date = completed_date
      cand.save

      put :candidate_sheet_verify_update,
          params: { id: @c0_id,
                    candidate: { christian_ministry_attributes:
                                   { what_service: '',
                                     where_service: '',
                                     when_service: '',
                                     helped_me: '',
                                     id: cand.christian_ministry_id } } }

      cand = Candidate.find(@c0_id)
      expect(controller.candidate).to eq(cand)
      # expect(response).to render_template('admins/mass_edit_candidates_event')
      expect(@request.fullpath).to eq("/candidate_sheet_verify.#{cand.id}")

      cand_event = cand.get_candidate_event(CandidateSheet.event_key)
      expect(cand_event.completed_date).to eq(completed_date)
      expect(cand_event.verified).to eq(true)
    end

    it 'should goes back to mass_edit_candidates_event, updating verified when admin fills in missing data' do
      cand = Candidate.find(@c0_id)
      cand.candidate_sheet.candidate_email = 'm'
      cand.save(validate: false)

      put :candidate_sheet_verify_update,
          params: { id: @c0_id,
                    candidate: { candidate_sheet_attributes:
                                   { first_name: 'Paul',
                                     middle_name: 'Richard',
                                     last_name: 'Foo',
                                     grade: 10,
                                     candidate_email: 'foo@bar.com',
                                     parent_email_1: 'baz@bar.com',
                                     attending: Candidate::THE_WAY,
                                     address_attributes: {
                                       street_1: 'the way way',
                                       city: 'wayville',
                                       state: 'WA',
                                       zip_code: '27502'
                                     } } } }

      cand = Candidate.find(@c0_id)
      expect(cand.candidate_sheet.candidate_email).to eq('foo@bar.com')

      expect(controller.candidate).to eq(cand)
      # expect(response).to render_template('admins/mass_edit_candidates_event')

      expect(@request.fullpath.include?("/candidate_sheet_verify.#{cand.id}")).to eq(true)

      cand_event = cand.get_candidate_event(CandidateSheet.event_key)
      expect(cand_event.completed_date).to eq(@today)
      expect(cand_event.verified).to eq(true)
    end
  end

  describe 'behaves like' do
    before(:each) do
      @candidate = FactoryBot.create(:candidate)
      @dev = ''
      @dev_registration = ''
    end

    describe 'sign_agreement' do
      it_behaves_like 'sign_agreement'
    end

    describe 'candidate_information_sheet' do
      it_behaves_like 'candidate_information_sheet'
    end

    describe 'baptismal_certificate' do
      it_behaves_like 'baptismal_certificate'
    end

    describe 'sponsor_covenant' do
      it_behaves_like 'sponsor_covenant'
    end

    describe 'sponsor_eligibility' do
      it_behaves_like 'sponsor_eligibility'
    end

    describe 'retreat_verification' do
      it_behaves_like 'retreat_verification'
    end
  end
end
