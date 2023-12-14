# frozen_string_literal: true

BIRTH_DATE = '1998-04-09'
BAPTISMAL_DATE = '1998-05-05'
CHURCH_NAME = 'St. Paul'
STREET_1 = 'St. Paul Way'
STREET_2 = 'Suite 1313'
CITY = 'Clarksville'
STATE = 'IN'
ZIP_CODE = '47129'
PROF_DATE = '1998-06-06'
PROF_CHURCH_NAME = 'St. George'
PROF_STREET_1 = 'St. George Way'
PROF_STREET_2 = 'Suite 666'
PROF_CITY = 'Atlanta'
PROF_STATE = 'GA'
PROF_ZIP_CODE = '64579'
FATHER_FIRST = 'Paul'
FATHER_MIDDLE = 'The'
LAST_NAME = 'Augusta'
MOTHER_FIRST = 'Paulette'
MOTHER_MIDDLE = 'Thette'
MOTHER_MAIDEN = 'Mary'
FIRST_NAME = 'Sophia'
MIDDLE_NAME = 'xxx'

# rubocop:disable RSpec/ContextWording
shared_context 'baptismal_certificate_html_erb' do
  # rubocop:enable RSpec/ContextWording
  include ViewsHelpers
  before do
    AppFactory.generate_default_status
    FactoryBot.create(:visitor)
    event_with_picture_setup(Event::Route::BAPTISMAL_CERTIFICATE, is_verify: @is_verify)
    AppFactory.add_confirmation_events
    @today = Time.zone.today
    page.driver.header 'Accept-Language', locale
    I18n.locale = locale

    @button_name = I18n.t('views.common.update_verify') if @is_verify
    @button_name = I18n.t('views.common.update') unless @is_verify
    cand_name = 'Sophia Augusta'
    @updated_message = I18n.t('messages.updated_verified', cand_name: cand_name) if @is_verify
    @updated_failed_verification = I18n.t('messages.updated_not_verified', cand_name: cand_name) if @is_verify
    @updated_message = I18n.t('messages.updated', cand_name: cand_name) unless @is_verify
    @updated_failed_verification = I18n.t('messages.updated', cand_name: cand_name) unless @is_verify
    @bc_form_info = ExpectBCFormInfo.new
  end

  describe 'show_empty_radio = 0' do
    before do
      @candidate.baptismal_certificate.show_empty_radio = 0
      @candidate.save!
      @bc_form_info.show_checked_baptized_at_home_parish = false
      @bc_form_info.yes_checked_baptized_at_home_parish = false
      @bc_form_info.no_checked_baptized_at_home_parish = false
      @bc_form_info.show_checked_baptized_catholic = false
    end

    describe 'initial screens' do
      it 'admin logs in and selects a candidate, nothing else showing' do
        update_baptismal_certificate

        visit @path

        expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify,
                                          @bc_form_info.show_info(false, false, false), false)
      end
    end

    describe 'error messages' do
      it 'do not fill in any fields get baptized at home parish be checked' do
        update_baptismal_certificate

        visit @path
        click_button @update_id

        # rubocop:disable Layout/LineLength
        expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify,
                                          @bc_form_info.show_info(false, false, false), false,
                                          expected_messages: [[:flash_notice, @updated_failed_verification],
                                                              [:error_explanation, [I18n.t('messages.error.missing_attribute', err_count: 1),
                                                                                    I18n.t('messages.error.baptized_should_be_checked', home_parish: Visitor.home_parish)]]])
        # rubocop:enable Layout/LineLength
        expect(Candidate.find(@candidate.id).baptismal_certificate.baptized_at_home_parish).to be(false)
        expect(Candidate.find(@candidate.id).baptismal_certificate.baptized_catholic).to be(false)
      end
    end
  end

  describe 'show_empty_radio = 1' do
    before do
      @candidate.baptismal_certificate.show_empty_radio = 1
      @candidate.save!
      @bc_form_info.show_checked_baptized_at_home_parish = true
      @bc_form_info.show_checked_baptized_catholic = false
    end

    describe 'baptized_at_home_parish = true' do
      before do
        @candidate.baptismal_certificate.baptized_at_home_parish = true
        @candidate.save!
        @bc_form_info.yes_checked_baptized_at_home_parish = true
        @bc_form_info.no_checked_baptized_at_home_parish = false
      end

      describe 'initial screens' do
        it 'admin logs in and selects a candidate, nothing else showing' do
          update_baptismal_certificate(home_parish_fields: true, baptized_catholic: true)

          visit @path

          expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify,
                                            @bc_form_info.show_info(true, true, false), false)
          expect(Candidate.find(@candidate.id).baptismal_certificate.baptized_at_home_parish).to be(true)
          expect(Candidate.find(@candidate.id).baptismal_certificate.baptized_catholic).to be(false)
        end
      end

      describe 'error messages' do
        it 'does not fill in any fields only get fields for baptized home parish' do
          update_baptismal_certificate

          visit @path
          fill_in(I18n.t('activerecord.attributes.candidate_sheet.middle_name'), with: MIDDLE_NAME)
          click_button @update_id

          # rubocop:disable Layout/LineLength
          expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify,
                                            @bc_form_info.show_info(true, true, false), false,
                                            expected_messages: [[:flash_notice, @updated_failed_verification],
                                                                [:error_explanation, [I18n.t('messages.error.missing_attributes', err_count: 14),
                                                                                      I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.birth_date')),
                                                                                      I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.baptismal_date')),
                                                                                      I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.father_first')),
                                                                                      I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.father_middle')),
                                                                                      I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.father_last')),
                                                                                      I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.mother_first')),
                                                                                      I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.mother_middle')),
                                                                                      I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.mother_maiden')),
                                                                                      I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.mother_last')),
                                                                                      I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.church_name')),
                                                                                      I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.church_address/address.street_1')),
                                                                                      I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.church_address/address.city')),
                                                                                      I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.church_address/address.state')),
                                                                                      I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.church_address/address.zip_code'))]]])
          # rubocop:enable Layout/LineLength
          expect(Candidate.find(@candidate.id).baptismal_certificate.baptized_at_home_parish).to be(true)
          expect(Candidate.find(@candidate.id).baptismal_certificate.baptized_catholic).to be(true)
        end

        it 'scanned_certificate is blank but update passes' do
          event_key = BaptismalCertificate.event_key
          update_baptismal_certificate(home_parish_fields: true, baptized_catholic: true)

          visit @path

          expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify,
                                            @bc_form_info.show_info(true, true, false), false)
          click_button @update_id
          if @is_verify
            expect_mass_edit_candidates_event(ConfirmationEvent.find_by(event_key: event_key),
                                              @candidate.id, I18n.t('messages.updated_verified',
                                                                    cand_name: @candidate.first_last_name),
                                              is_unverified: false)
          else
            expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify,
                                              @bc_form_info.show_info(true, true, false), false,
                                              expected_messages: [[:flash_notice, @updated_message]],
                                              expect_scanned_image: false)
          end
        end

        it 'admin un-verifies a verified baptized event' do
          expect(@is_verify == true || @is_verify == false).to be(true)

          event_key = BaptismalCertificate.event_key
          @candidate.get_candidate_event(event_key).completed_date = @today
          @candidate.get_candidate_event(event_key).verified = true
          @candidate.save!

          update_baptismal_certificate(home_parish_fields: true, baptized_catholic: true)

          visit @path

          expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify,
                                            @bc_form_info.show_info(true, true, false), false)

          expect(page).to have_button(I18n.t('views.common.un_verify'), count: 2) if @is_verify

          click_button('bottom-unverify') if @is_verify

          candidate = Candidate.find(@candidate.id)
          # rubocop:disable Layout/LineLength
          if @is_verify

            expect_mass_edit_candidates_event(ConfirmationEvent.find_by(event_key: event_key), candidate.id, I18n.t('messages.updated_unverified', cand_name: "#{candidate.candidate_sheet.first_name} #{candidate.candidate_sheet.last_name}"), is_unverified: true)
          else
            expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify,
                                              @bc_form_info.show_info(true, true, false), false)
          end
          # rubocop:enable Layout/LineLength

          expect(candidate.baptismal_certificate.baptized_at_home_parish).to be(true)
          expect(candidate.baptismal_certificate.baptized_catholic).to be(false)

          expect(candidate.get_candidate_event(event_key).completed_date).to eq(@today)
          expect(candidate.get_candidate_event(event_key).verified).to eq(!@is_verify)
        end

        it 'error oocurs when updating' do
          update_baptismal_certificate(home_parish_fields: true, baptized_catholic: true)
          @candidate.baptismal_certificate.scanned_certificate = create_scanned_image
          @candidate.save!

          visit @path

          choose('candidate_baptismal_certificate_attributes_baptized_at_home_parish_0')
          click_button @update_id
          @bc_form_info.yes_checked_baptized_at_home_parish = false
          @bc_form_info.no_checked_baptized_at_home_parish = true

          # rubocop:disable Layout/LineLength
          expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify,
                                            @bc_form_info.show_info(true, true, false), false,
                                            expected_messages: [[:flash_notice, @updated_failed_verification],
                                                                [:error_explanation, [I18n.t('messages.error.missing_attribute'),
                                                                                      I18n.t('messages.error.baptized_catholic_should_be_checked')]]],
                                            expect_scanned_image: true)
          # rubocop:enable Layout/LineLength
          expect(Candidate.find(@candidate.id).baptismal_certificate.baptized_at_home_parish).to be(false)
          expect(Candidate.find(@candidate.id).baptismal_certificate.baptized_catholic).to be(false)
        end
      end
    end

    describe 'baptized_at_home_parish = false' do
      before do
        @candidate.baptismal_certificate.baptized_at_home_parish = false
        @candidate.save!
        @bc_form_info.yes_checked_baptized_at_home_parish = false
        @bc_form_info.no_checked_baptized_at_home_parish = true
      end

      describe 'initial screens' do
        it 'admin logs in and selects a candidate, fc showing - no check showing 2' do
          update_baptismal_certificate(home_parish_fields: true, baptized_catholic: true)

          visit @path

          expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify,
                                            @bc_form_info.show_info(true, true, false), false)

          expect(Candidate.find(@candidate.id).baptismal_certificate.baptized_at_home_parish).to be(false)
          expect(Candidate.find(@candidate.id).baptismal_certificate.baptized_catholic).to be(false)
        end
      end

      describe 'error messages' do
        it 'does not fill in any fields only get fields for baptized home parish plus baptized catholic' do
          update_baptismal_certificate

          visit @path
          fill_in(I18n.t('activerecord.attributes.candidate_sheet.middle_name'), with: MIDDLE_NAME)
          click_button @update_id

          # rubocop:disable Layout/LineLength
          expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify,
                                            @bc_form_info.show_info(true, true, false), false,
                                            expected_messages: [[:flash_notice, @updated_failed_verification],
                                                                [:error_explanation, [I18n.t('messages.error.missing_attributes', err_count: 16),
                                                                                      I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.birth_date')),
                                                                                      I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.baptismal_date')),
                                                                                      I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.father_first')),
                                                                                      I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.father_middle')),
                                                                                      I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.father_last')),
                                                                                      I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.mother_first')),
                                                                                      I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.mother_middle')),
                                                                                      I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.mother_maiden')),
                                                                                      I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.mother_last')),
                                                                                      I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.church_name')),
                                                                                      I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.church_address/address.street_1')),
                                                                                      I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.church_address/address.city')),
                                                                                      I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.church_address/address.state')),
                                                                                      I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.church_address/address.zip_code')),
                                                                                      I18n.t('messages.error.baptized_catholic_should_be_checked')]]])
          # rubocop:enable Layout/LineLength
          expect(Candidate.find(@candidate.id).baptismal_certificate.baptized_at_home_parish).to be(false)
          expect(Candidate.find(@candidate.id).baptismal_certificate.baptized_catholic).to be(false)
        end
      end
    end
  end

  describe 'show_empty_radio = 2' do
    before do
      @candidate.baptismal_certificate.show_empty_radio = 2
      @candidate.save!
      @bc_form_info.show_checked_baptized_at_home_parish = true
      @bc_form_info.show_checked_baptized_catholic = true
    end

    describe 'baptized_at_home_parish = false' do
      before do
        @candidate.baptismal_certificate.baptized_at_home_parish = false
        @candidate.save!
        @bc_form_info.yes_checked_baptized_at_home_parish = false
        @bc_form_info.no_checked_baptized_at_home_parish = true
      end

      describe 'initial screens' do
        it 'admin logs in and selects a candidate, unchecks baptized_at_home_parish, first communion showing' do
          update_baptismal_certificate(home_parish_fields: true, baptized_catholic: true, prof_of_faith: true)

          visit @path

          expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verif,
                                            @bc_form_info.show_info(true, true, true), false)
        end
      end

      describe 'baptized_catholic = true' do
        before do
          @candidate.baptismal_certificate.baptized_catholic = true
          @bc_form_info.yes_checked_baptized_catholic = true
          @bc_form_info.no_checked_baptized_catholic = false
          @candidate.save!
        end

        describe 'error messages' do
          it 'not show a validation error for city and zip code' do
            @candidate.save!
            update_baptismal_certificate(home_parish_fields: true, baptized_catholic: true)

            visit @path
            expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify,
                                              @bc_form_info.show_info(true, true, false), false)
            fill_in_form

            click_button @update_id

            if @is_verify
              expect_mass_edit_candidates_event(ConfirmationEvent.find_by(event_key: BaptismalCertificate.event_key),
                                                @candidate.id, @updated_message)
            else
              expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify,
                                                @bc_form_info.show_info(true, true, false), false,
                                                expected_messages: [[:flash_notice, @updated_message]],
                                                expect_scanned_image: true)
            end
            expect(Candidate.find(@candidate.id).baptismal_certificate.baptized_at_home_parish).to be(false)
            expect(Candidate.find(@candidate.id).baptismal_certificate.baptized_catholic).to be(true)
          end

          it 'admin logs in and selects a candidate, unchecks baptized_at_home_parish, fills in template' do
            update_baptismal_certificate(home_parish_fields: true, baptized_catholic: true)

            expect_db(1, 0)

            visit @path

            expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify,
                                              @bc_form_info.show_info(true, true, false), false)
            fill_in_form

            click_button @update_id

            candidate = Candidate.find(@candidate.id)

            if @is_verify

              expect_mass_edit_candidates_event(ConfirmationEvent.find_by(event_key: BaptismalCertificate.event_key),
                                                candidate.id, @updated_message)

            else

              expect_baptismal_certificate_form(candidate.id, @dev, @path_str, @button_name, @is_verify,
                                                @bc_form_info.show_info(true, true, false), false,
                                                expected_messages: [[:flash_notice, @updated_message]],
                                                expect_scanned_image: true)

            end
            # make sure all basic info values are filled in
            expect(candidate.baptismal_certificate.birth_date.to_s).to eq(BIRTH_DATE)
            expect(candidate.baptismal_certificate.baptismal_date.to_s).to eq(BAPTISMAL_DATE)
            expect(candidate.baptismal_certificate.father_first).to eq(FATHER_FIRST)
            expect(candidate.baptismal_certificate.father_middle).to eq(FATHER_MIDDLE)
            expect(candidate.baptismal_certificate.father_last).to eq(LAST_NAME)
            expect(candidate.baptismal_certificate.mother_first).to eq(MOTHER_FIRST)
            expect(candidate.baptismal_certificate.mother_middle).to eq(MOTHER_MIDDLE)
            expect(candidate.baptismal_certificate.mother_maiden).to eq(MOTHER_MAIDEN)
            expect(candidate.baptismal_certificate.mother_last).to eq(LAST_NAME)

            expect(candidate.candidate_sheet.first_name).to eq(FIRST_NAME)
            expect(candidate.candidate_sheet.middle_name).to eq(MIDDLE_NAME)
            expect(candidate.candidate_sheet.last_name).to eq(LAST_NAME)

            # check baptized catholic info values are set.
            expect(candidate.baptismal_certificate.church_name).to eq(CHURCH_NAME)
            expect(candidate.baptismal_certificate.church_address.street_1).to eq(STREET_1)
            expect(candidate.baptismal_certificate.church_address.street_2).to eq(STREET_2)
            expect(candidate.baptismal_certificate.church_address.city).to eq(CITY)
            expect(candidate.baptismal_certificate.church_address.state).to eq(STATE)
            expect(candidate.baptismal_certificate.church_address.zip_code).to eq(ZIP_CODE)

            expect_db(1, 1) # make sure DB does not increase in size.
          end

          it 'create empty form,fill it in passes' do
            update_baptismal_certificate
            visit @path
            fill_in_form
            click_button @update_id

            candidate = Candidate.find(@candidate.id)
            if @is_verify

              expect_mass_edit_candidates_event(ConfirmationEvent.find_by(event_key: BaptismalCertificate.event_key),
                                                candidate.id, @updated_message)

            else

              expect_baptismal_certificate_form(candidate.id, @dev, @path_str, @button_name, @is_verify,
                                                @bc_form_info.show_info(true, true, false), false,
                                                expected_messages: [[:flash_notice, @updated_message]],
                                                expect_scanned_image: true)

            end

            visit @path

            choose('candidate_baptismal_certificate_attributes_baptized_at_home_parish_1')

            click_button @update_id

            @bc_form_info.show_checked_baptized_catholic = true
            @bc_form_info.yes_checked_baptized_at_home_parish = true
            @bc_form_info.no_checked_baptized_at_home_parish = false

            candidate = Candidate.find(@candidate.id)
            if @is_verify

              expect_mass_edit_candidates_event(ConfirmationEvent.find_by(event_key: BaptismalCertificate.event_key),
                                                candidate.id, @updated_message)

            else

              expect_baptismal_certificate_form(candidate.id, @dev, @path_str, @button_name, @is_verify,
                                                @bc_form_info.show_info(true, true, false), false,
                                                expected_messages: [[:flash_notice, @updated_message]],
                                                expect_scanned_image: true)

            end

            expect(candidate.baptismal_certificate).not_to be_nil # always created now
            expect(candidate.baptismal_certificate.baptized_at_home_parish).to be(true)
            expect(candidate.get_candidate_event(BaptismalCertificate.event_key).completed_date).to eq(@today)
            expect(candidate.get_candidate_event(BaptismalCertificate.event_key).verified).to eq(@is_verify)
          end

          # rubocop:disable Layout/LineLength
          it 'admin logs in and selects a candidate, adds picture, updates, adds rest of valid data, updates - everything is saved' do
            # rubocop:enable Layout/LineLength
            update_baptismal_certificate(home_parish_fields: true, baptized_catholic: true)
            @candidate.candidate_sheet.middle_name = ''
            @candidate.candidate_sheet.while_not_validating_middle_name do
              @candidate.save!
            end

            visit @path
            # rubocop:disable Layout/LineLength
            attach_file(I18n.t('activerecord.attributes.baptismal_certificate.certificate_picture'), 'spec/fixtures/files/actions.png')
            # rubocop:enable Layout/LineLength
            click_button @update_id

            candidate = Candidate.find(@candidate.id)

            # rubocop:disable Layout/LineLength
            expect_baptismal_certificate_form(candidate.id, @dev, @path_str, @button_name, @is_verify,
                                              @bc_form_info.show_info(true, true, false), false,
                                              expected_messages: [[:flash_notice, @updated_failed_verification],
                                                                  [:error_explanation,
                                                                   [I18n.t('messages.error.missing_attribute', err_count: 1),
                                                                    I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.candidate_sheet.middle_name'))]]],
                                              expect_scanned_image: true)
            # rubocop:enable Layout/LineLength
            candidate = Candidate.find(@candidate.id)

            # rubocop:disable Layout/LineLength
            expect(candidate.get_candidate_event(BaptismalCertificate.event_key).verified).to be(false), 'Baptismal certificate not verified.'
            # rubocop:enable Layout/LineLength
            expect(candidate.get_candidate_event(BaptismalCertificate.event_key).completed_date).to eq(Time.zone.today)

            expect(candidate.get_candidate_event(CandidateSheet.event_key).verified).to be(false)
            expect(candidate.get_candidate_event(CandidateSheet.event_key).completed_date).to be_nil

            fill_in(I18n.t('activerecord.attributes.candidate_sheet.middle_name'), with: MIDDLE_NAME)

            click_button @update_id

            if @is_verify

              # rubocop:disable Layout/LineLength
              expect_mass_edit_candidates_event(ConfirmationEvent.find_by(event_key: BaptismalCertificate.event_key), candidate.id, @updated_message)
              # rubocop:enable Layout/LineLength

            else
              expect_baptismal_certificate_form(candidate.id, @dev, @path_str, @button_name, @is_verify,
                                                @bc_form_info.show_info(true, true, false), false,
                                                expected_messages: [[:flash_notice, @updated_message]],
                                                expect_scanned_image: true)
            end

            candidate = Candidate.find_by(id: candidate.id)
            # rubocop:disable Layout/LineLength
            expect(candidate.get_candidate_event(BaptismalCertificate.event_key).verified).to eq(@is_verify), 'Baptismal certificate not verified.'
            # rubocop:enable Layout/LineLength
            expect(candidate.get_candidate_event(BaptismalCertificate.event_key).completed_date).to eq(Time.zone.today)

            # candidate_information_sheet if completed is automatically verified
            expect(candidate.get_candidate_event(CandidateSheet.event_key).verified?).to be(true)
            expect(candidate.get_candidate_event(CandidateSheet.event_key).completed_date).to eq(Time.zone.today)
          end

          it 'admin logs in and selects a candidate, checks no for baptized_at_home_parish and updates' do
            # This test was sometimes had middle_name == '' and sometimes not.  So
            # now it is always ''.
            @candidate.candidate_sheet.middle_name = ''
            @candidate.save!(validate: false)
            update_baptismal_certificate

            visit @path

            click_button @update_id

            candidate = Candidate.find(@candidate.id)

            # rubocop:disable Layout/LineLength
            expect_baptismal_certificate_form(candidate.id, @dev, @path_str, @button_name, @is_verify,
                                              @bc_form_info.show_info(true, true, false), false,
                                              expected_messages: [[:flash_notice, @updated_failed_verification],
                                                                  [:error_explanation, [I18n.t('messages.error.missing_attributes', err_count: 16),

                                                                                        I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.candidate_sheet.middle_name')),

                                                                                        I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.birth_date')),
                                                                                        I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.baptismal_date')),
                                                                                        I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.father_first')),
                                                                                        I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.father_middle')),
                                                                                        I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.father_last')),
                                                                                        I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.mother_first')),
                                                                                        I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.mother_middle')),
                                                                                        I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.mother_maiden')),
                                                                                        I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.mother_last')),
                                                                                        I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.church_name')),

                                                                                        I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.church_address/address.street_1')),
                                                                                        I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.church_address/address.city')),
                                                                                        I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.church_address/address.state')),
                                                                                        I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.church_address/address.zip_code')),
                                                                                        I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.certificate_picture'))],
                                                                   16]])
            # rubocop:enable Layout/LineLength
          end

          # rubocop:disable Layout/LineLength
          it 'admin logs in and selects a candidate, adds non-picture data, updates, adds picture, updates - everything is saved' do
            update_baptismal_certificate
            visit @path

            fill_in_form(attach_file: false) # no picture
            click_button @update_id

            expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify,
                                              @bc_form_info.show_info(true, true, false), false,
                                              expected_messages: [[:flash_notice, @updated_failed_verification],
                                                                  [:error_explanation, [I18n.t('messages.error.missing_attribute', err_count: 1),
                                                                                        I18n.t('errors.format_blank',
                                                                                               attribute: I18n.t('activerecord.attributes.baptismal_certificate.certificate_picture'))]]])

            attach_file(I18n.t('activerecord.attributes.baptismal_certificate.certificate_picture'), 'spec/fixtures/files/actions.png')
            click_button @update_id

            candidate = Candidate.find(@candidate.id)
            if @is_verify

              expect_mass_edit_candidates_event(ConfirmationEvent.find_by(event_key: BaptismalCertificate.event_key), candidate.id, @updated_message)

            else

              expect_baptismal_certificate_form(candidate.id, @dev, @path_str, @button_name, @is_verify,
                                                @bc_form_info.show_info(true, true, false), false,
                                                expected_messages: [[:flash_notice, @updated_message]],
                                                expect_scanned_image: true)

              expect(candidate.baptismal_certificate.baptized_at_home_parish).to be(false)
              expect(candidate.baptismal_certificate).not_to be_nil
              expect(candidate.baptismal_certificate.scanned_certificate).not_to be_nil

            end

            visit @path

            candidate = Candidate.find(@candidate.id)
            expect_baptismal_certificate_form(candidate.id, @dev, @path_str, @button_name, @is_verify,
                                              @bc_form_info.show_info(true, true, false), false,
                                              expected_messages: [[:flash_notice, @updated_message]],
                                              expect_scanned_image: true)
          end
          # rubocop:enable Layout/LineLength
        end
      end

      describe 'baptized_catholic = false' do
        before do
          @candidate.baptismal_certificate.baptized_catholic = false
          @candidate.save!
          @bc_form_info.yes_checked_baptized_catholic = false
          @bc_form_info.no_checked_baptized_catholic = true
        end

        describe 'error messages' do
          it 'only show a validation error scanned baptismal certificate & profession of faith' do
            update_baptismal_certificate(home_parish_fields: true, baptized_catholic: true, prof_of_faith: true)

            visit @path

            expect_field(I18n.t('activerecord.attributes.baptismal_certificate.prof_picture'), nil)

            expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify,
                                              @bc_form_info.show_info(true, true, true), false)
            click_button @update_id

            # rubocop:disable Layout/LineLength
            expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify,
                                              @bc_form_info.show_info(true, true, true), false,
                                              expected_messages: [[:flash_notice, @updated_failed_verification],
                                                                  [:error_explanation, [I18n.t('messages.error.missing_attributes', err_count: 2),
                                                                                        I18n.t('errors.format_blank',
                                                                                               attribute: I18n.t('activerecord.attributes.baptismal_certificate.certificate_picture')),
                                                                                        I18n.t('errors.format_blank',
                                                                                               attribute: I18n.t('activerecord.attributes.baptismal_certificate.prof_picture'))]]])
            # rubocop:enable Layout/LineLength

            attach_file(I18n.t('activerecord.attributes.baptismal_certificate.certificate_picture'),
                        'spec/fixtures/files/actions.png')
            attach_file(I18n.t('activerecord.attributes.baptismal_certificate.prof_picture'),
                        'spec/fixtures/files/actions.png')
            click_button @update_id

            if @is_verify

              expect_mass_edit_candidates_event(ConfirmationEvent.find_by(event_key: BaptismalCertificate.event_key),
                                                @candidate.id, @updated_message)

            else
              expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify,
                                                @bc_form_info.show_info(true, true, true), false,
                                                expected_messages: [[:flash_notice, @updated_message]],
                                                expect_scanned_image: true,
                                                expect_prof_scanned_image: true)
            end
          end

          it 'not error for baptized church_name and address' do
            update_baptismal_certificate(home_parish_fields: true, baptized_catholic: true, prof_of_faith: true)

            visit @path
            attach_file(I18n.t('activerecord.attributes.baptismal_certificate.certificate_picture'),
                        'spec/fixtures/files/actions.png')
            attach_file(I18n.t('activerecord.attributes.baptismal_certificate.prof_picture'),
                        'spec/fixtures/files/actions.png')
            click_button @update_id

            if @is_verify

              expect_mass_edit_candidates_event(ConfirmationEvent.find_by(event_key: BaptismalCertificate.event_key),
                                                @candidate.id, @updated_message)

            else
              expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify,
                                                @bc_form_info.show_info(true, true, true), false,
                                                expected_messages: [[:flash_notice, @updated_message]],
                                                expect_scanned_image: true,
                                                expect_prof_scanned_image: true)
            end
          end
        end

        describe 'reproduce runtime errors' do
          it 'User scans in profession of faith image, but when it is updated it disappears' do
            update_baptismal_certificate(home_parish_fields: true, baptized_catholic: true, prof_of_faith: true)

            visit @path
            attach_file(I18n.t('activerecord.attributes.baptismal_certificate.certificate_picture'),
                        'spec/fixtures/files/actions.png')
            click_button @update_id
            i18n_prof_picture = I18n.t('activerecord.attributes.baptismal_certificate.prof_picture')
            i18n_missing_attribute = I18n.t('messages.error.missing_attribute', err_count: 1)
            expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify,
                                              @bc_form_info.show_info(true, true, true), false,
                                              expected_messages: [[:flash_notice, @updated_failed_verification],
                                                                  [:error_explanation, [i18n_missing_attribute,
                                                                                        I18n.t('errors.format_blank',
                                                                                               attribute: i18n_prof_picture)]]],
                                              expect_scanned_image: true,
                                              expect_prof_scanned_image: false)
            attach_file(I18n.t('activerecord.attributes.baptismal_certificate.prof_picture'),
                        'spec/fixtures/files/actions.png')
            click_button @update_id

            if @is_verify
              expect_mass_edit_candidates_event(ConfirmationEvent.find_by(event_key: BaptismalCertificate.event_key),
                                                @candidate.id, I18n.t('messages.updated_verified',
                                                                      cand_name: @candidate.first_last_name),
                                                is_unverified: false)
            else
              expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify,
                                                @bc_form_info.show_info(true, true, true), false,
                                                expected_messages: [[:flash_notice, @updated_message]],
                                                expect_scanned_image: true,
                                                expect_prof_scanned_image: true)
            end
          end
        end
      end
    end
  end

  private

  include ExpectAddress

  def img_src_selector(is_other: nil)
    return "img[src=\"/#{@dev}event_with_picture_image/#{@candidate.id}/baptismal_certificate\"]" if is_other.nil?

    # rubocop:disable Layout/LineLength
    "img[src=\"/#{@dev}event_with_picture_image/#{@candidate.id}/baptismal_certificate/is_other/#{is_other}\"]" unless is_other.nil?
    # rubocop:enable Layout/LineLength
  end

  def expect_no_scanned_image
    expect(page).to have_selector('div[id=file-type-message_certificate_picture]',
                                  text: I18n.t('views.common.image_upload_file_types'))
    expect_field(I18n.t('activerecord.attributes.baptismal_certificate.certificate_picture'), nil)
    begin
      div = page.find_by_id('div-scanned-image-certificate_picture')
    rescue Capybara::ElementNotFound
      div = nil
    end
    expect(page).not_to have_selector('div[id=div-scanned-image-certificate_picture]') if div.nil?
    expect(div[:class]).to have_content('hide-div') unless div.nil?
  end

  def expect_no_prof_scanned_image
    expect(page).to have_selector('div[id=file-type-message_prof_picture]',
                                  text: I18n.t('views.common.image_upload_file_types'))
    expect_field(I18n.t('activerecord.attributes.baptismal_certificate.prof_picture'), nil)
    begin
      div = page.find_by_id('div-scanned-image-prof_picture')
    rescue Capybara::ElementNotFound
      div = nil
    end
    expect(page).not_to have_selector('div[id=div-scanned-image-prof_picture]') if div.nil?
    expect(div[:class]).to have_content('hide-div') unless div.nil?
  end

  def expect_scanned_image(candidate_id, dev, filename, file_type)
    expect(page).to have_selector('div[id=div-scanned-image-certificate_picture][class=show-div]')
    expect(page).to have_selector('div[id=file-type-message_certificate_picture]',
                                  text: I18n.t('views.common.image_upload_file_types'))
    si = page.find_by_id('img-scanned-image-certificate_picture')
    expect(si[:src]).to eq("/#{dev}event_with_picture_image/#{candidate_id}/baptismal_certificate/is_other/false")
    expect(si[:alt]).to eq("Did not receive the file: #{filename} of type #{file_type}")
  end

  def expect_prof_scanned_image(candidate_id, dev, filename, file_type)
    expect(page).to have_selector('div[id=div-scanned-image-prof_picture][class=show-div]')
    expect(page).to have_selector('div[id=file-type-message_prof_picture]',
                                  text: I18n.t('views.common.image_upload_file_types'))
    si = page.find_by_id('img-scanned-image-prof_picture')
    expect(si[:src]).to eq("/#{dev}event_with_picture_image/#{candidate_id}/baptismal_certificate/is_other/true")
    expect(si[:alt]).to eq("Did not receive the file: #{filename} of type #{file_type}")
  end

  # rubocop:disable Layout/LineLength
  def expect_baptismal_certificate_form(cand_id,
                                        dev_path,
                                        path_str,
                                        button_name,
                                        is_verify,
                                        bc_form_info,
                                        disabled,
                                        values = {})

    values = bc_form_info.values.merge(values)

    bc_form_info.add_blank_fields(values[:expected_messages])

    expect_messages(values[:expected_messages]) unless values[:expected_messages].nil?

    candidate = Candidate.find(cand_id)

    expect_heading(candidate, dev_path.empty?, BaptismalCertificate.event_key)

    expect(page).to have_selector("form[id=edit_candidate][action=\"/#{dev_path}#{path_str}/#{cand_id}/baptismal_certificate\"]")
    expect(page).to have_selector('div', text: I18n.t('activerecord.attributes.baptismal_certificate.baptized_at_home_parish', home_parish: Visitor.home_parish))

    expect_no_scanned_image unless values[:expect_scanned_image]
    expect_no_prof_scanned_image unless values[:expect_prof_scanned_image]
    expect_scanned_image(@candidate.id, @dev, 'actions.png', 'png') if values[:expect_scanned_image]
    expect_prof_scanned_image(@candidate.id, @dev, 'actions.png', 'png') if values[:expect_prof_scanned_image]

    expect_home_parish(page, bc_form_info, disabled)

    expect_baptized_catholic(page, bc_form_info, disabled)

    expect_profession_of_faith(page, bc_form_info, disabled)

    expect_image_upload('baptismal_certificate', 'certificate_picture', I18n.t('activerecord.attributes.baptismal_certificate.certificate_picture'))

    expect(page).to have_button(button_name, count: 2)
    expect_remove_button('candidate_baptismal_certificate_attributes_remove_certificate_picture', 'certificate_picture')
    expect(page).to have_button(I18n.t('views.common.remove_image'), count: 1)
    expect(page).to have_button(I18n.t('views.common.replace_image'), count: 1)
    expect(page).to have_button(I18n.t('views.common.un_verify'), count: 2) if is_verify
    expect_download_button(Event::Document::BAPTISMAL_CERTIFICATE, cand_id, dev_path)
    # rubocop:enable Layout/LineLength
  end

  def update_baptismal_certificate(home_parish_fields: false, baptized_catholic: false, prof_of_faith: false)
    if home_parish_fields
      baptismal_certificate = @candidate.baptismal_certificate

      candidate_sheet = @candidate.candidate_sheet

      baptismal_certificate.birth_date = Date.parse(BIRTH_DATE)
      baptismal_certificate.baptismal_date = Date.parse(BAPTISMAL_DATE)

      baptismal_certificate.father_first = FATHER_FIRST
      baptismal_certificate.father_middle = FATHER_MIDDLE
      baptismal_certificate.father_last = LAST_NAME

      baptismal_certificate.mother_first = MOTHER_FIRST
      baptismal_certificate.mother_middle = MOTHER_MIDDLE
      baptismal_certificate.mother_maiden = MOTHER_MAIDEN
      baptismal_certificate.mother_last = LAST_NAME

      candidate_sheet.first_name = FIRST_NAME
      candidate_sheet.middle_name = MIDDLE_NAME
      candidate_sheet.last_name = LAST_NAME

      @candidate.save!
    end

    if baptized_catholic
      baptismal_certificate.church_name = CHURCH_NAME
      baptismal_certificate.church_address.street_1 = STREET_1
      baptismal_certificate.church_address.street_2 = STREET_2
      baptismal_certificate.church_address.city = CITY
      baptismal_certificate.church_address.state = STATE
      baptismal_certificate.church_address.zip_code = ZIP_CODE
      @candidate.save!
    end

    return unless prof_of_faith

    baptismal_certificate.prof_date = PROF_DATE

    baptismal_certificate.prof_church_name = PROF_CHURCH_NAME
    baptismal_certificate.prof_church_address.street_1 = PROF_STREET_1
    baptismal_certificate.prof_church_address.street_2 = PROF_STREET_2
    baptismal_certificate.prof_church_address.city = PROF_CITY
    baptismal_certificate.prof_church_address.state = PROF_STATE
    baptismal_certificate.prof_church_address.zip_code = PROF_ZIP_CODE
    @candidate.save!
  end

  def baptized_home_parish_radios(bc_form_info)
    outter_fieldset_div = 'div[id=baptized-at-home-parish-radios-fieldset]'
    expect(page).to have_selector(outter_fieldset_div)
    fieldset_path = "#{outter_fieldset_div} fieldset"
    expect(page).to have_selector(fieldset_path, text: I18n.t('field_set.baptismal_certificate.question'))
    yes_id = 'candidate_baptismal_certificate_attributes_baptized_at_home_parish_1'
    no_id = 'candidate_baptismal_certificate_attributes_baptized_at_home_parish_0'
    expect(page).to have_selector("#{fieldset_path} input[type=radio][id=#{yes_id}][value='1']", count: 1)
    expect(page).to have_selector("#{fieldset_path} input[type=radio][id=#{no_id}][value='0']", count: 1)

    should_show_checked = bc_form_info.show_checked_baptized_at_home_parish
    yes_checked = should_show_checked && bc_form_info.yes_checked_baptized_at_home_parish
    no_checked = should_show_checked && bc_form_info.no_checked_baptized_at_home_parish

    expect(find_field(yes_id)).not_to be_checked unless should_show_checked
    expect(find_field(no_id)).not_to be_checked unless should_show_checked

    return unless should_show_checked

    expect(find_field(yes_id)).to be_checked if yes_checked
    expect(find_field(no_id)).not_to be_checked if yes_checked

    expect(find_field(yes_id)).not_to be_checked if no_checked
    expect(find_field(no_id)).to be_checked if no_checked
    true
  end

  def baptized_catholic_radios(bc_form_info)
    outter_fieldset_div = 'div[id=baptized-catholic-radios-fieldset]'
    expect(page).to have_selector(outter_fieldset_div)
    fieldset_path = "#{outter_fieldset_div} fieldset"
    expect(page).to have_selector(fieldset_path, text: I18n.t('field_set.baptismal_certificate.question'))
    yes_id = 'candidate_baptismal_certificate_attributes_baptized_catholic_1'
    no_id = 'candidate_baptismal_certificate_attributes_baptized_catholic_0'
    expect(page).to have_selector("#{fieldset_path} input[type=radio][id=#{yes_id}][value='1']", count: 1)
    expect(page).to have_selector("#{fieldset_path} input[type=radio][id=#{no_id}][value='0']", count: 1)

    should_show_checked = bc_form_info.show_checked_baptized_catholic
    yes_checked = should_show_checked && bc_form_info.yes_checked_baptized_catholic
    no_checked = should_show_checked && bc_form_info.no_checked_baptized_catholic

    expect(find_field(yes_id)).to be_checked if should_show_checked && yes_checked
    expect(find_field(no_id)).not_to be_checked if should_show_checked && yes_checked

    expect(find_field(yes_id)).not_to be_checked if should_show_checked && no_checked
    expect(find_field(no_id)).to be_checked if should_show_checked && no_checked
    should_show_checked
  end

  def expect_baptized_catholic_fields(rendered_or_page, disabled, visible, bc_form_info)
    ExpectAddress.expect_address_fields(rendered_or_page, bc_form_info, disabled, visible)

    text_fields = %i[church_name]
    text_fields.each do |sym|
      val = bc_form_info.field_value(sym, 'activerecord.attributes.baptismal_certificate')
      ExpectFields.expect_have_field_text(
        rendered_or_page,
        I18n.t("activerecord.attributes.baptismal_certificate.#{sym}"),
        "candidate_baptismal_certificate_attributes_#{sym}",
        val,
        disabled,
        visible
      )
    end
    val = bc_form_info.field_value(:dv_church_name, '')
    ExpectFields.expect_have_field_hidden(
      rendered_or_page,
      'dv-home-parish',
      val
    )

    ExpectAddress.address_fields.each do |address_field|
      field_id = "dv-#{address_field}".to_sym
      val = bc_form_info.field_value(field_id, '')
      ExpectFields.expect_have_field_hidden(
        rendered_or_page,
        field_id,
        val
      )
    end

    text_fields.each do |sym|
      val = bc_form_info.field_value(sym, 'activerecord.attributes.baptismal_certificate')
      ExpectFields.expect_have_field_text(
        rendered_or_page,
        I18n.t("activerecord.attributes.baptismal_certificate.#{sym}"),
        "candidate_baptismal_certificate_attributes_#{sym}",
        val,
        disabled,
        visible
      )
    end
  end

  def expect_baptized_catholic(rendered_or_page, bc_form_info, disabled)
    baptized_catholic_radios(bc_form_info)
    # rubocop:disable Layout/LineLength
    expect(rendered_or_page).to have_selector("div[id=baptized-catholic-info][class='#{!bc_form_info.show_baptized_catholic_info ? 'hide-div' : 'show-div'}']")
    # rubocop:enable Layout/LineLength
    expect_baptized_catholic_fields(rendered_or_page, disabled, bc_form_info.show_baptized_catholic_info, bc_form_info)
  end

  def expect_profession_of_faith_fields(rendered_or_page, disabled, visible, bc_form_info)
    text_fields = %i[prof_church_name]

    val = bc_form_info.field_value(:prof_date, 'activerecord.attributes.baptismal_certificate')
    vis = visible && !val.empty?
    ExpectFields.expect_have_field_date(
      rendered_or_page,
      I18n.t('activerecord.attributes.baptismal_certificate.prof_date'),
      'candidate_baptismal_certificate_attributes_prof_date',
      val,
      disabled,
      vis
    )

    ExpectAddress.expect_prof_address_fields(rendered_or_page, bc_form_info, disabled, visible)

    text_fields.each do |sym|
      val = bc_form_info.field_value(sym, 'activerecord.attributes.baptismal_certificate')
      ExpectFields.expect_have_field_text(
        rendered_or_page,
        I18n.t("activerecord.attributes.baptismal_certificate.#{sym}"),
        "candidate_baptismal_certificate_attributes_#{sym}",
        val,
        disabled,
        visible
      )
    end
  end

  def expect_profession_of_faith(rendered_or_page, bc_form_info, disabled)
    # rubocop:disable Layout/LineLength
    expect(rendered_or_page).to have_selector("div[id=profession-of-faith-info][class='#{!bc_form_info.show_profession_of_faith_info ? 'hide-div' : 'show-div'}']")
    expect_profession_of_faith_fields(rendered_or_page, disabled, bc_form_info.show_profession_of_faith_info, bc_form_info)
    # rubocop:enable Layout/LineLength
  end

  def expect_home_parish(rendered_or_page, bc_form_info, disabled)
    baptized_home_parish_radios(bc_form_info)
    # rubocop:disable Layout/LineLength
    expect(rendered_or_page).to have_selector("div[id=baptized-at-home-parish-info][class='#{!bc_form_info.show_baptized_at_home_parish_info ? 'hide-div' : 'show-div'}']")
    # rubocop:enable Layout/LineLength
    expect_home_parish_fields(rendered_or_page, disabled, bc_form_info, bc_form_info.show_baptized_at_home_parish_info)
  end

  def expect_home_parish_fields(rendered_or_page, disabled, bc_form_info, visible)
    cs_text_fields = %i[first_name middle_name last_name]
    cs_text_fields.each do |sym|
      val = bc_form_info.field_value(sym, 'activerecord.attributes.candidate_sheet')
      ExpectFields.expect_have_field_text(
        rendered_or_page,
        I18n.t("activerecord.attributes.candidate_sheet.#{sym}"),
        "candidate_candidate_sheet_attributes_#{sym}",
        val,
        disabled,
        visible
      )
    end

    text_fields = %i[father_first father_middle father_last
                     mother_first mother_middle mother_maiden mother_last]
    text_fields.each do |sym|
      val = bc_form_info.field_value(sym, 'activerecord.attributes.baptismal_certificate')
      ExpectFields.expect_have_field_text(
        rendered_or_page,
        I18n.t("activerecord.attributes.baptismal_certificate.#{sym}"),
        "candidate_baptismal_certificate_attributes_#{sym}",
        val,
        disabled,
        visible
      )
    end

    date_fields = %i[birth_date baptismal_date]
    date_fields.each do |sym|
      val = bc_form_info.field_value(sym, 'activerecord.attributes.baptismal_certificate')
      vis = visible && !val.empty?
      ExpectFields.expect_have_field_date(
        rendered_or_page,
        I18n.t("activerecord.attributes.baptismal_certificate.#{sym}"),
        "candidate_baptismal_certificate_attributes_#{sym}",
        val,
        disabled,
        vis
      )
    end
  end

  def fill_in_form(attach_file: true)
    # basic_info
    fill_in(I18n.t('activerecord.attributes.baptismal_certificate.birth_date'), with: BIRTH_DATE)
    fill_in(I18n.t('activerecord.attributes.baptismal_certificate.baptismal_date'), with: BAPTISMAL_DATE)
    fill_in(I18n.t('activerecord.attributes.baptismal_certificate.father_first'), with: FATHER_FIRST)
    fill_in(I18n.t('activerecord.attributes.baptismal_certificate.father_middle'), with: FATHER_MIDDLE)
    fill_in(I18n.t('activerecord.attributes.baptismal_certificate.father_last'), with: LAST_NAME)
    fill_in(I18n.t('activerecord.attributes.baptismal_certificate.mother_first'), with: MOTHER_FIRST)
    fill_in(I18n.t('activerecord.attributes.baptismal_certificate.mother_middle'), with: MOTHER_MIDDLE)
    fill_in(I18n.t('activerecord.attributes.baptismal_certificate.mother_maiden'), with: MOTHER_MAIDEN)
    fill_in(I18n.t('activerecord.attributes.baptismal_certificate.mother_last'), with: LAST_NAME)

    fill_in(I18n.t('activerecord.attributes.candidate_sheet.first_name'), with: FIRST_NAME)
    fill_in(I18n.t('activerecord.attributes.candidate_sheet.middle_name'), with: MIDDLE_NAME)
    fill_in(I18n.t('activerecord.attributes.candidate_sheet.last_name'), with: LAST_NAME)

    # baptized catholic info
    fill_in(I18n.t('activerecord.attributes.baptismal_certificate.church_name'), with: CHURCH_NAME)
    fill_in(I18n.t('activerecord.attributes.baptismal_certificate.church_address/address.street_1'), with: STREET_1)
    fill_in(I18n.t('activerecord.attributes.baptismal_certificate.church_address/address.street_2'), with: STREET_2)
    fill_in(I18n.t('activerecord.attributes.baptismal_certificate.church_address/address.city'), with: CITY)
    fill_in(I18n.t('activerecord.attributes.baptismal_certificate.church_address/address.state'), with: STATE)
    fill_in(I18n.t('activerecord.attributes.baptismal_certificate.church_address/address.zip_code'), with: ZIP_CODE)

    # rubocop:disable Layout/LineLength
    attach_file(I18n.t('activerecord.attributes.baptismal_certificate.certificate_picture'), 'spec/fixtures/files/actions.png') if attach_file
    # rubocop:enable Layout/LineLength
  end
