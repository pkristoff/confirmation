# frozen_string_literal: true

require 'rails_helper'

describe BaptismalCertificate do
  describe 'factories' do
    it 'can retrieve info if baptized_at_home_parish=true' do
      baptismal_certificate = FactoryBot.create(:baptismal_certificate)
      expect_baptized_at_home_parish(baptismal_certificate)
      expect_baptized_catholic(baptismal_certificate, false)
    end

    it 'can retrieve info if baptized_at_home_parish=false && baptized_catholic=true' do
      baptismal_certificate = FactoryBot.create(:baptismal_certificate, setup_baptized_catholic: true)
      expect_baptized_at_home_parish(baptismal_certificate)
      expect_baptized_catholic(baptismal_certificate, true)
    end

    it 'can retrieve info if baptized_at_home_parish=false && baptized_catholic=false' do
      baptismal_certificate = FactoryBot.create(:baptismal_certificate, setup_profession_of_faith: true)
      expect_baptized_at_home_parish(baptismal_certificate)
      expect_baptized_catholic(baptismal_certificate, true)
      expect_profession_of_faith(baptismal_certificate, true)
    end
  end

  describe 'verifiables' do
    it 'baptized_at_home_parish is true' do
      verifiables = FactoryBot.create(:baptismal_certificate).verifiable_info
      expected_verifiables = expected_verifiable_baptized_at_home_parish
      expect_verifiables(expected_verifiables, verifiables)
    end

    it 'baptized_at_home_parish is false && baptized_catholic is true' do
      verifiables = FactoryBot.create(:baptismal_certificate, setup_baptized_catholic: true).verifiable_info

      expected_verifiables = expected_verifiables_baptized_catholic.merge(expected_verifiable_baptized_at_home_parish)
      expect_verifiables(expected_verifiables, verifiables)
    end

    it 'baptized_at_home_parish is false && baptized_catholic is false' do
      verifiables = FactoryBot.create(:baptismal_certificate, setup_profession_of_faith: true).verifiable_info

      expected_verifiables = expected_verifiables_baptized_catholic.merge(expected_verifiable_baptized_at_home_parish)
                                                                   .merge(
                                                                     {
                                                                       'Prof date': Date.parse('1990-10-20'),
                                                                       'Prof church': 'St. Anthonys',
                                                                       'Prof street': '1313 Sherwood',
                                                                       'Prof street 2': 'Apt 123',
                                                                       'Prof city': 'Clarksville',
                                                                       'Prof state': 'IN',
                                                                       'Prof zip code': '47130'
                                                                     }
                                                                   )
      expect_verifiables(expected_verifiables, verifiables)
    end
  end

  describe 'show check and divs' do
    before do
      @baptismal_certificate = FactoryBot.create(:baptismal_certificate)
    end

    describe 'show_empty_radio=0' do
      before do
        @baptismal_certificate.show_empty_radio = 0
      end

      describe 'baptized_at_home_parish=false' do
        before do
          @baptismal_certificate.baptized_at_home_parish = false
        end

        it 'baptized_at_home_parish not chosen false' do
          expect(@baptismal_certificate.show_baptized_at_home_parish_radio).to be(true)
          expect(@baptismal_certificate.show_baptized_catholic_radio).to be(false)

          expect(@baptismal_certificate.baptized_at_home_parish_yes_checked).to be(false)
          expect(@baptismal_certificate.baptized_at_home_parish_no_checked).to be(false)
          expect(@baptismal_certificate.baptized_catholic_yes_checked).to be(false)
          expect(@baptismal_certificate.baptized_catholic_no_checked).to be(false)

          expect(@baptismal_certificate.info_show).to be(false)
          expect(@baptismal_certificate.info_show_baptized_catholic).to be(false)
          expect(@baptismal_certificate.info_show_profession_of_faith).to be(false)
        end
      end

      describe 'baptized_at_home_parish=false 2' do
        before do
          @baptismal_certificate.baptized_at_home_parish = true
        end

        it 'run queries' do
          expect(@baptismal_certificate.show_baptized_at_home_parish_radio).to be(true)
          expect(@baptismal_certificate.show_baptized_catholic_radio).to be(false)

          expect(@baptismal_certificate.baptized_at_home_parish_yes_checked).to be(false)
          expect(@baptismal_certificate.baptized_at_home_parish_no_checked).to be(false)
          expect(@baptismal_certificate.baptized_catholic_yes_checked).to be(false)
          expect(@baptismal_certificate.baptized_catholic_no_checked).to be(false)

          expect(@baptismal_certificate.info_show).to be(false)
          expect(@baptismal_certificate.info_show_baptized_catholic).to be(false)
          expect(@baptismal_certificate.info_show_profession_of_faith).to be(false)
        end
      end

      it 'run queries' do
        expect(@baptismal_certificate.show_baptized_at_home_parish_radio).to be(true)
        expect(@baptismal_certificate.show_baptized_catholic_radio).to be(false)

        expect(@baptismal_certificate.baptized_at_home_parish_yes_checked).to be(false)
        expect(@baptismal_certificate.baptized_at_home_parish_no_checked).to be(false)
        expect(@baptismal_certificate.baptized_catholic_yes_checked).to be(false)
        expect(@baptismal_certificate.baptized_catholic_no_checked).to be(false)

        expect(@baptismal_certificate.info_show).to be(false)
        expect(@baptismal_certificate.info_show_baptized_catholic).to be(false)
        expect(@baptismal_certificate.info_show_profession_of_faith).to be(false)
      end
    end

    describe 'show_empty_radio=1' do
      before do
        @baptismal_certificate.show_empty_radio = 1
      end

      describe 'baptized_at_home_parish=true' do
        before do
          @baptismal_certificate.baptized_at_home_parish = true
        end

        it 'run queries' do
          expect(@baptismal_certificate.show_baptized_at_home_parish_radio).to be(true)
          expect(@baptismal_certificate.show_baptized_catholic_radio).to be(false)

          expect(@baptismal_certificate.baptized_at_home_parish_yes_checked).to be(true)
          expect(@baptismal_certificate.baptized_at_home_parish_no_checked).to be(false)
          expect(@baptismal_certificate.baptized_catholic_yes_checked).to be(false)
          expect(@baptismal_certificate.baptized_catholic_no_checked).to be(false)

          expect(@baptismal_certificate.info_show).to be(true)
          expect(@baptismal_certificate.info_show_baptized_catholic).to be(true)
          expect(@baptismal_certificate.info_show_profession_of_faith).to be(false)
        end
      end

      describe 'baptized_at_home_parish=false' do
        before do
          @baptismal_certificate.baptized_at_home_parish = false
        end

        it 'run queries' do
          expect(@baptismal_certificate.show_baptized_at_home_parish_radio).to be(true)
          expect(@baptismal_certificate.show_baptized_catholic_radio).to be(true)

          expect(@baptismal_certificate.baptized_at_home_parish_yes_checked).to be(false)
          expect(@baptismal_certificate.baptized_at_home_parish_no_checked).to be(true)
          expect(@baptismal_certificate.baptized_catholic_yes_checked).to be(false)
          expect(@baptismal_certificate.baptized_catholic_no_checked).to be(false)

          expect(@baptismal_certificate.info_show).to be(true)
          expect(@baptismal_certificate.info_show_baptized_catholic).to be(true)
          expect(@baptismal_certificate.info_show_profession_of_faith).to be(false)
        end
      end
    end

    describe 'show_empty_radio=2' do
      before do
        @baptismal_certificate.show_empty_radio = 2
      end

      describe 'baptized_at_home_parish=false' do
        before do
          @baptismal_certificate.baptized_at_home_parish = false
        end

        describe 'baptized_catholic=true' do
          before do
            @baptismal_certificate.baptized_catholic = true
          end

          it 'run queries' do
            expect(@baptismal_certificate.show_baptized_at_home_parish_radio).to be(true)
            expect(@baptismal_certificate.show_baptized_catholic_radio).to be(true)

            expect(@baptismal_certificate.baptized_at_home_parish_yes_checked).to be(false)
            expect(@baptismal_certificate.baptized_at_home_parish_no_checked).to be(true)
            expect(@baptismal_certificate.baptized_catholic_yes_checked).to be(true)
            expect(@baptismal_certificate.baptized_catholic_no_checked).to be(false)

            expect(@baptismal_certificate.info_show).to be(true)
            expect(@baptismal_certificate.info_show_baptized_catholic).to be(true)
            expect(@baptismal_certificate.info_show_profession_of_faith).to be(false)
          end
        end

        describe 'baptized_catholic=false' do
          before do
            @baptismal_certificate.baptized_catholic = false
          end

          it 'run queries' do
            expect(@baptismal_certificate.show_baptized_at_home_parish_radio).to be(true)
            expect(@baptismal_certificate.show_baptized_catholic_radio).to be(true)

            expect(@baptismal_certificate.baptized_at_home_parish_yes_checked).to be(false)
            expect(@baptismal_certificate.baptized_at_home_parish_no_checked).to be(true)
            expect(@baptismal_certificate.baptized_catholic_yes_checked).to be(false)
            expect(@baptismal_certificate.baptized_catholic_no_checked).to be(true)

            expect(@baptismal_certificate.info_show).to be(true)
            expect(@baptismal_certificate.info_show_baptized_catholic).to be(true)
            expect(@baptismal_certificate.info_show_profession_of_faith).to be(true)
          end
        end
      end
    end
  end

  describe 'validate_event_complete' do
    before do
      FactoryBot.create(:visitor)
      # Visitor.visitor('St. Mary Magdalene', 'replace me - home', 'replace me - about', 'replace me - contaclt')
      @baptismal_certificate = FactoryBot.create(:baptismal_certificate)
    end

    describe 'baptized_at_home_parish = true' do
      it 'pass validation' do
        add_address
        expect(@baptismal_certificate.validate_event_complete).to be(true)
      end

      it 'pass validation scanned_certificate' do
        add_address
        @baptismal_certificate.scanned_certificate = nil
        expect(@baptismal_certificate.validate_event_complete).to be(true)
      end

      it 'fail validation - have not chosen baptized_at_home_parish' do
        @baptismal_certificate.show_empty_radio = 0

        expect(@baptismal_certificate.validate_event_complete).to be(false)
        msgs = @baptismal_certificate.errors.full_messages
        expect(msgs[0]).to eq(I18n.t('messages.error.baptized_should_be_checked', home_parish: Visitor.home_parish))
        expect(msgs.size).to eq(1)
      end

      it 'fail validation - have not filled in fathers first name' do
        add_address
        @baptismal_certificate.father_first = ''

        expect(@baptismal_certificate.validate_event_complete).to be(false)
        msgs = @baptismal_certificate.errors.full_messages
        expect(msgs[0]).to eq("Father first can't be blank")
        expect(msgs.size).to eq(1)
      end
    end

    describe 'Baptized Catholic - baptized_at_home_parish = false baptized_cbaptized = true' do
      before do
        @baptismal_certificate = FactoryBot.create(:baptismal_certificate, setup_baptized_catholic: true)
      end

      it 'pass validation' do
        expect(@baptismal_certificate.validate_event_complete).to be(true)
      end

      it 'fail validation - have not chosen baptized_at_home_parish' do
        @baptismal_certificate.show_empty_radio = 1

        expect(@baptismal_certificate.validate_event_complete).to be(false)
        msgs = @baptismal_certificate.errors.full_messages
        expect(msgs[0]).to eq(I18n.t('messages.error.baptized_catholic_should_be_checked'))
        expect(msgs.size).to eq(1)
      end

      it 'fail validation - have not filled in fathers first name && scanned_certificate' do
        @baptismal_certificate.father_first = ''
        @baptismal_certificate.scanned_certificate = nil

        expect(@baptismal_certificate.validate_event_complete).to be(false)
        msgs = @baptismal_certificate.errors.full_messages
        expect(msgs[0]).to eq("Father first can't be blank")
        expect(msgs[1]).to eq("Scanned baptismal certificate can't be blank")
        expect(msgs.size).to eq(2)
      end

      it 'fail validation - have not filled in church name and address' do
        @baptismal_certificate.church_name = ''
        @baptismal_certificate.church_address.street_1 = ''
        @baptismal_certificate.church_address.zip_code = ''

        expect(@baptismal_certificate.validate_event_complete).to be(false)
        msgs = @baptismal_certificate.errors.full_messages
        expect(msgs[0]).to eq("Church name can't be blank")
        expect(msgs[1]).to eq("Street 1 can't be blank")
        expect(msgs[2]).to eq("Zip code can't be blank")
        expect(msgs.size).to eq(3)
      end
    end

    describe 'Profession of faith - baptized_at_home_parish = false baptized_cbaptized = false' do
      before do
        @baptismal_certificate = FactoryBot.create(:baptismal_certificate, setup_profession_of_faith: true)
      end

      it 'pass validation' do
        expect(@baptismal_certificate.validate_event_complete).to be(true)
      end

      it 'fail validation - have not chosen baptized_catholic' do
        @baptismal_certificate.show_empty_radio = 1

        expect(@baptismal_certificate.validate_event_complete).to be(false)
        msgs = @baptismal_certificate.errors.full_messages
        expect(msgs[0]).to eq(I18n.t('messages.error.baptized_catholic_should_be_checked'))
        expect(msgs.size).to eq(1)
      end

      it 'fail validation - have not filled in fathers first name && scanned_certificate' do
        @baptismal_certificate.prof_date = ''
        @baptismal_certificate.scanned_prof = nil

        expect(@baptismal_certificate.validate_event_complete).to be(false)
        msgs = @baptismal_certificate.errors.full_messages
        expect(msgs[0]).to eq(I18n.t('errors.format_blank',
                                     attribute: I18n.t('activerecord.attributes.baptismal_certificate.prof_date')))
        # rubocop:disable Layout/LineLength
        expect(msgs[1]).to eq(I18n.t('errors.format_blank', attribute: I18n.t('activerecord.attributes.baptismal_certificate.prof_picture')))
        # rubocop:enable Layout/LineLength
        expect(msgs.size).to eq(2)
      end

      it 'fail validation - have not filled in church name and address' do
        @baptismal_certificate.prof_church_name = ''
        @baptismal_certificate.prof_church_address.street_1 = ''
        @baptismal_certificate.prof_church_address.zip_code = ''

        expect(@baptismal_certificate.validate_event_complete).to be(false)
        msgs = @baptismal_certificate.errors.full_messages
        expect(msgs[0]).to eq(I18n.t('errors.format_blank',
                                     attribute: I18n.t('activerecord.attributes.baptismal_certificate.prof_church_name')))
        expect(msgs[1]).to eq(I18n.t('errors.format_blank',
                                     attribute: I18n.t('activerecord.attributes.address.street_1')))
        expect(msgs[2]).to eq(I18n.t('errors.format_blank',
                                     attribute: I18n.t('activerecord.attributes.address.zip_code')))
        expect(msgs.size).to eq(3)
      end
    end
  end

  describe 'permitted params' do
    it 'check' do
      expected = [:birth_date,
                  :baptismal_date,
                  :church_name,
                  :father_first,
                  :father_middle,
                  :father_last,
                  :mother_first,
                  :mother_middle,
                  :mother_maiden,
                  :mother_last,
                  :certificate_picture,
                  :remove_certificate_picture,
                  :baptized_catholic,
                  :prof_picture,
                  :remove_prof_picture,
                  :scanned_certificate,
                  :scanned_prof,
                  :id,
                  :baptized_at_home_parish,
                  :show_empty_radio,
                  :prof_church_name,
                  :prof_date,
                  { church_address_attributes: %i[street_1 street_2 city state zip_code id],
                    prof_church_address_attributes: %i[street_1 street_2 city state zip_code id],
                    scanned_certificate_attributes: %i[filename content_type content id],
                    scanned_prof_attributes: %i[filename content_type content id] }]

      expect(BaptismalCertificate.permitted_params).to eq(expected)
    end

    describe 'basic_validation_params' do
      it 'basic_validation_params = baptized_at_home_parish = true' do
        expected = %i[birth_date
                      baptismal_date
                      father_first
                      father_middle
                      father_last
                      mother_first
                      mother_middle
                      mother_maiden
                      mother_last
                      id
                      show_empty_radio]
        baptismal_certificate = FactoryBot.create(:baptismal_certificate)
        expect_validation_params(baptismal_certificate.basic_validation_params, expected)
      end

      it 'basic_validation_params setup_baptized_catholic' do
        expected = %i[church_name
                      scanned_certificate
                      id
                      show_empty_radio]
        baptismal_certificate = FactoryBot.create(:baptismal_certificate, setup_baptized_catholic: true)
        expect_validation_params(baptismal_certificate.baptized_catholic_validation_params, expected)
      end

      it 'basic_validation_params setup_profession_of_faith' do
        expected = %i[scanned_prof
                      id
                      show_empty_radio
                      prof_church_name
                      prof_date]
        baptismal_certificate = FactoryBot.create(:baptismal_certificate, setup_profession_of_faith: true)
        expect_validation_params(baptismal_certificate.prof_of_faith_validation_params, expected)
      end
    end

    describe 'update_baptized_catholic' do
      before do
        @baptismal_certificate = FactoryBot.create(:baptismal_certificate)
      end

      it 'baptized_at_home_parish=true' do
        @baptismal_certificate.baptized_at_home_parish = true
        expect(@baptismal_certificate.baptized_catholic).to be(false)

        @baptismal_certificate.update_baptized_catholic
        expect(@baptismal_certificate.baptized_catholic).to be(true)
      end

      it 'baptized_at_home_parish=true then canged to false' do
        @baptismal_certificate.baptized_at_home_parish = true
        expect(@baptismal_certificate.baptized_catholic).to be(false)
        @baptismal_certificate.update_baptized_catholic

        expect(@baptismal_certificate.baptized_catholic).to be(true)

        @baptismal_certificate.baptized_at_home_parish = false
        @baptismal_certificate.update_baptized_catholic

        expect(@baptismal_certificate.baptized_catholic).to be(true)
      end

      it 'baptized_at_home_parish=false' do
        @baptismal_certificate.baptized_at_home_parish = false
        expect(@baptismal_certificate.baptized_catholic).to be(false)

        @baptismal_certificate.update_baptized_catholic

        expect(@baptismal_certificate.baptized_at_home_parish).to be(false)
      end
    end
  end

  private

  def expect_validation_params(actual, expected)
    expected.each do |expected_param|
      puts(actual) unless actual.include?(expected_param)
      expect(actual.include?(expected_param)).to be(true)
      puts(actual) if actual.size != expected.size
      expect(actual.size).to eq(expected.size)
    end
  end

  def expect_baptized_at_home_parish(baptismal_certificate)
    expect(baptismal_certificate.birth_date.to_s).to match '1983-08-20'
    expect(baptismal_certificate.baptismal_date.to_s).to match '1983-10-20'
    expect(baptismal_certificate.father_first).to match 'George'
    expect(baptismal_certificate.father_middle).to match 'Paul'
    expect(baptismal_certificate.father_last).to match 'Smith'
    expect(baptismal_certificate.mother_first).to match 'Georgette'
    expect(baptismal_certificate.mother_middle).to match 'Paula'
    expect(baptismal_certificate.mother_maiden).to match 'Kirk'
    expect(baptismal_certificate.mother_last).to match 'Smith'
  end

  def expect_baptized_catholic(baptismal_certificate, with_values)
    expect(baptismal_certificate.church_name).to match with_values ? 'St. Micheals' : ''
    expect(baptismal_certificate.church_address.street_1).to match with_values ? '1313 High House' : ''
    expect(baptismal_certificate.church_address.street_2).to match with_values ? 'Apt 123' : ''
    expect(baptismal_certificate.church_address.city).to match with_values ? 'Cary' : ''
    expect(baptismal_certificate.church_address.state).to match with_values ? 'NC' : ''
    expect(baptismal_certificate.church_address.zip_code).to match with_values ? '27506' : ''
  end

  def expect_profession_of_faith(baptismal_certificate, with_values)
    expect(baptismal_certificate.baptized_at_home_parish).to be(false)
    expect(baptismal_certificate.baptized_catholic).to be(false)
    expect(baptismal_certificate.show_empty_radio).to eq(2)
    expect(baptismal_certificate.prof_date.to_s).to match with_values ? '1990-10-20' : ''
    expect(baptismal_certificate.prof_church_name).to match with_values ? 'St. Anthonys' : ''
    expect(baptismal_certificate.prof_church_address.street_1).to match with_values ? '1313 Sherwood' : ''
    expect(baptismal_certificate.prof_church_address.street_2).to match with_values ? 'Apt 123' : ''
    expect(baptismal_certificate.prof_church_address.city).to match with_values ? 'Clarksville' : ''
    expect(baptismal_certificate.prof_church_address.state).to match with_values ? 'IN' : ''
    expect(baptismal_certificate.prof_church_address.zip_code).to match with_values ? '47130' : ''
  end

  def expect_verifiables(expected_verifiables, actual_verifiables)
    expected_verifiables.each_pair do |key, value|
      expect(actual_verifiables[key]).to eq(value),
                                         "key(#{key}) mismatch actual value(#{actual_verifiables[key]}) expected value(#{value})"
    end
    expect(expected_verifiables.size).to eq(actual_verifiables.size)
  end

  def expected_verifiable_baptized_at_home_parish
    {
      Birthday: Date.parse('1983-08-20'),
      'Baptismal date': Date.parse('1983-10-20'),
      'Father\'s name': 'George Paul Smith',
      'Mother\'s name': 'Georgette Paula Kirk Smith'
    }
  end

  def expected_verifiables_baptized_catholic
    {
      Church: 'St. Micheals',
      Street: '1313 High House',
      'Street 2': 'Apt 123',
      City: 'Cary',
      State: 'NC',
      'Zip Code': '27506'
    }
  end

  def add_address
    @baptismal_certificate.church_address.street_1 = 'st1'
    @baptismal_certificate.church_address.city = 'city'
    @baptismal_certificate.church_address.state = 'OH'
    @baptismal_certificate.church_address.zip_code = '12345'
  end
end
