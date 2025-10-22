FactoryBot.define do
  factory :visit do
    association :property
    association :buyer, factory: :user
    association :agent, factory: :user
    scheduled_at { 1.day.from_now }
    status { :pending }
    notes { nil }
    after(:build) do |visit|
      visit.agent ||= visit.property.agent if visit.property
    end
  end
end