end

# Helper class to hold expected values
#
class ExpectBCFormInfo
  attr_accessor :show_baptized_at_home_parish_info,
                :show_baptized_catholic_info,
                :show_profession_of_faith_info,
                :show_checked_baptized_at_home_parish,
                :yes_checked_baptized_at_home_parish,
                :no_checked_baptized_at_home_parish,
                :show_checked_baptized_catholic,
                :yes_checked_baptized_catholic,
                :no_checked_baptized_catholic,
                :values,
                :blank_fields

  # determine if a field have a value or not
  #
  # === Parameters:
  #
  # * <tt>:sym</tt> field name
  # * <tt>:i18_label_base</tt>
  #
  def field_value(sym, i18_label_base)
    val = values[sym]
    val = '' if blank_field?("#{i18_label_base}.#{sym}")
    val
  end

  # determine if a field have a value or not
  #
  # === Parameters:
  #
  # * <tt>:i18n_path</tt>
  #
  def blank_field?(i18n_path)
    blank_fields.include?(I18n.t('errors.format_blank', attribute: I18n.t(i18n_path)))
  end

  # Set attributes expect to be showing
  #
  # === Parameters:
  #
  # * <tt>:show_home_parish_info</tt>
  # * <tt>:show_baptized_catholic_info</tt>
  # * <tt>:show_profession_info</tt>
  #
  def show_info(show_home_parish_info, show_baptized_catholic_info, show_profession_info)
    @show_baptized_at_home_parish_info = show_home_parish_info
    @show_baptized_catholic_info = show_baptized_catholic_info
    @show_profession_of_faith_info = show_profession_info
    init_values
    self
  end

  # determine which fields be blank bbased on expected error messages
  #
  # === Parameters:
  #
  # * <tt>:expected_messages</tt>
  #
  def add_blank_fields(expected_messages)
    if expected_messages.nil? || expected_messages.size < 2
      @blank_fields = []
    else
      @blank_fields = expected_messages[1][1] unless expected_messages.nil?
    end
  end

  private

  def init_values
    @values =
      {
        expected_messages: [],
        expect_scanned_image: false,
        expect_prof_scanned_image: false,
        # basic info
        birth_date: !show_baptized_at_home_parish_info ? nil : BIRTH_DATE,
        baptismal_date: !show_baptized_at_home_parish_info ? nil : BAPTISMAL_DATE,

        father_first: !show_baptized_at_home_parish_info ? nil : FATHER_FIRST,
        father_middle: !show_baptized_at_home_parish_info ? nil : FATHER_MIDDLE,
        father_last: !show_baptized_at_home_parish_info ? nil : LAST_NAME,

        mother_first: !show_baptized_at_home_parish_info ? nil : MOTHER_FIRST,
        mother_middle: !show_baptized_at_home_parish_info ? nil : MOTHER_MIDDLE,
        mother_maiden: !show_baptized_at_home_parish_info ? nil : MOTHER_MAIDEN,
        mother_last: !show_baptized_at_home_parish_info ? nil : LAST_NAME,

        first_name: !show_baptized_at_home_parish_info ? nil : FIRST_NAME,
        middle_name: !show_baptized_at_home_parish_info ? nil : MIDDLE_NAME,
        last_name: !show_baptized_at_home_parish_info ? nil : LAST_NAME,

        # baptized catholic info
        church_name: !show_baptized_catholic_info ? nil : CHURCH_NAME,
        dv_church_name: Visitor.home_parish,
        street1: !show_baptized_catholic_info ? nil : STREET_1,
        "dv-street1": Visitor.visitor.home_parish_address.street_1,
        street_1: !show_baptized_catholic_info ? nil : STREET_1, # remove
        street2: !show_baptized_catholic_info ? nil : STREET_2,
        "dv-street2": Visitor.visitor.home_parish_address.street_2,
        street_2: !show_baptized_catholic_info ? nil : STREET_2, # remove
        city: !show_baptized_catholic_info ? nil : CITY,
        "dv-city": Visitor.visitor.home_parish_address.city,
        state: !show_baptized_catholic_info ? nil : STATE,
        "dv-state": Visitor.visitor.home_parish_address.state,
        zip_code: !show_baptized_catholic_info ? nil : ZIP_CODE,
        "dv-zip_code": Visitor.visitor.home_parish_address.zip_code,

        # profession of faith info
        prof_date: !show_profession_of_faith_info ? nil : PROF_DATE,
        prof_church_name: !show_profession_of_faith_info ? nil : PROF_CHURCH_NAME,
        prof_street1: !show_profession_of_faith_info ? nil : PROF_STREET_1,
        prof_street_1: !show_profession_of_faith_info ? nil : PROF_STREET_1, # remove
        prof_street2: !show_profession_of_faith_info ? nil : PROF_STREET_2,
        prof_street_2: !show_profession_of_faith_info ? nil : PROF_STREET_2, # remove
        prof_city: !show_profession_of_faith_info ? nil : PROF_CITY,
        prof_state: !show_profession_of_faith_info ? nil : PROF_STATE,
        prof_zip_code: !show_profession_of_faith_info ? nil : PROF_ZIP_CODE
      }
  end
end
