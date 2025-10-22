FactoryBot.define do
  factory :property_photo do
    association :property
    sequence(:position) { |n| n }
  end
end
