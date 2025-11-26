FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password" }
    password_confirmation { "password" }
    name { "Test User" }
    role { :buyer }
    phone { "11987654321" }
  end
end
