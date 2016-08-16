

shared_context 'upload_baptismal_certificate' do

  it 'should show upload_baptismal_certificate for the candidate.' do

    expect(@candidate.baptismal_certificate).to eq(nil)

    get :upload_baptismal_certificate, id: @candidate.id

    expect(response).to render_template('upload_baptismal_certificate')
    expect(controller.candidate).to eq(@candidate)
    expect(@request.fullpath).to eq("/#{@dev}upload_baptismal_certificate.#{@candidate.id}")

    expect(controller.candidate.baptismal_certificate).not_to eq(nil)
  end

  it 'show should update the candidate upload_baptismal_certificate info and update Candidate event.' do

    AppFactory.add_confirmation_event(I18n.t('events.upload_baptismal_certificate'))

    candidate = Candidate.find(@candidate.id)
    candidate.baptismal_certificate = BaptismalCertificate.new
    candidate_event = candidate.candidate_events.find { |ce| ce.name == I18n.t('events.upload_baptismal_certificate') }
    expect(candidate_event.completed_date).to eq(nil)

    put :baptismal_certificate_update, id: candidate.id, candidate: {baptized_at_stmm: '1'}

    candidate = Candidate.find(@candidate.id)
    candidate_event = candidate.candidate_events.find { |ce| ce.name == I18n.t('events.upload_baptismal_certificate') }
    expect(response.status).to eq(302)
    expect(@request.fullpath).to eq("/#{@dev}upload_baptismal_certificate.#{candidate.id}?candidate%5Bbaptized_at_stmm%5D=1")
    expect(candidate.baptized_at_stmm).to eq(true)
    expect(candidate.baptismal_certificate).to eq(nil)
    expect(candidate_event.completed_date).to eq(Date.today)
  end

  it 'show should illegal parameter.' do

    AppFactory.add_confirmation_event(I18n.t('events.upload_baptismal_certificate'))

    candidate = Candidate.find(@candidate.id)
    candidate.baptismal_certificate = BaptismalCertificate.new
    candidate_event = candidate.candidate_events.find { |ce| ce.name == I18n.t('events.upload_baptismal_certificate') }
    expect(candidate_event.completed_date).to eq(nil)

    put :baptismal_certificate_update, id: candidate.id

    candidate = Candidate.find(@candidate.id)
    candidate_event = candidate.candidate_events.find { |ce| ce.name == I18n.t('events.upload_baptismal_certificate') }
    # expect(response).to redirect_to(baptismal_certificate_update_path(candidate.id))
    expect(response.status).to eq(200)
    expect(@request.fullpath).to eq("/#{@dev}upload_baptismal_certificate.#{candidate.id}")
    expect(candidate.baptized_at_stmm).to eq(true)
    expect(candidate.baptismal_certificate).to eq(nil)
    expect(candidate_event.completed_date).to eq(nil)

    expect(response).to render_template('candidates/baptismal_certificate_update')
    expect(flash[:alert]).to eq('Unknown Parameter: candidate')
  end

  it 'should show illegal parameter.' do

    AppFactory.add_confirmation_event(I18n.t('events.upload_baptismal_certificate'))

    candidate = Candidate.find(@candidate.id)
    candidate.baptismal_certificate = BaptismalCertificate.new
    candidate_event = candidate.candidate_events.find { |ce| ce.name == I18n.t('events.upload_baptismal_certificate') }
    expect(candidate_event.completed_date).to eq(nil)

    put :baptismal_certificate_update,
        id: candidate.id,
        candidate: {baptized_at_stmm: '0',
                    baptismal_certificate_attributes: {},}

    candidate = Candidate.find(@candidate.id)
    candidate_event = candidate.candidate_events.find { |ce| ce.name == I18n.t('events.upload_baptismal_certificate') }
    # expect(response).to redirect_to(baptismal_certificate_update_path(candidate.id))
    expect(response.status).to eq(200)
    expect(@request.fullpath).to eq("/#{@dev}upload_baptismal_certificate.#{candidate.id}?candidate%5Bbaptized_at_stmm%5D=0")
    expect(candidate.baptized_at_stmm).to eq(false)
    expect(candidate.baptismal_certificate).not_to eq(nil)
    expect(candidate_event.completed_date.to_s).to eq('')

    expect(response).to render_template('candidates/baptismal_certificate_update')
    expect(flash[:alert]).to eq(I18n.t('messages.certificate_not_blank'))
  end

  it 'User fills in all info and updates' do

    AppFactory.add_confirmation_event(I18n.t('events.upload_baptismal_certificate'))

    candidate = Candidate.find(@candidate.id)

    valid_parameters = get_valid_parameters
    valid_parameters[:certificate_picture] = fixture_file_upload('Baptismal Certificate.png', 'image/png')
    put :baptismal_certificate_update,
        id: candidate.id,
        candidate: {baptized_at_stmm: '0',
                    baptismal_certificate_attributes: valid_parameters
        }

    expect(response).to redirect_to("/#{@dev_registration}event/#{candidate.id}")
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

