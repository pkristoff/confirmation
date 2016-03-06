FactoryGirl.define do
  factory :admin, class: Admin do
    name "Admin User"
    email "test@example.com"
    password "please123"
  end
end
