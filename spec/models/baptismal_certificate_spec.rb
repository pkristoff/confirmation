# frozen_string_literal: true

require 'rails_helper'

describe BaptismalCertificate, type: :model do
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
    describe '..._yes_checked & ..._no_checked ' do
      it 'baptized_at_home_parish not chosen false' do
        baptismal_certificate = FactoryBot.create(:baptismal_certificate)
        baptismal_certificate.baptized_at_home_parish = false
        baptismal_certificate.baptized_catholic = false
        baptismal_certificate.show_empty_radio = 0

        expect(baptismal_certificate.baptized_at_home_parish_yes_checked).to eq(false)
        expect(baptismal_certificate.baptized_at_home_parish_no_checked).to eq(false)
        expect(baptismal_certificate.baptized_catholic_yes_checked).to eq(false)
        expect(baptismal_certificate.baptized_catholic_no_checked).to eq(false)

        expect(baptismal_certificate.info_show).to eq(false)
        expect(baptismal_certificate.show_baptized_catholic_radio).to eq(false)
        expect(baptismal_certificate.info_show_baptized_catholic).to eq(false)
        expect(baptismal_certificate.info_show_profession_of_faith).to eq(false)
      end

      it 'baptized_at_home_parish not chosen true' do
        baptismal_certificate = FactoryBot.create(:baptismal_certificate)
        baptismal_certificate.baptized_at_home_parish = true
        baptismal_certificate.baptized_catholic = false
        baptismal_certificate.show_empty_radio = 0

        expect(baptismal_certificate.baptized_at_home_parish_yes_checked).to eq(false)
        expect(baptismal_certificate.baptized_at_home_parish_no_checked).to eq(false)
        expect(baptismal_certificate.baptized_catholic_yes_checked).to eq(false)
        expect(baptismal_certificate.baptized_catholic_no_checked).to eq(false)

        expect(baptismal_certificate.info_show).to eq(false)
        expect(baptismal_certificate.show_baptized_catholic_radio).to eq(false)
        expect(baptismal_certificate.info_show_baptized_catholic).to eq(false)
        expect(baptismal_certificate.info_show_profession_of_faith).to eq(false)
      end

      it 'baptized_at_home_parish chosen true' do
        baptismal_certificate = FactoryBot.create(:baptismal_certificate)
        baptismal_certificate.baptized_at_home_parish = true
        baptismal_certificate.baptized_catholic = false
        baptismal_certificate.show_empty_radio = 1

        expect(baptismal_certificate.baptized_at_home_parish_yes_checked).to eq(true)
        expect(baptismal_certificate.baptized_at_home_parish_no_checked).to eq(false)
        expect(baptismal_certificate.baptized_catholic_yes_checked).to eq(false)
        expect(baptismal_certificate.baptized_catholic_no_checked).to eq(false)

        expect(baptismal_certificate.info_show).to eq(true)
        expect(baptismal_certificate.show_baptized_catholic_radio).to eq(false)
        expect(baptismal_certificate.info_show_baptized_catholic).to eq(false)
        expect(baptismal_certificate.info_show_profession_of_faith).to eq(false)
      end

      it 'baptized_at_home_parish chosen false' do
        baptismal_certificate = FactoryBot.create(:baptismal_certificate)
        baptismal_certificate.baptized_at_home_parish = false
        baptismal_certificate.baptized_catholic = false
        baptismal_certificate.show_empty_radio = 1

        expect(baptismal_certificate.baptized_at_home_parish_yes_checked).to eq(false)
        expect(baptismal_certificate.baptized_at_home_parish_no_checked).to eq(true)
        expect(baptismal_certificate.baptized_catholic_yes_checked).to eq(false)
        expect(baptismal_certificate.baptized_catholic_no_checked).to eq(false)

        expect(baptismal_certificate.info_show).to eq(true)
        expect(baptismal_certificate.show_baptized_catholic_radio).to eq(true)
        expect(baptismal_certificate.info_show_baptized_catholic).to eq(false)
        expect(baptismal_certificate.info_show_profession_of_faith).to eq(false)
      end

      it 'baptized_catholic chosen true' do
        baptismal_certificate = FactoryBot.create(:baptismal_certificate)
        baptismal_certificate.baptized_at_home_parish = false
        baptismal_certificate.baptized_catholic = true
        baptismal_certificate.show_empty_radio = 2

        expect(baptismal_certificate.baptized_at_home_parish_yes_checked).to eq(false)
        expect(baptismal_certificate.baptized_at_home_parish_no_checked).to eq(true)
        expect(baptismal_certificate.baptized_catholic_yes_checked).to eq(true)
        expect(baptismal_certificate.baptized_catholic_no_checked).to eq(false)

        expect(baptismal_certificate.info_show).to eq(true)
        expect(baptismal_certificate.show_baptized_catholic_radio).to eq(true)
        expect(baptismal_certificate.info_show_baptized_catholic).to eq(true)
        expect(baptismal_certificate.info_show_profession_of_faith).to eq(false)
      end

      it 'baptized_catholic chosen false' do
        baptismal_certificate = FactoryBot.create(:baptismal_certificate)
        baptismal_certificate.baptized_at_home_parish = false
        baptismal_certificate.baptized_catholic = false
        baptismal_certificate.show_empty_radio = 2

        expect(baptismal_certificate.baptized_at_home_parish_yes_checked).to eq(false)
        expect(baptismal_certificate.baptized_at_home_parish_no_checked).to eq(true)
        expect(baptismal_certificate.baptized_catholic_yes_checked).to eq(false)
        expect(baptismal_certificate.baptized_catholic_no_checked).to eq(true)

        expect(baptismal_certificate.info_show).to eq(true)
        expect(baptismal_certificate.show_baptized_catholic_radio).to eq(true)
        expect(baptismal_certificate.info_show_baptized_catholic).to eq(true)
        expect(baptismal_certificate.info_show_profession_of_faith).to eq(true)
      end
    end
  end

  describe 'validate_event_complete' do
    before(:each) do
      Visitor.visitor('St. Mary Magdalene', 'replace me - home', 'replace me - about', 'replace me - contaclt')
      @baptismal_certificate = FactoryBot.create(:baptismal_certificate)
    end
    describe 'baptized_at_home_parish = true' do
      it 'pass validation' do
        expect(@baptismal_certificate.validate_event_complete).to eq(true)
      end
      it 'pass validation scanned_certificate' do
        @baptismal_certificate.scanned_certificate = nil
        expect(@baptismal_certificate.validate_event_complete).to eq(true)
      end
      it 'should fail validation - have not chosen baptized_at_home_parish' do
        @baptismal_certificate.show_empty_radio = 0

        expect(@baptismal_certificate.validate_event_complete).to eq(false)
        msgs = @baptismal_certificate.errors.full_messages
        expect(msgs[0]).to eq(I18n.t('messages.error.baptized_should_be_checked', home_parish: Visitor.home_parish))
        expect(msgs.size).to eq(1)
      end
      it 'should fail validation - have not filled in fathers first name' do
        @baptismal_certificate.father_first = ''

        expect(@baptismal_certificate.validate_event_complete).to eq(false)
        msgs = @baptismal_certificate.errors.full_messages
        expect(msgs[0]).to eq("Father first can't be blank")
        expect(msgs.size).to eq(1)
      end
    end
    describe 'Baptized Catholic - baptized_at_home_parish = false baptized_cbaptized = true' do
      before(:each) do
        @baptismal_certificate = FactoryBot.create(:baptismal_certificate, setup_baptized_catholic: true)
      end
      it 'pass validation' do
        expect(@baptismal_certificate.validate_event_complete).to eq(true)
      end
      it 'should fail validation - have not chosen baptized_at_home_parish' do
        @baptismal_certificate.show_empty_radio = 1

        expect(@baptismal_certificate.validate_event_complete).to eq(false)
        msgs = @baptismal_certificate.errors.full_messages
        expect(msgs[0]).to eq(I18n.t('messages.error.baptized_catholic_should_be_checked'))
        expect(msgs.size).to eq(1)
      end
      it 'should fail validation - have not filled in fathers first name && scanned_certificate' do
        @baptismal_certificate.father_first = ''
        @baptismal_certificate.scanned_certificate = nil

        expect(@baptismal_certificate.validate_event_complete).to eq(false)
        msgs = @baptismal_certificate.errors.full_messages
        expect(msgs[0]).to eq("Father first can't be blank")
        expect(msgs[1]).to eq("Scanned baptismal certificate can't be blank")
        expect(msgs.size).to eq(2)
      end
      it 'should fail validation - have not filled in church nsme snd address' do
        @baptismal_certificate.church_name = ''
        @baptismal_certificate.church_address.street_1 = ''
        @baptismal_certificate.church_address.zip_code = ''

        expect(@baptismal_certificate.validate_event_complete).to eq(false)
        msgs = @baptismal_certificate.errors.full_messages
        expect(msgs[0]).to eq("Church name can't be blank")
        expect(msgs[1]).to eq("Street 1 can't be blank")
        expect(msgs[2]).to eq("Zip code can't be blank")
        expect(msgs.size).to eq(3)
      end
    end
    describe 'Profession of faith - baptized_at_home_parish = false baptized_cbaptized = false' do
      before(:each) do
        @baptismal_certificate = FactoryBot.create(:baptismal_certificate, setup_profession_of_faith: true)
      end
      it 'pass validation' do
        expect(@baptismal_certificate.validate_event_complete).to eq(true)
      end
      it 'should fail validation - have not chosen baptized_catholic' do
        @baptismal_certificate.show_empty_radio = 1

        expect(@baptismal_certificate.validate_event_complete).to eq(false)
        msgs = @baptismal_certificate.errors.full_messages
        expect(msgs[0]).to eq(I18n.t('messages.error.baptized_catholic_should_be_checked'))
        expect(msgs.size).to eq(1)
      end
      it 'should fail validation - have not filled in fathers first name && scanned_certificate' do
        @baptismal_certificate.prof_date = ''
        @baptismal_certificate.scanned_prof = nil

        expect(@baptismal_certificate.validate_event_complete).to eq(false)
        msgs = @baptismal_certificate.errors.full_messages
        expect(msgs[0]).to eq("Prof date can't be blank")
        expect(msgs[1]).to eq("Scanned Profession 0f faith can't be blank")
        expect(msgs.size).to eq(2)
      end
      it 'should fail validation - have not filled in church name snd address' do
        @baptismal_certificate.prof_church_name = ''
        @baptismal_certificate.prof_church_address.street_1 = ''
        @baptismal_certificate.prof_church_address.zip_code = ''

        expect(@baptismal_certificate.validate_event_complete).to eq(false)
        msgs = @baptismal_certificate.errors.full_messages
        expect(msgs[0]).to eq("Prof church name can't be blank")
        expect(msgs[1]).to eq("Street 1 can't be blank")
        expect(msgs[2]).to eq("Zip code can't be blank")
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
        expect_basic_validation_params(baptismal_certificate.basic_validation_params, expected)
      end
      it 'basic_validation_params setup_baptized_catholic' do
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
                      show_empty_radio
                      church_name
                      scanned_certificate]
        baptismal_certificate = FactoryBot.create(:baptismal_certificate, setup_baptized_catholic: true)
        expect_basic_validation_params(baptismal_certificate.basic_validation_params, expected)
      end
      it 'basic_validation_params setup_profession_of_faith' do
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
                      show_empty_radio
                      church_name
                      scanned_certificate
                      scanned_prof
                      prof_church_name
                      prof_date]
        baptismal_certificate = FactoryBot.create(:baptismal_certificate, setup_profession_of_faith: true)
        expect_basic_validation_params(baptismal_certificate.basic_validation_params, expected)
      end
    end
  end

  private

  def expect_basic_validation_params(actual, expected)
    expected.each do |expected_param|
      expect(actual.include?(expected_param)).to eq(true)
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
    expect(baptismal_certificate.baptized_at_home_parish).to eq(false)
    expect(baptismal_certificate.baptized_catholic).to eq(false)
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
end
