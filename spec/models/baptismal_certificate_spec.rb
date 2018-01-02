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
      candidate = FactoryBot.create(:candidate, baptized_at_stmm: false)
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
      candidate = FactoryBot.create(:candidate, baptized_at_stmm: true)
      verifiables = FactoryBot.create(:baptismal_certificate).verifiable_info(candidate)
      expected_verifiables = {
          Church: I18n.t('home_parish.name')
      }
      expect(verifiables).to eq(expected_verifiables)
    end
end
