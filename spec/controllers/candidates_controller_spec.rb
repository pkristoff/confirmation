# frozen_string_literal: true

describe CandidatesController do
  before(:each) do
    @admdin = login_admin
  end

  it 'should NOT have a current_candidate' do
    expect(subject.current_candidate).to eq(nil)
  end

  it 'should show sorted list of candidates' do
    c1 = create_candidate('c1')
    c2 = create_candidate('c2')
    c3 = create_candidate('c3')
    get :index
    expect(response).to render_template('index')
    expect(response.status).to eq(200)
    expect(controller.candidate_info.size).to eq(3)
    expect(controller.candidate_info[0].id).to eq(c1.id)
    expect(controller.candidate_info[1].id).to eq(c2.id)
    expect(controller.candidate_info[2].id).to eq(c3.id)
  end

  it 'should show sorted list of candidates based on first_name' do
    c1 = create_candidate('c1')
    c2 = create_candidate('c2')
    c3 = create_candidate('c3')
    get :index, direction: 'asc', sort: 'candidate_sheet.first_name'
    expect(response).to render_template('index')
    expect(response.status).to eq(200)
    # order not important js will do it
    expect(controller.candidate_info.size).to eq(3)
    [c1, c2, c3].each_with_index do |candidate, index|
      expect(controller.candidate_info[index].id).to eq(candidate.id)
    end
  end

  it 'should show sorted list of candidates based on last_name' do
    c1 = create_candidate('c1')
    c2 = create_candidate('c2')
    c3 = create_candidate('c3')
    get :index, direction: 'asc', sort: 'candidate_sheet.last_name'
    expect(response).to render_template('index')
    expect(response.status).to eq(200)
    # order not important js will do it
    expect(controller.candidate_info.size).to eq(3)
    [c1, c2, c3].each_with_index do |candidate, index|
      expect(controller.candidate_info[index].id).to eq(candidate.id)
    end
  end

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
    end
    candidate.save
    candidate
  end

  describe 'show' do
    it 'show should show candidate.' do
      candidate = FactoryBot.create(:candidate)
      get :show, id: candidate.id
      expect(response).to render_template('show')
      expect(controller.candidate).to eq(candidate)
      expect(@request.fullpath).to eq("/candidates/#{candidate.id}")
    end
  end

  describe 'pick_confirmation_name_verify' do
    before(:each) do
      c1 = create_candidate('c1')
      @c1_id = c1.id
      AppFactory.add_confirmation_event(I18n.t('events.confirmation_name'))
    end

    it 'should set @candidate' do
      get :pick_confirmation_name_verify, id: @c1_id

      cand = Candidate.find(@c1_id)
      expect(controller.candidate).to eq(cand)
      expect(response).to render_template('candidates/pick_confirmation_name_verify')
      expect(@request.fullpath).to eq("/pick_confirmation_name_verify.#{cand.id}")
    end

    it 'should stay on pick_confirmation_name_verify, since it should not pass validation' do
      put :pick_confirmation_name_verify_update,
          id: @c1_id, candidate: { candidate_ids: [] }

      cand = Candidate.find(@c1_id)
      expect(controller.candidate).to eq(cand)
      expect(response).to render_template('candidates/pick_confirmation_name_verify')
      expect(@request.fullpath).to eq("/pick_confirmation_name_verify.#{cand.id}")

      cand_event = cand.get_candidate_event(I18n.t('events.confirmation_name'))
      expect(cand_event.completed_date).to eq(nil)
      expect(cand_event.verified).to eq(false)
    end

    it 'should goes back to mass_edit_candidates_event, updating verified' do
      completed_date = Date.today - 20
      cand = Candidate.find(@c1_id)
      cand.pick_confirmation_name.saint_name = 'george'
      cand.save

      cand_event = cand.get_candidate_event(I18n.t('events.confirmation_name'))
      cand_event.completed_date = completed_date
      cand.save

      put :pick_confirmation_name_verify_update,
          id: @c1_id, candidate: { candidate_ids: [] }

      cand = Candidate.find(@c1_id)
      expect(controller.candidate).to eq(cand)
      expect(response).to render_template('admins/mass_edit_candidates_event')
      expect(@request.fullpath).to eq("/pick_confirmation_name_verify.#{cand.id}")

      cand_event = cand.get_candidate_event(I18n.t('events.confirmation_name'))
      expect(cand_event.completed_date).to eq(completed_date)
      expect(cand_event.verified).to eq(true)
    end

    it 'should goes back to mass_edit_candidates_event, updating verified when admin fills in missing data' do
      put :pick_confirmation_name_verify_update,
          id: @c1_id,
          candidate: { pick_confirmation_name_attributes: { saint_name: 'foo' } }

      cand = Candidate.find(@c1_id)
      expect(cand.pick_confirmation_name.saint_name).to eq('foo')

      expect(controller.candidate).to eq(cand)
      expect(response).to render_template('admins/mass_edit_candidates_event')
      expect(@request.fullpath).to eq("/pick_confirmation_name_verify.#{cand.id}?candidate%5Bpick_confirmation_name_attributes%5D%5Bsaint_name%5D=foo")

      cand_event = cand.get_candidate_event(I18n.t('events.confirmation_name'))
      expect(cand_event.completed_date).to eq(Date.today)
      expect(cand_event.verified).to eq(true)
    end
  end

  describe 'sponsor_agreement_verify' do
    before(:each) do
      c1 = create_candidate('c1')
      @c1_id = c1.id
      AppFactory.add_confirmation_event(I18n.t('events.sponsor_agreement'))
    end

    it 'should set @candidate' do
      get :sponsor_agreement_verify, id: @c1_id

      cand = Candidate.find(@c1_id)
      expect(controller.candidate).to eq(cand)
      expect(response).to render_template('candidates/sponsor_agreement_verify')
      expect(@request.fullpath).to eq("/sponsor_agreement_verify.#{cand.id}")
    end

    it 'should stay on sponsor_agreement_verify, since it should not pass validation' do
      put :sponsor_agreement_verify_update,
          id: @c1_id, candidate: { sponsor_agreement: '0' }

      cand = Candidate.find(@c1_id)
      expect(controller.candidate).to eq(cand)
      expect(response).to render_template('candidates/sponsor_agreement_verify')
      expect(@request.fullpath).to eq("/sponsor_agreement_verify.#{cand.id}?candidate%5Bsponsor_agreement%5D=0")

      cand_event = cand.get_candidate_event(I18n.t('events.sponsor_agreement'))
      expect(cand_event.completed_date).to eq(nil)
      expect(cand_event.verified).to eq(false)
    end

    it 'should goes back to mass_edit_candidates_event, updating verified' do
      completed_date = Date.today - 20
      cand = Candidate.find(@c1_id)
      cand.sponsor_agreement = true
      cand.save

      cand_event = cand.get_candidate_event(I18n.t('events.sponsor_agreement'))
      cand_event.completed_date = completed_date
      cand_event.verified = false
      cand.save

      put :sponsor_agreement_verify_update,
          id: @c1_id, candidate: { sponsor_agreement: '1' }

      cand = Candidate.find(@c1_id)
      expect(controller.candidate).to eq(cand)
      expect(response).to render_template('admins/mass_edit_candidates_event')
      expect(@request.fullpath).to eq("/sponsor_agreement_verify.#{cand.id}?candidate%5Bsponsor_agreement%5D=1")

      cand_event = cand.get_candidate_event(I18n.t('events.sponsor_agreement'))
      expect(cand_event.completed_date).to eq(completed_date)
      expect(cand_event.verified).to eq(true)
    end

    it 'should goes back to mass_edit_candidates_event, updating verified when admin fills in missing data' do
      put :sponsor_agreement_verify_update,
          id: @c1_id,
          candidate: { sponsor_agreement: '1' }

      cand = Candidate.find(@c1_id)
      expect(cand.sponsor_agreement).to eq(true)

      expect(controller.candidate).to eq(cand)
      expect(response).to render_template('admins/mass_edit_candidates_event')
      expect(@request.fullpath).to eq("/sponsor_agreement_verify.#{cand.id}?candidate%5Bsponsor_agreement%5D=1")

      cand_event = cand.get_candidate_event(I18n.t('events.sponsor_agreement'))
      expect(cand_event.completed_date).to eq(Date.today)
      expect(cand_event.verified).to eq(true)
    end
  end

  describe 'sign_agreement_verify' do
    before(:each) do
      c1 = create_candidate('c1')
      @c1_id = c1.id
      AppFactory.add_confirmation_event(I18n.t('events.candidate_covenant_agreement'))
    end

    it 'should set @candidate' do
      get :sign_agreement_verify, id: @c1_id

      cand = Candidate.find(@c1_id)
      expect(controller.candidate).to eq(cand)
      expect(response).to render_template('candidates/sign_agreement_verify')
      expect(@request.fullpath).to eq("/sign_agreement_verify.#{cand.id}")
    end

    it 'should stay on sign_agreement_verify, since it should not pass validation' do
      put :sign_agreement_verify_update,
          id: @c1_id, candidate: { signed_agreement: '0' }

      cand = Candidate.find(@c1_id)
      expect(controller.candidate).to eq(cand)
      expect(response).to render_template('candidates/sign_agreement_verify')
      expect(@request.fullpath).to eq("/sign_agreement_verify.#{cand.id}?candidate%5Bsigned_agreement%5D=0")

      cand_event = cand.get_candidate_event(I18n.t('events.candidate_covenant_agreement'))
      expect(cand_event.completed_date).to eq(nil)
      expect(cand_event.verified).to eq(false)
    end

    it 'should goes back to mass_edit_candidates_event, updating verified' do
      completed_date = Date.today - 20
      cand = Candidate.find(@c1_id)
      cand.signed_agreement = true
      cand.save

      cand_event = cand.get_candidate_event(I18n.t('events.candidate_covenant_agreement'))
      cand_event.completed_date = completed_date
      cand_event.verified = false
      cand.save

      put :sign_agreement_verify_update,
          id: @c1_id, candidate: { signed_agreement: '1' }

      cand = Candidate.find(@c1_id)
      expect(controller.candidate).to eq(cand)
      expect(response).to render_template('admins/mass_edit_candidates_event')
      expect(@request.fullpath).to eq("/sign_agreement_verify.#{cand.id}?candidate%5Bsigned_agreement%5D=1")

      cand_event = cand.get_candidate_event(I18n.t('events.candidate_covenant_agreement'))
      expect(cand_event.completed_date).to eq(completed_date)
      expect(cand_event.verified).to eq(true)
    end

    it 'should goes back to mass_edit_candidates_event, updating verified when admin fills in missing data' do
      put :sign_agreement_verify_update,
          id: @c1_id,
          candidate: { signed_agreement: '1' }

      cand = Candidate.find(@c1_id)
      expect(cand.signed_agreement).to eq(true)

      expect(controller.candidate).to eq(cand)
      expect(response).to render_template('admins/mass_edit_candidates_event')
      expect(@request.fullpath).to eq("/sign_agreement_verify.#{cand.id}?candidate%5Bsigned_agreement%5D=1")

      cand_event = cand.get_candidate_event(I18n.t('events.candidate_covenant_agreement'))
      expect(cand_event.completed_date).to eq(Date.today)
      expect(cand_event.verified).to eq(true)
    end
  end

  describe 'event_with_picture_verify' do
    before(:each) do
      c1 = create_candidate('c1')
      @c1_id = c1.id
      AppFactory.add_confirmation_event(I18n.t('events.baptismal_certificate'))
      AppFactory.add_confirmation_event(I18n.t('events.retreat_verification'))
      AppFactory.add_confirmation_event(I18n.t('events.sponsor_covenant'))
    end

    [
      ['baptismal_certificate',
       lambda do |candidate|
         candidate.baptismal_certificate.baptized_at_stmm = true
       end,
       lambda do |candidate|
         {
           baptismal_certificate_attributes: {
             baptized_at_stmm: 1,
             show_empty_radio: 1,
             id: candidate.id
           }
         }
       end],
      ['retreat_verification',
       lambda do |candidate|
         candidate.retreat_verification.retreat_held_at_stmm = true
       end,
       lambda do |candidate|
         {
           retreat_verification_attributes: {
             retreat_held_at_stmm: candidate.retreat_verification.retreat_held_at_stmm,
             id: candidate.retreat_verification.id
           }
         }
       end],
      ['sponsor_covenant', lambda do |candidate|
        candidate.sponsor_covenant.sponsor_name = 'mmm'
        candidate.sponsor_covenant.sponsor_attends_stmm = true
        File.open('spec/fixtures/Baptismal Certificate.pdf', 'rb') do |f|
          candidate.sponsor_covenant.scanned_covenant =
            candidate.sponsor_covenant.build_scanned_covenant(
              filename: 'Baptismal Certificate.pdf',
              content_type: 'application/pdf',
              content: f.read
            )
        end
        # candidate.sponsor_covenant.scanned_covenant = FactoryBot.create(:scanned_image, filename: 'actions.png', content_type: 'image/png', content: 'WWW')
      end,
       lambda do |candidate|
         {
           sponsor_covenant_attributes: {
             sponsor_name: candidate.sponsor_covenant.sponsor_name,
             sponsor_attends_stmm: candidate.sponsor_covenant.sponsor_attends_stmm,
             id: candidate.sponsor_covenant.id
           }
         }
       end]
    ].each do |event_info|

      event_name_key = event_info[0]
      valid_setter = event_info[1]
      generate_cand_parms = event_info[2]

      it "should set @candidate: #{event_name_key}" do
        get :event_with_picture_verify, id: @c1_id, event_name: event_name_key

        cand = Candidate.find(@c1_id)
        expect(controller.candidate).to eq(cand)
        expect(response).to render_template('candidates/event_with_picture_verify')
        expect(@request.fullpath).to eq("/event_with_picture_verify/#{cand.id}/#{event_name_key}")
      end

      it "should stay on event_with_picture_verify, since it should not pass validation: #{event_name_key}" do
        put :event_with_picture_verify_update, id: @c1_id, event_name: event_name_key

        cand = Candidate.find(@c1_id)
        expect(controller.candidate).to eq(cand)
        expect(response).to render_template('candidates/event_with_picture_verify')
        expect(@request.fullpath).to eq("/event_with_picture_verify/#{cand.id}/#{event_name_key}")

        cand_event = cand.get_candidate_event(I18n.t("events.#{event_name_key}"))
        expect(cand_event.completed_date).to eq(nil)
        expect(cand_event.verified).to eq(false)
      end

      it "should goes back to mass_edit_candidates_event, updating verified: #{event_name_key}" do
        completed_date = Date.today - 20
        cand = Candidate.find(@c1_id)
        valid_setter.call(cand)
        cand.save

        cand_event = cand.get_candidate_event(I18n.t("events.#{event_name_key}"))
        cand_event.completed_date = completed_date
        cand.save

        cand_parms = generate_cand_parms.call(cand)

        put :event_with_picture_verify_update,
            id: @c1_id,
            event_name: event_name_key,
            candidate: cand_parms

        cand = Candidate.find(@c1_id)
        expect(controller.candidate).to eq(cand)
        expect(response).to render_template('admins/mass_edit_candidates_event')
        expect(@request.fullpath).to include("/event_with_picture_verify/#{cand.id}/#{event_name_key}")

        cand_event = cand.get_candidate_event(I18n.t("events.#{event_name_key}"))
        expect(cand_event.completed_date).to eq(completed_date)
        expect(cand_event.verified).to eq(true)
      end
    end
  end

  describe 'christian_ministry_verify' do
    before(:each) do
      c1 = create_candidate('c1')
      @c1_id = c1.id
      AppFactory.add_confirmation_event(I18n.t('events.christian_ministry'))
    end

    it 'should set @candidate' do
      get :christian_ministry_verify, id: @c1_id

      cand = Candidate.find(@c1_id)
      expect(controller.candidate).to eq(cand)
      expect(response).to render_template('candidates/christian_ministry_verify')
      expect(@request.fullpath).to eq("/christian_ministry_verify.#{cand.id}")
    end

    it 'should stay on christian_ministry_verify, since it should not pass validation' do
      put :christian_ministry_verify_update,
          id: @c1_id, candidate: { candidate_ids: [] }

      cand = Candidate.find(@c1_id)
      expect(controller.candidate).to eq(cand)
      expect(response).to render_template('candidates/christian_ministry_verify')
      expect(@request.fullpath).to eq("/christian_ministry_verify.#{cand.id}")

      cand_event = cand.get_candidate_event(I18n.t('events.christian_ministry'))
      expect(cand_event.completed_date).to eq(nil)
      expect(cand_event.verified).to eq(false)
    end

    it 'should goes back to mass_edit_candidates_event, updating verified' do
      completed_date = Date.today - 20
      cand = Candidate.find(@c1_id)
      cand.christian_ministry.what_service = 'xxx'
      cand.christian_ministry.where_service = 'yyy'
      cand.christian_ministry.when_service = 'zzz'
      cand.christian_ministry.helped_me = 'eee'
      cand.save

      cand_event = cand.get_candidate_event(I18n.t('events.christian_ministry'))
      cand_event.completed_date = completed_date
      cand.save

      put :christian_ministry_verify_update,
          id: @c1_id, candidate: { candidate_ids: [] }

      cand = Candidate.find(@c1_id)
      expect(controller.candidate).to eq(cand)
      expect(response).to render_template('admins/mass_edit_candidates_event')
      expect(@request.fullpath).to eq("/christian_ministry_verify.#{cand.id}")

      cand_event = cand.get_candidate_event(I18n.t('events.christian_ministry'))
      expect(cand_event.completed_date).to eq(completed_date)
      expect(cand_event.verified).to eq(true)
    end

    it 'should goes back to mass_edit_candidates_event, updating verified when admin fills in missing data' do
      put :christian_ministry_verify_update,
          id: @c1_id,
          candidate: { christian_ministry_attributes:
                         { what_service: 'ccc',
                           where_service: 'bbb',
                           when_service: 'aaa',
                           helped_me: 'qqq' } }

      cand = Candidate.find(@c1_id)
      expect(cand.christian_ministry.what_service).to eq('ccc')
      expect(cand.christian_ministry.where_service).to eq('bbb')
      expect(cand.christian_ministry.when_service).to eq('aaa')
      expect(cand.christian_ministry.helped_me).to eq('qqq')

      expect(controller.candidate).to eq(cand)
      expect(response).to render_template('admins/mass_edit_candidates_event')

      expect(@request.fullpath).to eq("/christian_ministry_verify.#{cand.id}?candidate%5Bchristian_ministry_attributes%5D%5Bhelped_me%5D=qqq&candidate%5Bchristian_ministry_attributes%5D%5Bwhat_service%5D=ccc&candidate%5Bchristian_ministry_attributes%5D%5Bwhen_service%5D=aaa&candidate%5Bchristian_ministry_attributes%5D%5Bwhere_service%5D=bbb")

      cand_event = cand.get_candidate_event(I18n.t('events.christian_ministry'))
      expect(cand_event.completed_date).to eq(Date.today)
      expect(cand_event.verified).to eq(true)
    end
  end

  describe 'candidate_sheet_verify' do
    before(:each) do
      c0 = FactoryBot.create(:candidate)
      @c0_id = c0.id
      AppFactory.add_confirmation_event(I18n.t('events.candidate_information_sheet'))
    end

    it 'should set @candidate' do
      get :candidate_sheet_verify, id: @c0_id

      cand = Candidate.find(@c0_id)
      expect(controller.candidate).to eq(cand)
      expect(response).to render_template('candidates/candidate_sheet_verify')
      expect(@request.fullpath).to eq("/candidate_sheet_verify.#{cand.id}")
    end

    it 'should stay on christian_ministry_verify, since it should not pass validation' do
      cand = Candidate.find(@c0_id)
      cand.candidate_sheet.candidate_email = 'm'
      cand.save(validate: false)

      put :candidate_sheet_verify_update,
          id: @c0_id, candidate: { candidate_ids: [] }

      cand = Candidate.find(@c0_id)
      expect(controller.candidate).to eq(cand)
      expect(response).to render_template('candidates/candidate_sheet_verify')
      expect(@request.fullpath).to eq("/candidate_sheet_verify.#{cand.id}")

      cand_event = cand.get_candidate_event(I18n.t('events.candidate_information_sheet'))
      expect(cand_event.completed_date).to eq(nil)
      expect(cand_event.verified).to eq(false)
    end

    it 'should goes back to mass_edit_candidates_event, updating verified' do
      completed_date = Date.today - 20
      cand = Candidate.find(@c0_id)
      cand.candidate_sheet.candidate_email = 'foo@kristoffs.com'
      cand.save

      cand_event = cand.get_candidate_event(I18n.t('events.candidate_information_sheet'))
      cand_event.completed_date = completed_date
      cand.save

      put :candidate_sheet_verify_update,
          id: @c0_id, candidate: { candidate_ids: [] }

      cand = Candidate.find(@c0_id)
      expect(controller.candidate).to eq(cand)
      expect(response).to render_template('admins/mass_edit_candidates_event')
      expect(@request.fullpath).to eq("/candidate_sheet_verify.#{cand.id}")

      cand_event = cand.get_candidate_event(I18n.t('events.candidate_information_sheet'))
      expect(cand_event.completed_date).to eq(completed_date)
      expect(cand_event.verified).to eq(true)
    end

    it 'should goes back to mass_edit_candidates_event, updating verified when admin fills in missing data' do
      cand = Candidate.find(@c0_id)
      cand.candidate_sheet.candidate_email = 'm'
      cand.save(validate: false)

      put :candidate_sheet_verify_update,
          id: @c0_id,
          candidate: { candidate_sheet_attributes:
                         { first_name: 'Paul',
                           middle_name: 'Richard',
                           last_name: 'Foo',
                           grade: 10,
                           candidate_email: 'foo@bar.com',
                           parent_email_1: 'baz@bar.com',
                           attending: 'The Way',
                           address_attributes: {
                             street_1: 'the way way',
                             city: 'wayville',
                             state: 'WA',
                             zip_code: '27502'
                           } } }

      cand = Candidate.find(@c0_id)
      expect(cand.candidate_sheet.candidate_email).to eq('foo@bar.com')

      expect(controller.candidate).to eq(cand)
      expect(response).to render_template('admins/mass_edit_candidates_event')

      expect(@request.fullpath.include?("/candidate_sheet_verify.#{cand.id}")).to eq(true)

      cand_event = cand.get_candidate_event(I18n.t('events.candidate_information_sheet'))
      expect(cand_event.completed_date).to eq(Date.today)
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

    describe 'sponsor_agreement' do
      it_behaves_like 'sponsor_agreement'
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

    describe 'retreat_verification' do
      it_behaves_like 'retreat_verification'
    end
  end
end
