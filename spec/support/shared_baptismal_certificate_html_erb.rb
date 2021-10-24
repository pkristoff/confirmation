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
LAST_NAME = 'Agusta'
MOTHER_FIRST = 'Paulette'
MOTHER_MIDDLE = 'Thette'
MOTHER_MAIDEN = 'Mary'
FIRST_NAME = 'Sophia'
MIDDLE_NAME = 'xxx'

shared_context 'baptismal_certificate_html_erb' do
  include ViewsHelpers
  before(:each) do
    event_with_picture_setup(Event::Route::BAPTISMAL_CERTIFICATE, { is_verify: @is_verify })
    AppFactory.add_confirmation_events
    @today = Time.zone.today
    page.driver.header 'Accept-Language', locale
    I18n.locale = locale

    @button_name = I18n.t('views.common.update_verify') if @is_verify
    @button_name = I18n.t('views.common.update') unless @is_verify
    cand_name = 'Sophia Agusta'
    @updated_message = I18n.t('messages.updated_verified', cand_name: cand_name) if @is_verify
    @updated_failed_verification = I18n.t('messages.updated_not_verified', cand_name: cand_name) if @is_verify
    @updated_message = I18n.t('messages.updated', cand_name: cand_name) unless @is_verify
    @updated_failed_verification = I18n.t('messages.updated', cand_name: cand_name) unless @is_verify
    @bc_form_info = ExpectBCFormInfo.new
  end
  feature 'show_empty_radio = 0' do
    before(:each) do
      @candidate.baptismal_certificate.show_empty_radio = 0
      @candidate.save!
      @bc_form_info.show_checked_baptized_at_home_parish = false
      @bc_form_info.yes_checked_baptized_at_home_parish = false
      @bc_form_info.no_checked_baptized_at_home_parish = false
      @bc_form_info.show_checked_baptized_catholic = false
    end
    feature 'initial screens' do
      scenario 'admin logs in and selects a candidate, nothing else showing' do
        update_baptismal_certificate

        visit @path

        expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify,
                                          @bc_form_info.show_info(false, false, false), false)
      end
    end
    feature 'error messages' do
      scenario 'do not fill in any fields should get baptized at home parish should be checked' do
        update_baptismal_certificate

        visit @path
        click_button @update_id

        expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify,
                                          @bc_form_info.show_info(false, false, false), false,
                                          expected_messages: [[:flash_notice, @updated_failed_verification],
                                                              # rubocop:disable Layout/LineLength
                                                              [:error_explanation, [I18n.t('messages.error.missing_attribute', err_count: 1),
                                                                                    I18n.t('messages.error.baptized_should_be_checked', home_parish: Visitor.home_parish)]]])
        # rubocop:enable Layout/LineLength
      end
    end
  end

  feature 'show_empty_radio = 1' do
    before(:each) do
      @candidate.baptismal_certificate.show_empty_radio = 1
      @candidate.save!
      @bc_form_info.show_checked_baptized_at_home_parish = true
      @bc_form_info.show_checked_baptized_catholic = false
    end
    feature 'baptized_at_home_parish = true' do
      before(:each) do
        @candidate.baptismal_certificate.baptized_at_home_parish = true
        @candidate.save!
        @bc_form_info.yes_checked_baptized_at_home_parish = true
        @bc_form_info.no_checked_baptized_at_home_parish = false
      end
      feature 'initial screens' do
        scenario 'admin logs in and selects a candidate, nothing else showing' do
          update_baptismal_certificate(home_parish_fields: true)

          visit @path

          expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify,
                                            @bc_form_info.show_info(true, false, false), false)
        end

        scenario 'admin logs in and selects a candidate, initial baptized_at_home_parish = true, show_empty_radio = 1' do
          update_baptismal_certificate(home_parish_fields: true)

          visit @path

          expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify,
                                            @bc_form_info.show_info(true, false, false), false)
        end
      end
      feature 'error messages' do
        scenario 'does not fill in any fields should only get fields for baptized home parish' do
          update_baptismal_certificate

          visit @path
          fill_in(I18n.t('label.candidate_sheet.middle_name'), with: MIDDLE_NAME)
          click_button @update_id

          expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify,
                                            @bc_form_info.show_info(true, false, false), false,
                                            expected_messages: [[:flash_notice, @updated_failed_verification],
                                                                # rubocop:disable Layout/LineLength
                                                                [:error_explanation, [I18n.t('messages.error.missing_attributes', err_count: 9),
                                                                                      "Birth date #{I18n.t('errors.messages.blank')}",
                                                                                      "Baptismal date #{I18n.t('errors.messages.blank')}",
                                                                                      "Father first #{I18n.t('errors.messages.blank')}",
                                                                                      "Father middle #{I18n.t('errors.messages.blank')}",
                                                                                      "Father last #{I18n.t('errors.messages.blank')}",
                                                                                      "Mother first #{I18n.t('errors.messages.blank')}",
                                                                                      "Mother middle #{I18n.t('errors.messages.blank')}",
                                                                                      "Mother maiden #{I18n.t('errors.messages.blank')}",
                                                                                      "Mother last #{I18n.t('errors.messages.blank')}"]]])
          # rubocop:enable Layout/LineLength
        end
        scenario 'admin un-verifies a verified baptized event' do
          expect(@is_verify == true || @is_verify == false).to eq(true)

          event_key = BaptismalCertificate.event_key
          @candidate.get_candidate_event(event_key).completed_date = @today
          @candidate.get_candidate_event(event_key).verified = true
          @candidate.save!

          update_baptismal_certificate(home_parish_fields: true)

          visit @path

          expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify,
                                            @bc_form_info.show_info(true, false, false), false)

          expect(page).to have_button(I18n.t('views.common.un_verify'), count: 2) if @is_verify

          click_button('bottom-unverify') if @is_verify

          candidate = Candidate.find(@candidate.id)
          # rubocop:disable Layout/LineLength
          if @is_verify

            expect_mass_edit_candidates_event(ConfirmationEvent.find_by(event_key: event_key), candidate.id, I18n.t('messages.updated_unverified', cand_name: "#{candidate.candidate_sheet.first_name} #{candidate.candidate_sheet.last_name}"), { is_unverified: true })
          else
            expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify,
                                              @bc_form_info.show_info(true, false, false), false)
          end
          # rubocop:enable Layout/LineLength

          expect(candidate.get_candidate_event(event_key).completed_date).to eq(@today)
          expect(candidate.get_candidate_event(event_key).verified).to eq(!@is_verify)
        end
      end
    end
    feature 'baptized_at_home_parish = false' do
      before(:each) do
        @candidate.baptismal_certificate.baptized_at_home_parish = false
        @candidate.save!
        @bc_form_info.yes_checked_baptized_at_home_parish = false
        @bc_form_info.no_checked_baptized_at_home_parish = true
      end
      feature 'initial screens' do
        scenario 'admin logs in and selects a candidate, fc showing - no check showing' do
          update_baptismal_certificate(home_parish_fields: true)

          visit @path

          expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify,
                                            @bc_form_info.show_info(true, false, false), false)
        end
        # rubocop:disable Layout/LineLength
        scenario 'admin logs in and selects a candidate, initial baptized_at_home_parish = true, show_empty_radio = 1 fc showing - yes check' do
          # rubocop:enable Layout/LineLength
          update_baptismal_certificate(home_parish_fields: true)

          visit @path

          expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify,
                                            @bc_form_info.show_info(true, false, false), false)
        end
      end
      feature 'error messages' do
        scenario 'does not fill in any fields should only get fields for baptized home parish plus baptized catholic' do
          update_baptismal_certificate

          visit @path
          fill_in(I18n.t('label.candidate_sheet.middle_name'), with: MIDDLE_NAME)
          click_button @update_id

          expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify,
                                            @bc_form_info.show_info(true, false, false), false,
                                            expected_messages: [[:flash_notice, @updated_failed_verification],
                                                                # rubocop:disable Layout/LineLength
                                                                [:error_explanation, [I18n.t('messages.error.missing_attributes', err_count: 10),
                                                                                      "Birth date #{I18n.t('errors.messages.blank')}",
                                                                                      "Baptismal date #{I18n.t('errors.messages.blank')}",
                                                                                      "Father first #{I18n.t('errors.messages.blank')}",
                                                                                      "Father middle #{I18n.t('errors.messages.blank')}",
                                                                                      "Father last #{I18n.t('errors.messages.blank')}",
                                                                                      "Mother first #{I18n.t('errors.messages.blank')}",
                                                                                      "Mother middle #{I18n.t('errors.messages.blank')}",
                                                                                      "Mother maiden #{I18n.t('errors.messages.blank')}",
                                                                                      "Mother last #{I18n.t('errors.messages.blank')}",
                                                                                      I18n.t('messages.error.baptized_catholic_should_be_checked')]]])
          # rubocop:enable Layout/LineLength
        end
      end
    end
  end

  feature 'show_empty_radio = 2' do
    before(:each) do
      @candidate.baptismal_certificate.show_empty_radio = 2
      @candidate.save!
      @bc_form_info.show_checked_baptized_at_home_parish = true
      @bc_form_info.show_checked_baptized_catholic = true
    end
    feature 'baptized_at_home_parish = false' do
      before(:each) do
        @candidate.baptismal_certificate.baptized_at_home_parish = false
        @candidate.save!
        @bc_form_info.yes_checked_baptized_at_home_parish = false
        @bc_form_info.no_checked_baptized_at_home_parish = true
      end
      feature 'initial screens' do
        scenario 'admin logs in and selects a candidate, unchecks baptized_at_home_parish, first communion showing' do
          update_baptismal_certificate(home_parish_fields: true, baptized_catholic: true)

          visit @path

          expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verif,
                                            @bc_form_info.show_info(true, true, true), false)
        end
      end
      # feature 'error messages' do
      #
      # end
      feature 'baptized_catholic = true' do
        before(:each) do
          @candidate.baptismal_certificate.baptized_catholic = true
          @bc_form_info.yes_checked_baptized_catholic = true
          @bc_form_info.no_checked_baptized_catholic = false
          @candidate.save!
        end
        # feature 'initial screens' do
        #
        # end
        feature 'error messages' do
          scenario 'should not show a validation error for city and zip code' do
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
                                                expected_messages: [[:flash_notice, @updated_message]])
            end
          end
          scenario 'admin logs in and selects a candidate, unchecks baptized_at_home_parish, fills in template' do
            update_baptismal_certificate(home_parish_fields: true, baptized_catholic: true)

            expect_db(1, 0)

            visit @path
            # rubocop:disable Layout/LineLength
            expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify,
                                              @bc_form_info.show_info(true, true, false), false)
            fill_in_form

            click_button @update_id

            candidate = Candidate.find(@candidate.id)

            if @is_verify

              expect_mass_edit_candidates_event(ConfirmationEvent.find_by(event_key: BaptismalCertificate.event_key), candidate.id, @updated_message)

            else

              expect_baptismal_certificate_form(candidate.id, @dev, @path_str, @button_name, @is_verify,
                                                @bc_form_info.show_info(true, true, false), false,
                                                expected_messages: [[:flash_notice, @updated_message]])

            end
            # rubocop:enable Layout/LineLength
            expect(candidate.baptismal_certificate.birth_date.to_s).to eq(BIRTH_DATE)
            expect(candidate.baptismal_certificate.baptismal_date.to_s).to eq(BAPTISMAL_DATE)
            expect(candidate.baptismal_certificate.church_name).to eq(CHURCH_NAME)
            expect(candidate.baptismal_certificate.church_address.street_1).to eq(STREET_1)
            expect(candidate.baptismal_certificate.church_address.street_2).to eq(STREET_2)
            expect(candidate.baptismal_certificate.church_address.city).to eq(CITY)
            expect(candidate.baptismal_certificate.church_address.state).to eq(STATE)
            expect(candidate.baptismal_certificate.church_address.zip_code).to eq(ZIP_CODE)
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

            expect_db(1, 1) # make sure DB does not increase in size.
          end
          scenario 'admin logs in and selects a candidate, unfills in template then changes mind she was baptized at stmm' do
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
                                                expected_messages: [[:flash_notice, @updated_message]])

            end

            visit @path

            choose('candidate_baptismal_certificate_attributes_baptized_at_home_parish_1')
            # since js is not called set show_empty_radio as update_show_empty_radio would do
            find(:id, 'candidate_baptismal_certificate_attributes_show_empty_radio', visible: false).set('1')

            click_button @update_id

            @bc_form_info.show_checked_baptized_catholic = false
            @bc_form_info.yes_checked_baptized_at_home_parish = true
            @bc_form_info.no_checked_baptized_at_home_parish = false

            candidate = Candidate.find(@candidate.id)
            if @is_verify

              expect_mass_edit_candidates_event(ConfirmationEvent.find_by(event_key: BaptismalCertificate.event_key),
                                                candidate.id, @updated_message)

            else

              expect_baptismal_certificate_form(candidate.id, @dev, @path_str, @button_name, @is_verify,
                                                @bc_form_info.show_info(true, false, false), false,
                                                expected_messages: [[:flash_notice, @updated_message]])

            end

            expect(candidate.baptismal_certificate).not_to eq(nil) # always created now
            expect(candidate.baptismal_certificate.baptized_at_home_parish).to eq(true)
            expect(candidate.get_candidate_event(BaptismalCertificate.event_key).completed_date).to eq(@today)
            expect(candidate.get_candidate_event(BaptismalCertificate.event_key).verified).to eq(@is_verify)
          end
          # rubocop:disable Layout/LineLength
          scenario 'admin logs in and selects a candidate, adds picture, updates, adds rest of valid data, updates - everything is saved' do
            update_baptismal_certificate(home_parish_fields: true, baptized_catholic: true)
            @candidate.candidate_sheet.middle_name = ''
            @candidate.candidate_sheet.while_not_validating_middle_name do
              @candidate.save!
            end

            visit @path
            attach_file(I18n.t('label.baptismal_certificate.baptismal_certificate.certificate_picture'), 'spec/fixtures/actions.png')
            click_button @update_id

            candidate = Candidate.find(@candidate.id)

            expect_baptismal_certificate_form(candidate.id, @dev, @path_str, @button_name, @is_verify,
                                              @bc_form_info.show_info(true, true, false), false,
                                              expected_messages: [[:flash_notice, @updated_failed_verification],
                                                                  [:error_explanation, [I18n.t('messages.error.missing_attribute', err_count: 1),
                                                                                        "Middle name #{I18n.t('errors.messages.blank')}"]]])

            candidate = Candidate.find(@candidate.id)

            expect(candidate.get_candidate_event(BaptismalCertificate.event_key).verified).to eq(false), 'Baptismal certificate not verified.'
            expect(candidate.get_candidate_event(BaptismalCertificate.event_key).completed_date).to eq(Time.zone.today)

            expect(candidate.get_candidate_event(CandidateSheet.event_key).verified).to eq(false)
            expect(candidate.get_candidate_event(CandidateSheet.event_key).completed_date).to eq(nil)

            fill_in(I18n.t('label.candidate_sheet.middle_name'), with: MIDDLE_NAME)

            click_button @update_id

            if @is_verify

              expect_mass_edit_candidates_event(ConfirmationEvent.find_by(event_key: BaptismalCertificate.event_key), candidate.id, @updated_message)

            else
              expect_baptismal_certificate_form(candidate.id, @dev, @path_str, @button_name, @is_verify,
                                                @bc_form_info.show_info(true, true, false), false, expected_messages: [[:flash_notice, @updated_message]])
            end

            cand = Candidate.find_by(id: candidate.id)
            expect(cand.get_candidate_event(BaptismalCertificate.event_key).verified).to eq(@is_verify), 'Baptismal certificate not verified.'
            expect(cand.get_candidate_event(BaptismalCertificate.event_key).completed_date).to eq(Time.zone.today)

            # candidate_information_sheet if completed is automatically verified
            expect(cand.get_candidate_event(CandidateSheet.event_key).verified?).to eq(true)
            expect(cand.get_candidate_event(CandidateSheet.event_key).completed_date).to eq(Time.zone.today)
          end
          # rubocop:enable Layout/LineLength
          scenario 'admin logs in and selects a candidate, checks no for baptized_at_home_parish and updates' do
            # rubocop:disable Layout/LineLength
            # This test was sometimes had middle_name == '' and sometimes not.  So
            # now it is always ''.
            @candidate.candidate_sheet.middle_name = ''
            @candidate.save!(validate: false)
            update_baptismal_certificate

            visit @path

            click_button @update_id

            candidate = Candidate.find(@candidate.id)

            expect_baptismal_certificate_form(candidate.id, @dev, @path_str, @button_name, @is_verify,
                                              @bc_form_info.show_info(true, true, false), false,
                                              expected_messages: [[:flash_notice, @updated_failed_verification],
                                                                  [:error_explanation, [I18n.t('messages.error.missing_attributes', err_count: 16),

                                                                                        "Middle name #{I18n.t('errors.messages.blank')}",

                                                                                        "Birth date #{I18n.t('errors.messages.blank')}",
                                                                                        "Baptismal date #{I18n.t('errors.messages.blank')}",
                                                                                        "Father first #{I18n.t('errors.messages.blank')}",
                                                                                        "Father middle #{I18n.t('errors.messages.blank')}",
                                                                                        "Father last #{I18n.t('errors.messages.blank')}",
                                                                                        "Mother first #{I18n.t('errors.messages.blank')}",
                                                                                        "Mother middle #{I18n.t('errors.messages.blank')}",
                                                                                        "Mother maiden #{I18n.t('errors.messages.blank')}",
                                                                                        "Mother last #{I18n.t('errors.messages.blank')}",

                                                                                        "Church name #{I18n.t('errors.messages.blank')}",
                                                                                        "Street 1 #{I18n.t('errors.messages.blank')}",
                                                                                        "City #{I18n.t('errors.messages.blank')}",
                                                                                        "State #{I18n.t('errors.messages.blank')}",
                                                                                        "Zip code #{I18n.t('errors.messages.blank')}",

                                                                                        "Scanned baptismal certificate #{I18n.t('errors.messages.blank')}"],
                                                                   16]])
            # rubocop:enable Layout/LineLength
          end
          # rubocop:disable Layout/LineLength
          scenario 'admin logs in and selects a candidate, adds non-picture data, updates, adds picture, updates - everything is saved' do
            update_baptismal_certificate
            visit @path

            fill_in_form({ attach_file: false }) # no picture
            click_button @update_id

            expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify,
                                              @bc_form_info.show_info(true, true, false), false,
                                              expected_messages: [[:flash_notice, @updated_failed_verification],
                                                                  [:error_explanation, [I18n.t('messages.error.missing_attribute', err_count: 1),
                                                                                        "Scanned baptismal certificate #{I18n.t('errors.messages.blank')}"]]])

            attach_file(I18n.t('label.baptismal_certificate.baptismal_certificate.certificate_picture'), 'spec/fixtures/actions.png')
            click_button @update_id

            candidate = Candidate.find(@candidate.id)
            if @is_verify

              expect_mass_edit_candidates_event(ConfirmationEvent.find_by(event_key: BaptismalCertificate.event_key), candidate.id, @updated_message)

            else

              expect_baptismal_certificate_form(candidate.id, @dev, @path_str, @button_name, @is_verify,
                                                @bc_form_info.show_info(true, true, false), false,
                                                expected_messages: [[:flash_notice, @updated_message]])

              expect(candidate.baptismal_certificate.baptized_at_home_parish).to eq(false)
              expect(candidate.baptismal_certificate).not_to eq(nil)
              expect(candidate.baptismal_certificate.scanned_certificate).not_to eq(nil)

            end

            visit @path
            candidate = Candidate.find(@candidate.id)
            expect_baptismal_certificate_form(candidate.id, @dev, @path_str, @button_name, @is_verify,
                                              @bc_form_info.show_info(true, true, false), false,
                                              expected_messages: [[:flash_notice, @updated_message]])
          end
          # rubocop:enable Layout/LineLength
        end
      end
      feature 'baptized_catholic = false' do
        before(:each) do
          @candidate.baptismal_certificate.baptized_catholic = false
          @candidate.save!
          @bc_form_info.yes_checked_baptized_catholic = false
          @bc_form_info.no_checked_baptized_catholic = true
        end
        # feature 'initial screens' do
        #   scenario 'everything filled in' do
        #     update_baptismal_certificate(home_parish_fields: true, baptized_catholic: true, prof_of_faith: true)
        #
        #     visit @path
        #     expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify,
        #                                       @bc_form_info.show_info(true, false, true), false)
        #   end
        #   scenario 'everything empty in' do
        #     update_baptismal_certificate(home_parish_fields: false, baptized_catholic: false, prof_of_faith: false)
        #
        #     visit @path
        #     expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify,
        #                                       @bc_form_info.show_info(true, false, true), false)
        #   end
        # end
        feature 'error messages' do
          scenario 'should not show a validation error scanned baptismal certificate & profession of faith' do
            update_baptismal_certificate(home_parish_fields: true, baptized_catholic: true, prof_of_faith: true)

            visit @path

            expect_field(I18n.t('label.baptismal_certificate.baptismal_certificate.prof_picture'), nil)

            expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify,
                                              @bc_form_info.show_info(true, true, true), false)
            # fill_in(I18n.t('label.candidate_sheet.first_name'), with: '')
            # fill_in(I18n.t('label.baptismal_certificate.baptismal_certificate.mother_first'), with: '')
            click_button @update_id

            # rubocop:disable Layout/LineLength
            expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify,
                                              @bc_form_info.show_info(true, true, true), false,
                                              expected_messages: [[:flash_notice, @updated_failed_verification],
                                                                  [:error_explanation, [I18n.t('messages.error.missing_attributes', err_count: 2),
                                                                                        "Scanned baptismal certificate #{I18n.t('errors.messages.blank')}",
                                                                                        "Scanned Profession 0f faith #{I18n.t('errors.messages.blank')}"]]])
            # rubocop:enable Layout/LineLength

            attach_file(I18n.t('label.baptismal_certificate.baptismal_certificate.certificate_picture'),
                        'spec/fixtures/actions.png')
            attach_file(I18n.t('label.baptismal_certificate.baptismal_certificate.prof_picture'),
                        'spec/fixtures/actions.png')
            click_button @update_id

            if @is_verify

              expect_mass_edit_candidates_event(ConfirmationEvent.find_by(event_key: BaptismalCertificate.event_key),
                                                @candidate.id, @updated_message)

            else
              # expect_loaded_scanned_images

              expect_baptismal_certificate_form(@candidate.id, @dev, @path_str, @button_name, @is_verify,
                                                @bc_form_info.show_info(true, true, true), false,
                                                expected_messages: [[:flash_notice, @updated_message]])
            end
          end
        end
      end
    end
  end

  private

  include ExpectAddress

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

    expect_messages(values[:expected_messages]) unless values[:expected_messages].nil?

    if values[:expected_messages].nil? || values[:expected_messages].size < 2
      blank_fields = []
    else
      blank_fields = values[:expected_messages][1][1] unless values[:expected_messages].nil?
    end

    cand = Candidate.find(cand_id)

    expect_heading(cand, dev_path.empty?, BaptismalCertificate.event_key)

    expect(page).to have_selector("form[id=edit_candidate][action=\"/#{dev_path}#{path_str}/#{cand_id}/baptismal_certificate\"]")
    expect(page).to have_selector('div', text: I18n.t('label.baptismal_certificate.baptismal_certificate.baptized_at_home_parish', home_parish: Visitor.home_parish))

    expect(page).to have_selector("div[id=baptized-at-home-parish-info][class='#{!bc_form_info.show_baptized_at_home_parish_info ? 'hide-div' : 'show-div'}']")

    expect_field(I18n.t('label.baptismal_certificate.baptismal_certificate.certificate_picture'), nil)

    baptized_home_parish_radios(bc_form_info)
    expect(page).to have_selector("div[id=baptized-at-home-parish-info][class='#{!bc_form_info.show_baptized_at_home_parish_info ? 'hide-div' : 'show-div'}']")
    expect_home_parish(page, disabled, bc_form_info.show_baptized_at_home_parish_info, blank_fields, values)

    baptized_catholic_radios(bc_form_info)
    expect(page).to have_selector("div[id=baptized-catholic-info][class='#{!bc_form_info.show_baptized_catholic_info ? 'hide-div' : 'show-div'}']")
    expect_baptized_catholic(page, disabled, bc_form_info.show_baptized_catholic_info, blank_fields, values)

    expect(page).to have_selector("div[id=profession-of-faith-info][class='#{!bc_form_info.show_profession_of_faith_info ? 'hide-div' : 'show-div'}']")

    expect_image_upload('baptismal_certificate', 'certificate_picture', I18n.t('label.baptismal_certificate.baptismal_certificate.certificate_picture'))

    expect(page).to have_button(button_name, count: 2)
    # remove_count = cand.baptismal_certificate.scanned_certificate.nil? ? 0 : 1
    expect_remove_button('candidate_baptismal_certificate_attributes_remove_certificate_picture', 'certificate_picture') unless cand.baptismal_certificate.scanned_certificate.nil?
    expect(page).to have_button(I18n.t('views.common.remove_image'), count: 1)
    expect(page).to have_button(I18n.t('views.common.replace_image'), count: 1)
    expect(page).to have_button(I18n.t('views.common.un_verify'), count: 2) if is_verify
    expect_download_button(Event::Document::BAPTISMAL_CERTIFICATE, cand_id, dev_path)
    # rubocop:enable Layout/LineLength
  end

  def fill_in_form(attach_file: true)
    fill_in(I18n.t('label.baptismal_certificate.baptismal_certificate.birth_date'), with: BIRTH_DATE)
    fill_in(I18n.t('label.baptismal_certificate.baptismal_certificate.baptismal_date'), with: BAPTISMAL_DATE)
    fill_in(I18n.t('label.baptismal_certificate.baptismal_certificate.church_name'), with: CHURCH_NAME)
    fill_in(I18n.t('label.baptismal_certificate.baptismal_certificate.church_address.street_1'), with: STREET_1)
    fill_in(I18n.t('label.baptismal_certificate.baptismal_certificate.church_address.street_2'), with: STREET_2)
    fill_in(I18n.t('label.baptismal_certificate.baptismal_certificate.church_address.city'), with: CITY)
    fill_in(I18n.t('label.baptismal_certificate.baptismal_certificate.church_address.state'), with: STATE)
    fill_in(I18n.t('label.baptismal_certificate.baptismal_certificate.church_address.zip_code'), with: ZIP_CODE)
    fill_in(I18n.t('label.baptismal_certificate.baptismal_certificate.father_first'), with: FATHER_FIRST)
    fill_in(I18n.t('label.baptismal_certificate.baptismal_certificate.father_middle'), with: FATHER_MIDDLE)
    fill_in(I18n.t('label.baptismal_certificate.baptismal_certificate.father_last'), with: LAST_NAME)
    fill_in(I18n.t('label.baptismal_certificate.baptismal_certificate.mother_first'), with: MOTHER_FIRST)
    fill_in(I18n.t('label.baptismal_certificate.baptismal_certificate.mother_middle'), with: MOTHER_MIDDLE)
    fill_in(I18n.t('label.baptismal_certificate.baptismal_certificate.mother_maiden'), with: MOTHER_MAIDEN)
    fill_in(I18n.t('label.baptismal_certificate.baptismal_certificate.mother_last'), with: LAST_NAME)

    fill_in(I18n.t('label.candidate_sheet.first_name'), with: FIRST_NAME)
    fill_in(I18n.t('label.candidate_sheet.middle_name'), with: MIDDLE_NAME)
    fill_in(I18n.t('label.candidate_sheet.last_name'), with: LAST_NAME)

    # rubocop:disable Layout/LineLength
    attach_file(I18n.t('label.baptismal_certificate.baptismal_certificate.certificate_picture'), 'spec/fixtures/actions.png') if attach_file
    # rubocop:enable Layout/LineLength
  end

  def img_src_selector(is_other: nil)
    return "img[src=\"/#{@dev}event_with_picture_image/#{@candidate.id}/baptismal_certificate\"]" if is_other.nil?

    # rubocop:disable Layout/LineLength
    "img[src=\"/#{@dev}event_with_picture_image/#{@candidate.id}/baptismal_certificate/is_other/#{is_other}\"]" unless is_other.nil?
    # rubocop:enable Layout/LineLength
  end

  def update_baptismal_certificate(home_parish_fields: false, baptized_catholic: false, prof_of_faith: false)
    if home_parish_fields
      # return unless home_parish_fields

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
      # return unless baptized_catholic

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
    yes_id = 'candidate_baptismal_certificate_attributes_baptized_at_home_parish_1'
    no_id = 'candidate_baptismal_certificate_attributes_baptized_at_home_parish_0'
    expect(page).to have_selector("input[type=radio][id=#{yes_id}][value='1']", count: 1)
    expect(page).to have_selector("input[type=radio][id=#{no_id}][value='0']", count: 1)

    should_show_checked = bc_form_info.show_checked_baptized_at_home_parish
    yes_checked = should_show_checked && bc_form_info.yes_checked_baptized_at_home_parish
    no_checked = should_show_checked && bc_form_info.no_checked_baptized_at_home_parish
    # no_checked = should_show_checked && !cand.baptismal_certificate.baptized_at_home_parish

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
    yes_id = 'candidate_baptismal_certificate_attributes_baptized_catholic_1'
    no_id = 'candidate_baptismal_certificate_attributes_baptized_catholic_0'
    expect(page).to have_selector("input[type=radio][id=#{yes_id}][value='1']", count: 1)
    expect(page).to have_selector("input[type=radio][id=#{no_id}][value='0']", count: 1)

    should_show_checked = bc_form_info.show_checked_baptized_catholic
    # should_show_checked = cand.baptismal_certificate.show_empty_radio > 1
    yes_checked = should_show_checked && bc_form_info.yes_checked_baptized_catholic
    no_checked = should_show_checked && bc_form_info.no_checked_baptized_catholic
    # yes_checked = should_show_checked && cand.baptismal_certificate.baptized_catholic
    # no_checked = should_show_checked && !cand.baptismal_certificate.baptized_catholic

    expect(find_field(yes_id)).to be_checked if should_show_checked && yes_checked
    expect(find_field(no_id)).not_to be_checked if should_show_checked && yes_checked

    expect(find_field(yes_id)).not_to be_checked if should_show_checked && no_checked
    expect(find_field(no_id)).to be_checked if should_show_checked && no_checked
    should_show_checked
  end

  def expect_baptized_catholic(rendered_or_page, disabled, visible, blank_fields, values)
    text_fields = %i[church_name]

    ExpectAddress.expect_address_fields(rendered_or_page, values, disabled, blank_fields, visible)

    text_fields.each do |sym|
      val = values[sym]
      val = '' if ExpectAddress.blank_field(blank_fields, "label.baptismal_certificate.baptismal_certificate.#{sym}")
      ExpectFields.expect_have_field_text(
        rendered_or_page,
        I18n.t("label.baptismal_certificate.baptismal_certificate.#{sym}"),
        "candidate_baptismal_certificate_attributes_#{sym}",
        val,
        disabled,
        visible
      )
    end
  end

  def expect_home_parish(rendered_or_page, disabled, visible, blank_fields, values)
    cs_text_fields = %i[first_name middle_name last_name]
    cs_text_fields.each do |sym|
      val = values[sym]
      val = '' if ExpectAddress.blank_field(blank_fields, "label.candidate_sheet.#{sym}")
      ExpectFields.expect_have_field_text(
        rendered_or_page,
        I18n.t("label.candidate_sheet.#{sym}"),
        "candidate_candidate_sheet_attributes_#{sym}",
        val,
        disabled,
        visible
      )
    end

    text_fields = %i[father_first father_middle father_last
                     mother_first mother_middle mother_maiden mother_last]
    text_fields.each do |sym|
      val = values[sym]
      val = '' if ExpectAddress.blank_field(blank_fields, "label.baptismal_certificate.baptismal_certificate.#{sym}")
      ExpectFields.expect_have_field_text(
        rendered_or_page,
        I18n.t("label.baptismal_certificate.baptismal_certificate.#{sym}"),
        "candidate_baptismal_certificate_attributes_#{sym}",
        val,
        disabled,
        visible
      )
    end

    val = values[:birth_date]
    val = '' if ExpectAddress.blank_field(blank_fields, 'label.baptismal_certificate.baptismal_certificate.birth_date')
    vis = visible && !val.empty?
    ExpectFields.expect_have_field_date(
      rendered_or_page,
      I18n.t('label.baptismal_certificate.baptismal_certificate.birth_date'),
      'candidate_baptismal_certificate_attributes_birth_date',
      val,
      disabled,
      vis
    )
  end
