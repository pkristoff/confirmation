FactoryGirl.define do
  factory :baptismal_certificate do
    birth_date '1983-08-20'
    baptismal_date '1983-10-20'
    church_name 'St. Francis'
    father_first 'George'
    father_last 'Smith'
    father_middle 'Paul'
    mother_first 'Georgette'
    mother_middle 'Paula'
    mother_maiden 'Kirk'
    mother_last 'Smith'
    after(:build) do |baptismal_certificate|
      # replace baptismal_certificate
      baptismal_certificate.church_address = FactoryGirl.create(
          :address,
          street_1: '1313 Magdalene Way',
          street_2: 'Apt. 456',
          city: 'Apex',
          state: 'NC',
          zip_code: '27502',
      )
      baptismal_certificate.scanned_certificate = FactoryGirl.create(:scanned_image, filename: 'actions.png', content_type: 'image/png', content: 'vvv')
    end
  end
end