shared_context 'sign_agreement' do

  it 'should show sign_agreement for the candidate.' do

    get :sign_agreement, id: @candidate.id

    expect(response).to render_template('sign_agreement')
    expect(controller.candidate).to eq(@candidate)
    expect(@request.fullpath).to eq("/#{@dev}sign_agreement.#{@candidate.id}")
  end

  it 'show should update the candidate to signing the confirmation agreement and update Candidate event.' do

    AppFactory.add_confirmation_event(I18n.t('events.sign_agreement'))

    candidate = Candidate.find(@candidate.id)
    candidate_event = candidate.candidate_events.find { |ce| ce.name == I18n.t('events.sign_agreement') }
    expect(candidate_event.completed_date).to eq(nil)

    put :sign_agreement_update, id: candidate.id, candidate: {signed_agreement: 1}

    candidate = Candidate.find(@candidate.id)
    candidate_event = candidate.candidate_events.find { |ce| ce.name == I18n.t('events.sign_agreement') }
    unless @dev.empty?
      expect(response).to redirect_to(event_candidate_registration_path(candidate.id))
    else
      expect(response).to redirect_to(event_candidate_path(candidate.id))
    end
    expect(@request.fullpath).to eq("/#{@dev}sign_agreement.#{candidate.id}?candidate%5Bsigned_agreement%5D=1")
    expect(candidate.signed_agreement).to eq(true)
    expect(candidate_event.completed_date).to eq(Date.today)
  end

end

shared_context 'fill_out_candidate_sheet' do

  it 'should show fill_out_candidate_sheet for the candidate.' do

    get :candidate_sheet, id: @candidate.id

    expect(response).to render_template('candidate_sheet')
    expect(controller.candidate).to eq(@candidate)
    expect(@request.fullpath).to eq("/#{@dev}candidate_sheet.#{@candidate.id}")
  end

  it 'show should update the candidate to fill out candidate sheet and update Candidate event.' do

    AppFactory.add_confirmation_event(I18n.t('events.fill_out_candidate_sheet'))

    candidate = Candidate.find(@candidate.id)
    candidate_event = candidate.candidate_events.find { |ce| ce.name == I18n.t('events.fill_out_candidate_sheet') }
    expect(candidate_event.completed_date).to eq(nil)

    put :candidate_sheet_update, id: candidate.id, candidate: {first_name: 'Paul'}

    candidate = Candidate.find(@candidate.id)
    candidate_event = candidate.candidate_events.find { |ce| ce.name == I18n.t('events.fill_out_candidate_sheet') }
    if @dev.empty?
      expect(response).to redirect_to(event_candidate_path(candidate.id))
    else
      expect(response).to redirect_to(event_candidate_registration_path(candidate.id))
    end
    expect(@request.fullpath).to eq("/#{@dev}candidate_sheet.#{candidate.id}?candidate%5Bfirst_name%5D=Paul")
    expect(candidate.first_name).to eq('Paul')
    expect(candidate_event.completed_date).to eq(Date.today)
  end

end