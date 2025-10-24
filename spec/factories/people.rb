FactoryBot.define do
  factory :person do
    name { "Fulano de Tal" }
    sequence(:email) { |n| "person#{n}@example.com" }
    phone { "11999990000" }
    birthdate { 30.years.ago.to_date }
    status { :prospect }
    preferred_contact_method { :phone }
    notes { "Interessado em imóveis na região sul." }
    active { true }
  end
end
