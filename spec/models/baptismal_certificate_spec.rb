# frozen_string_literal: true

require 'rails_helper'

describe BaptismalCertificate, type: :model do
  describe 'church_address' do
    it 'can retrieve a candiadate\'s address' do
      baptismal_certificate = FactoryBot.create(:baptismal_certificate)
      expect(baptismal_certificate.birth_date.to_s).to match '1983-08-20'
      expect(baptismal_certificate.baptismal_date.to_s).to match '1983-10-20'
      expect(baptismal_certificate.church_name).to match 'St. Francis'
      expect(baptismal_certificate.father_first).to match 'George'
      expect(baptismal_certificate.father_middle).to match 'Paul'
      expect(baptismal_certificate.father_last).to match 'Smith'
      expect(baptismal_certificate.mother_first).to match 'Georgette'
      expect(baptismal_certificate.mother_middle).to match 'Paula'
      expect(baptismal_certificate.mother_maiden).to match 'Kirk'
      expect(baptismal_certificate.mother_last).to match 'Smith'

      expect(baptismal_certificate.church_address.street_1).to match '1313 Magdalene Way'
      expect(baptismal_certificate.church_address.street_2).to match 'Apt. 456'
      expect(baptismal_certificate.church_address.city).to match 'Apex'
      expect(baptismal_certificate.church_address.state).to match 'NC'
      expect(baptismal_certificate.church_address.zip_code).to match '27502'
    end
  end

  describe 'event completion attributes' do
    it 'should return a hash of :attribute => value' do
      candidate = FactoryBot.create(:candidate)
      candidate.baptismal_certificate.baptized_at_home_parish = false
      verifiables = FactoryBot.create(:baptismal_certificate).verifiable_info(candidate)
      expected_verifiables = {
        Birthday: Date.parse('1983-08-20'),
        'Baptismal date': Date.parse('1983-10-20'),
        'Father\'s name': 'George Paul Smith',
        'Mother\'s name': 'Georgette Paula Kirk Smith',
        Church: 'St. Francis',
        Street: '1313 Magdalene Way',
        'Street 2': 'Apt. 456',
        City: 'Apex',
        State: 'NC',
        'Zip Code': '27502'
      }
      expect(verifiables).to eq(expected_verifiables)
    end
  end

  it 'should return a hash of :attribute => value' do
    candidate = FactoryBot.create(:candidate)
    candidate.baptismal_certificate.baptized_at_home_parish = true
    verifiables = FactoryBot.create(:baptismal_certificate).verifiable_info(candidate)
    expected_verifiables = {
      Church: Visitor.home_parish
    }
    expect(verifiables).to eq(expected_verifiables)
  end

  describe 'show check and divs' do
    describe 'baptized_at_home_parish_show_yes' do
      it 'should not show yes if has_chosen_baptized_at_home_parish has not happend: false 0' do
        baptismal_certificate = FactoryBot.create(:baptismal_certificate)
        baptismal_certificate.baptized_at_home_parish = false
        baptismal_certificate.show_empty_radio = 0

        expect(baptismal_certificate.baptized_at_home_parish_show_yes).to eq(false)
      end

      it 'should not show yes if has_chosen_baptized_at_home_parish has not happend: true 0' do
        baptismal_certificate = FactoryBot.create(:baptismal_certificate)
        baptismal_certificate.baptized_at_home_parish = true
        baptismal_certificate.show_empty_radio = 0

        expect(baptismal_certificate.baptized_at_home_parish_show_yes).to eq(false)
      end

      it 'should not show yes if has_chosen_baptized_at_home_parish has not happend: false 1' do
        baptismal_certificate = FactoryBot.create(:baptismal_certificate)
        baptismal_certificate.baptized_at_home_parish = false
        baptismal_certificate.show_empty_radio = 1

        expect(baptismal_certificate.baptized_at_home_parish_show_yes).to eq(false)
      end

      it 'should show yes if has_chosen_baptized_at_home_parish has not happend: true 1' do
        baptismal_certificate = FactoryBot.create(:baptismal_certificate)
        baptismal_certificate.baptized_at_home_parish = true
        baptismal_certificate.show_empty_radio = 1

        expect(baptismal_certificate.baptized_at_home_parish_show_yes).to eq(true)
      end
    end

    describe 'baptized_at_home_parish_show_no' do
      it 'should not show no if has_chosen_baptized_at_home_parish has not happend: false 0' do
        baptismal_certificate = FactoryBot.create(:baptismal_certificate)
        baptismal_certificate.baptized_at_home_parish = false
        baptismal_certificate.show_empty_radio = 0

        expect(baptismal_certificate.baptized_at_home_parish_show_no).to eq(false)
      end

      it 'should not show no if has_chosen_baptized_at_home_parish has not happend: true 0' do
        baptismal_certificate = FactoryBot.create(:baptismal_certificate)
        baptismal_certificate.baptized_at_home_parish = true
        baptismal_certificate.show_empty_radio = 0

        expect(baptismal_certificate.baptized_at_home_parish_show_no).to eq(false)
      end

      it 'should show no if has_chosen_baptized_at_home_parish has not happend: false 1' do
        baptismal_certificate = FactoryBot.create(:baptismal_certificate)
        baptismal_certificate.baptized_at_home_parish = false
        baptismal_certificate.show_empty_radio = 1

        expect(baptismal_certificate.baptized_at_home_parish_show_no).to eq(true)
      end

      it 'should not show no if has_chosen_baptized_at_home_parish has not happend: true 1' do
        baptismal_certificate = FactoryBot.create(:baptismal_certificate)
        baptismal_certificate.baptized_at_home_parish = true
        baptismal_certificate.show_empty_radio = 1

        expect(baptismal_certificate.baptized_at_home_parish_show_no).to eq(false)
      end
    end

    describe 'first_comm_show' do
      it 'should not show: false 0' do
        baptismal_certificate = FactoryBot.create(:baptismal_certificate)
        baptismal_certificate.baptized_at_home_parish = false
        baptismal_certificate.show_empty_radio = 0

        expect(baptismal_certificate.first_comm_show).to eq(false)
      end

      it 'should not show: true 0' do
        baptismal_certificate = FactoryBot.create(:baptismal_certificate)
        baptismal_certificate.baptized_at_home_parish = true
        baptismal_certificate.show_empty_radio = 0

        expect(baptismal_certificate.first_comm_show).to eq(false)
      end

      it 'should show: false 1' do
        baptismal_certificate = FactoryBot.create(:baptismal_certificate)
        baptismal_certificate.baptized_at_home_parish = false
        baptismal_certificate.show_empty_radio = 1

        expect(baptismal_certificate.first_comm_show).to eq(true)
      end

      it 'should not show: true 1' do
        baptismal_certificate = FactoryBot.create(:baptismal_certificate)
        baptismal_certificate.baptized_at_home_parish = true
        baptismal_certificate.show_empty_radio = 1

        expect(baptismal_certificate.first_comm_show).to eq(false)
      end
    end

    describe 'info_show' do
      it 'should show: true' do
        baptismal_certificate = FactoryBot.create(:baptismal_certificate)
        baptismal_certificate.baptized_at_home_parish = true
        baptismal_certificate.show_empty_radio = 1

        expect(baptismal_certificate.info_show).to eq(false)
      end

      it 'should show: true' do
        baptismal_certificate = FactoryBot.create(:baptismal_certificate)
        baptismal_certificate.baptized_at_home_parish = false
        baptismal_certificate.show_empty_radio = 2

        baptismal_certificate.first_comm_at_home_parish = true

        expect(baptismal_certificate.info_show).to eq(true)
      end

      it 'should show: true' do
        baptismal_certificate = FactoryBot.create(:baptismal_certificate)
        baptismal_certificate.baptized_at_home_parish = false
        baptismal_certificate.show_empty_radio = 2

        baptismal_certificate.first_comm_at_home_parish = false

        expect(baptismal_certificate.info_show).to eq(true)
      end
    end
  end
  describe 'validate_event_complete' do
    before(:each) do
      Visitor.visitor('St. Mary Magdalene', 'replace me - home', 'replace me - about', 'replace me - contaclt')
    end
    it 'should fail validation - new baptismal_certificate validated' do
      baptismal_certificate = FactoryBot.create(:baptismal_certificate)

      expect(baptismal_certificate.validate_event_complete).to eq(false)
      msgs = baptismal_certificate.errors.full_messages
      expect(msgs[0]).to eq('I was Baptized at St. Mary Magdalene should be checked.')
      expect(msgs.size).to eq(1)
    end

    it 'should pass validation - user selects Yes and saves' do
      baptismal_certificate = FactoryBot.create(:baptismal_certificate)
      baptismal_certificate.baptized_at_home_parish = true
      baptismal_certificate.show_empty_radio = 1

      expect(baptismal_certificate.validate_event_complete).to eq(true)
      msgs = baptismal_certificate.errors.full_messages
      expect(msgs.size).to eq(0)
    end
    it 'should fail validation - user selects No and saves' do
      baptismal_certificate = FactoryBot.create(:baptismal_certificate)
      baptismal_certificate.baptized_at_home_parish = false
      baptismal_certificate.show_empty_radio = 1

      expect(baptismal_certificate.validate_event_complete).to eq(false)
      msgs = baptismal_certificate.errors.full_messages
      expect(msgs[0]).to eq('I received First Communion at St. Mary Magdalene should be checked.')
      expect(msgs.size).to eq(1)
    end
    it 'should pass validation - user selects No, Yes and saves' do
      baptismal_certificate = FactoryBot.create(:baptismal_certificate)
      baptismal_certificate.baptized_at_home_parish = false
      baptismal_certificate.first_comm_at_home_parish = true
      baptismal_certificate.show_empty_radio = 2

      expect(baptismal_certificate.validate_event_complete).to eq(true)
      msgs = baptismal_certificate.errors.full_messages
      expect(msgs.size).to eq(0)
    end
    it 'should pass validation - user selects No, No and saves' do
      baptismal_certificate = FactoryBot.create(:baptismal_certificate)
      baptismal_certificate.baptized_at_home_parish = false
      baptismal_certificate.first_comm_at_home_parish = false
      baptismal_certificate.show_empty_radio = 2

      expect(baptismal_certificate.validate_event_complete).to eq(true)
      msgs = baptismal_certificate.errors.full_messages
      expect(msgs.size).to eq(0)
    end
    it 'should fail validation - user selects No, No, removes mother_first and saves' do
      baptismal_certificate = FactoryBot.create(:baptismal_certificate)
      baptismal_certificate.baptized_at_home_parish = false
      baptismal_certificate.first_comm_at_home_parish = false
      baptismal_certificate.show_empty_radio = 2
      baptismal_certificate.mother_first = ''

      expect(baptismal_certificate.validate_event_complete).to eq(true)
      msgs = baptismal_certificate.errors.full_messages
      expect(msgs[0]).to eq("Mother first can't be blank")
      expect(msgs.size).to eq(1)
    end
  end

  it 'check permitted_params' do
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
                :scanned_certificate,
                :id,
                :baptized_at_home_parish,
                :first_comm_at_home_parish,
                :show_empty_radio,
                { church_address_attributes: %i[street_1 street_2 city state zip_code id],
                  scanned_certificate_attributes: %i[filename content_type content id] }]
    expect(BaptismalCertificate.permitted_params).to eq(expected)
  end
end
