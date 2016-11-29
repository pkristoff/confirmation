

shared_context 'baptismal_certificate' do

  before(:each) do
    AppFactory.add_confirmation_event(I18n.t('events.baptismal_certificate'))
  end

  it 'should show baptismal_certificate for the candidate.' do

    expect(@candidate.baptismal_certificate).not_to eq(nil)

    put :event_with_picture, id: @candidate.id, event_name: Event::Route::BAPTISMAL_CERTIFICATE

    expect(response).to render_template('event_with_picture')
    expect(controller.candidate).to eq(@candidate)
    expect(@request.fullpath).to eq("/#{@dev}event_with_picture/#{@candidate.id}/baptismal_certificate")

    expect(controller.candidate.baptismal_certificate).not_to eq(nil)
  end

  it 'show should update the candidate baptismal_certificate info and update Candidate event.' do

    candidate = Candidate.find(@candidate.id)
    candidate.baptismal_certificate = BaptismalCertificate.new
    candidate_event = candidate.get_candidate_event(I18n.t('events.baptismal_certificate'))
    expect(candidate_event.completed_date).to eq(nil)

    put :event_with_picture_update, id: candidate.id, event_name: Event::Route::BAPTISMAL_CERTIFICATE, candidate: {baptized_at_stmm: '1'}

    candidate = Candidate.find(@candidate.id)
    candidate_event = candidate.get_candidate_event(I18n.t('events.baptismal_certificate'))
    expect(response.status).to eq(302)
    expect(@request.fullpath).to eq("/#{@dev}event_with_picture/#{candidate.id}/baptismal_certificate?candidate%5Bbaptized_at_stmm%5D=1")
    expect(candidate.baptized_at_stmm).to eq(true)
    expect(candidate_event.completed_date).to eq(Date.today)
  end

  it 'show should illegal parameter.' do

    candidate = Candidate.find(@candidate.id)
    candidate.baptismal_certificate = BaptismalCertificate.new
    candidate_event = candidate.get_candidate_event(I18n.t('events.baptismal_certificate'))
    expect(candidate_event.completed_date).to eq(nil)

    put :event_with_picture_update, id: candidate.id, event_name: Event::Route::BAPTISMAL_CERTIFICATE

    candidate = Candidate.find(@candidate.id)
    candidate_event = candidate.get_candidate_event(I18n.t('events.baptismal_certificate'))
    expect(response.status).to eq(200)
    expect(@request.fullpath).to eq("/#{@dev}event_with_picture/#{candidate.id}/baptismal_certificate")
    expect(candidate.baptized_at_stmm).to eq(true)
    expect(candidate_event.completed_date).to eq(nil)

    expect(response).to render_template('candidates/event_with_picture')
    expect(flash[:alert]).to eq('Unknown Parameter: candidate')
  end

  it 'should show illegal parameter.' do

    candidate = Candidate.find(@candidate.id)
    candidate_event = candidate.get_candidate_event(I18n.t('events.baptismal_certificate'))
    expect(candidate_event.completed_date).to eq(nil)

    put :event_with_picture_update, id: candidate.id, event_name: Event::Route::BAPTISMAL_CERTIFICATE,
        candidate: {baptized_at_stmm: '0',
                    baptismal_certificate_attributes: {},}

    candidate = Candidate.find(@candidate.id)
    candidate_event = candidate.get_candidate_event(I18n.t('events.baptismal_certificate'))
    # expect(response).to redirect_to(baptismal_certificate_update_path(candidate.id))
    expect(response.status).to eq(200)
    expect(@request.fullpath).to eq("/#{@dev}event_with_picture/#{candidate.id}/baptismal_certificate?candidate%5Bbaptized_at_stmm%5D=0")
    expect(candidate.baptized_at_stmm).to eq(false)
    expect(candidate.baptismal_certificate).not_to eq(nil)
    expect(candidate_event.completed_date.to_s).to eq('')

    expect(response).to render_template('candidates/event_with_picture')
    expect(assigns(:candidate).errors.empty?).not_to be true
  end

  it 'User fills in all info and updates' do

    candidate = Candidate.find(@candidate.id)

    valid_parameters = get_valid_parameters
    valid_parameters[:certificate_picture] = fixture_file_upload('Baptismal Certificate.png', 'image/png')
    put :event_with_picture_update, id: candidate.id, event_name: Event::Route::BAPTISMAL_CERTIFICATE,
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

    AppFactory.add_confirmation_event(I18n.t('events.candidate_covenant_agreement'))

    candidate = Candidate.find(@candidate.id)
    candidate_event = candidate.get_candidate_event(I18n.t('events.candidate_covenant_agreement'))
    expect(candidate_event.completed_date).to eq(nil)

    put :sign_agreement_update, id: candidate.id, candidate: {signed_agreement: 1}

    candidate = Candidate.find(@candidate.id)
    candidate_event = candidate.get_candidate_event(I18n.t('events.candidate_covenant_agreement'))
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

