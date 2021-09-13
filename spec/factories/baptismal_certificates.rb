# frozen_string_literal: true

FactoryBot.define do
  factory :baptismal_certificate do
    transient do
      skip_address_replacement { false }
      setup_baptized_catholic { false }
    end
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
    after(:build) do |baptismal_certificate, evaluator|
      unless evaluator.skip_address_replacement
        # replace baptismal_certificate
        baptismal_certificate.church_address = FactoryBot.create(
          :address,
          street_1: '1313 Magdalene Way',
          street_2: 'Apt. 456',
          city: 'Apex',
          state: 'NC',
          zip_code: '27502'
        )
      end

      # should be optional when baptized at home parish
      baptismal_certificate.scanned_certificate =
        FactoryBot.create(:scanned_image, filename: 'actions.png', content_type: 'image/png', content: 'vvv')

      if evaluator.setup_baptized_catholic
        baptismal_certificate.baptized_at_home_parish = false
        baptismal_certificate.baptized_catholic = true
        baptismal_certificate.show_empty_radio = 2
        baptismal_certificate.church_name = 'St. Micheals'
        baptismal_certificate.church_address = FactoryBot.create(
          :address,
          street_1: '1313 High House',
          street_2: '',
          city: 'Cary',
          state: 'NC',
          zip_code: '27502'
        )
        baptismal_certificate.show_empty_radio = 2
      end
    end
  end
end
