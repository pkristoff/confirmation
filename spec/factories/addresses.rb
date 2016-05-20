FactoryGirl.define do
  factory :address do
    street_1 "2120 Frissell Ave."
    street_2 "Apt. 456"
    city "Apex"
    state "NC"
    zip_code "27502"

    # after(:build) do |address|
    #   address.candidate ||= FactoryGirl.create(:candidate, address: address)
    # end
  end
end