shared_context 'sponsor_agreement' do

  it 'should show sponsor_agreement for the candidate.' do

    get :sponsor_agreement, id: @candidate.id

    expect(response).to render_template('sponsor_agreement')
    expect(controller.candidate).to eq(@candidate)
    expect(@request.fullpath).to eq("/#{@dev}sponsor_agreement.#{@candidate.id}")
  end

  it 'show should update the candidate to signing the sponsor agreement and update Candidate event.' do

    AppFactory.add_confirmation_event(I18n.t('events.sponsor_agreement'))

    candidate = Candidate.find(@candidate.id)
    candidate_event = candidate.get_candidate_event(I18n.t('events.sponsor_agreement'))
    expect(candidate_event.completed_date).to eq(nil)

    put :sponsor_agreement_update, id: candidate.id, candidate: {sponsor_agreement: 1}

    candidate = Candidate.find(@candidate.id)
    candidate_event = candidate.get_candidate_event(I18n.t('events.sponsor_agreement'))
    unless @dev.empty?
      expect(response).to redirect_to(event_candidate_registration_path(candidate.id))
    else
      expect(response).to redirect_to(event_candidate_path(candidate.id))
    end
    expect(@request.fullpath).to eq("/#{@dev}sponsor_agreement.#{candidate.id}?candidate%5Bsponsor_agreement%5D=1")
    expect(candidate.sponsor_agreement).to eq(true)
    expect(candidate_event.completed_date).to eq(Date.today)
  end

end

shared_context 'candidate_information_sheet' do

  it 'should show candidate_information_sheet for the candidate.' do

    get :candidate_sheet, id: @candidate.id

    expect(response).to render_template('candidate_sheet')
    expect(controller.candidate).to eq(@candidate)
    expect(@request.fullpath).to eq("/#{@dev}candidate_sheet.#{@candidate.id}")
  end

  it 'show should update the candidate to fill out candidate sheet and update Candidate event.' do

    AppFactory.add_confirmation_event(I18n.t('events.candidate_information_sheet'))

    candidate = Candidate.find(@candidate.id)
    candidate_event = candidate.get_candidate_event(I18n.t('events.candidate_information_sheet'))
    expect(candidate_event.completed_date).to eq(nil)

    put :candidate_sheet_update, id: candidate.id,
        candidate: {
            candidate_sheet_attributes:
                {first_name: 'Paul',
                 last_name: 'Foo',
                grade: 10,
                candidate_email: 'foo@bar.com',
                parent_email_1: 'baz@bar.com',
                attending: 'The Way',
                 address_attributes:{
                     street_1: 'the way way',
                     city: 'wayville',
                     state: 'WA',
                     zip_code: '27502'
                 }
                }
        }

    candidate = Candidate.find(@candidate.id)
    candidate_event = candidate.get_candidate_event(I18n.t('events.candidate_information_sheet'))
    if @dev.empty?
      expect(response).to redirect_to(event_candidate_path(candidate.id))
    else
      expect(response).to redirect_to(event_candidate_registration_path(candidate.id))
    end
    expect(candidate.candidate_sheet.first_name).to eq('Paul')
    expect(candidate.candidate_sheet.address.city).to eq('wayville')
    expect(candidate_event.completed_date).to eq(Date.today)
  end

end