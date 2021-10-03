# frozen_string_literal: true

FactoryBot.define do
  factory :baptismal_certificate do
    transient do
      skip_address_replacement { false }
      setup_baptized_catholic { false }
      setup_profession_of_faith { false }
    end
    baptized_at_home_parish { true }
    birth_date { '1983-08-20' }
    baptismal_date { '1983-10-20' }
    church_name { 'St. Francis' }
    father_first { 'George' }
    father_last { 'Smith' }
    father_middle { 'Paul' }
    mother_first { 'Georgette' }
    mother_middle { 'Paula' }
    mother_maiden { 'Kirk' }
    mother_last { 'Smith' }
    show_empty_radio { 1 }
    after(:build) do |baptismal_certificate, evaluator|
      # should be optional when baptized at home parish
      baptismal_certificate.scanned_certificate =
        FactoryBot.create(:scanned_image, filename: 'actions.png', content_type: 'image/png', content: 'vvv')
      baptized_catholic(baptismal_certificate) if evaluator.setup_baptized_catholic

      if evaluator.setup_profession_of_faith
        baptized_catholic(baptismal_certificate)
        baptismal_certificate.baptized_at_home_parish = false
        baptismal_certificate.baptized_catholic = false
        baptismal_certificate.show_empty_radio = 2
        baptismal_certificate.prof_church_name = 'St. Anthonys'
        baptismal_certificate.prof_date = '1990-10-20'
        baptismal_certificate.prof_church_address = FactoryBot.create(
          :address,
          street_1: '1313 Sherwood',
          street_2: 'Apt 123',
          city: 'Clarksville',
          state: 'IN',
          zip_code: '47130'
        )
        baptismal_certificate.scanned_prof =
          FactoryBot.create(:scanned_image, filename: 'actions.png', content_type: 'image/png', content: 'vvv')
      end
    end
  end
end

private

def baptized_catholic(baptismal_certificate)
  baptismal_certificate.baptized_at_home_parish = false
  baptismal_certificate.baptized_catholic = true
  baptismal_certificate.show_empty_radio = 2
  baptismal_certificate.church_name = 'St. Micheals'
  baptismal_certificate.church_address = FactoryBot.create(
    :address,
    street_1: '1313 High House',
    street_2: 'Apt 123',
    city: 'Cary',
    state: 'NC',
    zip_code: '27506'
  )
end