end

class ExpectBCFormInfo
  attr_accessor :show_baptized_at_home_parish_info,
                :show_baptized_catholic_info,
                :show_profession_of_faith_info,
                :show_checked_baptized_at_home_parish,
                :yes_checked_baptized_at_home_parish,
                :no_checked_baptized_at_home_parish,
                :show_checked_baptized_catholic,
                :yes_checked_baptized_catholic,
                :no_checked_baptized_catholic

  def show_info(show_home_parish_info, show_hide_baptized_catholic_info, show_profession_info)
    @show_baptized_at_home_parish_info = show_home_parish_info
    @show_baptized_catholic_info = show_hide_baptized_catholic_info
    @show_profession_of_faith_info = show_profession_info
    self
  end

  def values
    {
      expected_messages: [],
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

      church_name: !show_baptized_catholic_info ? nil : CHURCH_NAME,
      street1: !show_baptized_catholic_info ? nil : STREET_1,
      street_1: !show_baptized_catholic_info ? nil : STREET_1, # remove
      street2: !show_baptized_catholic_info ? nil : STREET_2,
      street_2: !show_baptized_catholic_info ? nil : STREET_2, # remove
      city: !show_baptized_catholic_info ? nil : CITY,
      state: !show_baptized_catholic_info ? nil : STATE,
      zip_code: !show_baptized_catholic_info ? nil : ZIP_CODE,

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
