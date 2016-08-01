describe Dev::CandidatesController do
  before(:each) do
    @login_candidate = login_candidate
  end

  it 'should NOT have a current_candidate' do
    expect(subject.current_candidate).to eq(@login_candidate)
  end

  describe 'index' do

    it 'index does not exist for a candidate' do
      begin
        get :index
        expect(false).to eq(true) # should never be executed.
      rescue ActionController::UrlGenerationError => err
        expect(err.message).to eq('No route matches {:action=>"index", :controller=>"dev/candidates"}')
      end
    end

  end

  describe 'edit' do

    it 'should not edit candidate' do
      begin
        get :edit, id: @login_candidate.id
        expect(false).to eq(true) # should never be executed.
      rescue ActionController::UrlGenerationError => err
        expect(err.message).to eq("No route matches {:action=>\"edit\", :controller=>\"dev/candidates\", :id=>\"#{@login_candidate.id}\"}")
      end
    end

  end

  describe 'show' do

    it 'show should not rediect if admin is logged in.' do

      get :show, id: @login_candidate.id
      expect(response).to render_template('show')
      expect(controller.candidate).to eq(@login_candidate)
      expect(@request.fullpath).to eq("/show/#{@login_candidate.id}")
    end

  end

  describe 'sign_agreement' do

    it 'should show sign_agreement for the candidate.' do

      get :sign_agreement, id: @login_candidate.id
      expect(response).to render_template('sign_agreement')
      expect(controller.candidate).to eq(@login_candidate)
      expect(@request.fullpath).to eq("/sign_agreement.#{@login_candidate.id}")
    end

    it 'show should update the candidate to signing the confirmation agreement and update Candidate event.' do

      AppFactory.add_confirmation_event(I18n.t('events.sign_agreement'))

      candidate = Candidate.find(@login_candidate.id)
      candidate_event = candidate.candidate_events.find { |ce| ce.name == I18n.t('events.sign_agreement') }
      expect(candidate_event.completed_date).to eq(nil)

      put :sign_agreement_update, id: candidate.id, candidate: {signed_agreement: 1}

      candidate = Candidate.find(@login_candidate.id)
      candidate_event = candidate.candidate_events.find { |ce| ce.name == I18n.t('events.sign_agreement') }
      expect(response).to redirect_to(event_candidate_registration_path(candidate.id))
      expect(@request.fullpath).to eq("/sign_agreement.#{candidate.id}?candidate%5Bsigned_agreement%5D=1")
      expect(candidate.signed_agreement).to eq(true)
      expect(candidate_event.completed_date).to eq(Date.today)
    end

  end

  describe 'fill_out_candidate_sheet' do

    it 'should show fill_out_candidate_sheet for the candidate.' do

      get :candidate_sheet, id: @login_candidate.id

      expect(response).to render_template('candidate_sheet')
      expect(controller.candidate).to eq(@login_candidate)
      expect(@request.fullpath).to eq("/candidate_sheet.#{@login_candidate.id}")
    end

    it 'show should update the candidate to fill out candidate sheet and update Candidate event.' do

      AppFactory.add_confirmation_event(I18n.t('events.fill_out_candidate_sheet'))

      candidate = Candidate.find(@login_candidate.id)
      candidate_event = candidate.candidate_events.find { |ce| ce.name == I18n.t('events.fill_out_candidate_sheet') }
      expect(candidate_event.completed_date).to eq(nil)

      put :candidate_sheet_update, id: candidate.id, candidate: {first_name: 'Paul'}

      candidate = Candidate.find(@login_candidate.id)
      candidate_event = candidate.candidate_events.find { |ce| ce.name == I18n.t('events.fill_out_candidate_sheet') }
      expect(response).to redirect_to(event_candidate_registration_path(candidate.id))
      expect(@request.fullpath).to eq("/candidate_sheet.#{candidate.id}?candidate%5Bfirst_name%5D=Paul")
      expect(candidate.first_name).to eq('Paul')
      expect(candidate_event.completed_date).to eq(Date.today)
    end

  end

  describe 'upload_baptismal_certificate' do

    it 'should show upload_baptismal_certificate for the candidate.' do

      expect(@login_candidate.baptismal_certificate).to eq(nil)

      get :upload_baptismal_certificate, id: @login_candidate.id

      expect(response).to render_template('upload_baptismal_certificate')
      expect(controller.candidate).to eq(@login_candidate)
      expect(@request.fullpath).to eq("/dev/upload_baptismal_certificate.#{@login_candidate.id}")

      expect(controller.candidate.baptismal_certificate).not_to eq(nil)
    end

    it 'show should update the candidate upload_baptismal_certificate info and update Candidate event.' do

      AppFactory.add_confirmation_event(I18n.t('events.upload_baptismal_certificate'))

      candidate = Candidate.find(@login_candidate.id)
      candidate.baptismal_certificate = BaptismalCertificate.new
      candidate_event = candidate.candidate_events.find { |ce| ce.name == I18n.t('events.upload_baptismal_certificate') }
      expect(candidate_event.completed_date).to eq(nil)

      put :baptismal_certificate_update, id: candidate.id, candidate: {baptized_at_stmm: '1'}

      candidate = Candidate.find(@login_candidate.id)
      candidate_event = candidate.candidate_events.find { |ce| ce.name == I18n.t('events.upload_baptismal_certificate') }
      expect(response.status).to eq(302)
      expect(@request.fullpath).to eq("/dev/upload_baptismal_certificate.#{candidate.id}?candidate%5Bbaptized_at_stmm%5D=1")
      expect(candidate.baptized_at_stmm).to eq(true)
      expect(candidate.baptismal_certificate).to eq(nil)
      expect(candidate_event.completed_date).to eq(Date.today)
    end

    it 'show should illegal parameter.' do

      AppFactory.add_confirmation_event(I18n.t('events.upload_baptismal_certificate'))

      candidate = Candidate.find(@login_candidate.id)
      candidate.baptismal_certificate = BaptismalCertificate.new
      candidate_event = candidate.candidate_events.find { |ce| ce.name == I18n.t('events.upload_baptismal_certificate') }
      expect(candidate_event.completed_date).to eq(nil)

      put :baptismal_certificate_update, id: candidate.id

      candidate = Candidate.find(@login_candidate.id)
      candidate_event = candidate.candidate_events.find { |ce| ce.name == I18n.t('events.upload_baptismal_certificate') }
      # expect(response).to redirect_to(baptismal_certificate_update_path(candidate.id))
      expect(response.status).to eq(200)
      expect(@request.fullpath).to eq("/dev/upload_baptismal_certificate.#{candidate.id}")
      expect(candidate.baptized_at_stmm).to eq(true)
      expect(candidate.baptismal_certificate).to eq(nil)
      expect(candidate_event.completed_date).to eq(nil)

      expect(response).to render_template('dev/candidates/baptismal_certificate_update')
      expect(flash[:alert]).to eq('Unknown Parameter: candidate')
    end

    it 'should show illegal parameter.' do

      AppFactory.add_confirmation_event(I18n.t('events.upload_baptismal_certificate'))

      candidate = Candidate.find(@login_candidate.id)
      candidate.baptismal_certificate = BaptismalCertificate.new
      candidate_event = candidate.candidate_events.find { |ce| ce.name == I18n.t('events.upload_baptismal_certificate') }
      expect(candidate_event.completed_date).to eq(nil)

      put :baptismal_certificate_update,
          id: candidate.id,
          candidate: {baptized_at_stmm: '0',
                      baptismal_certificate_attributes: {},}

      candidate = Candidate.find(@login_candidate.id)
      candidate_event = candidate.candidate_events.find { |ce| ce.name == I18n.t('events.upload_baptismal_certificate') }
      # expect(response).to redirect_to(baptismal_certificate_update_path(candidate.id))
      expect(response.status).to eq(200)
      expect(@request.fullpath).to eq("/dev/upload_baptismal_certificate.#{candidate.id}?candidate%5Bbaptized_at_stmm%5D=0")
      expect(candidate.baptized_at_stmm).to eq(false)
      expect(candidate.baptismal_certificate).not_to eq(nil)
      expect(candidate_event.completed_date.to_s).to eq('')

      expect(response).to render_template('dev/candidates/baptismal_certificate_update')
      expect(flash[:alert]).to eq(I18n.t('messages.certificate_not_blank'))
    end

    it 'User fills in all info and updates' do

      AppFactory.add_confirmation_event(I18n.t('events.upload_baptismal_certificate'))

      candidate = Candidate.find(@login_candidate.id)

      valid_parameters = get_valid_parameters
      valid_parameters[:certificate_picture] = fixture_file_upload('Baptismal Certificate.png', 'image/png')
      put :baptismal_certificate_update,
          id: candidate.id,
          candidate: {baptized_at_stmm: '0',
                      baptismal_certificate_attributes: valid_parameters
          }

      expect(response).to redirect_to("/dev/registrations/event/#{candidate.id}")
      expect(flash[:notice]).to eq(I18n.t('messages.updated'))
    end

    def get_valid_parameters
      {
          birth_date: '2000-07-01',
          baptismal_date: '2000-09-27',
          church_name: 'St. Paul',
          church_address_attributes: {
              street_1: 'St. Paul Way',
              street_2: 'Apt. 5',
              city: 'Holy Smoke',
              state: 'KS',
              zip_code: '55555',
          },
          father_first: 'Moses',
          father_middle: 'Cane',
          father_last: 'Abel',
          mother_first: 'Mary',
          mother_middle: 'Middle',
          mother_maiden: 'Maiden',
          mother_last: 'Maiden'
      }
    end

  end

end