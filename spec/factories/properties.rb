FactoryBot.define do
  factory :property do
    title { "Sample Property" }
    description { "Nice place" }
    price { 100_000.00 }
    property_type { :house }
    area { nil }
    bedrooms { 0 }
    bathrooms { 0 }
    parking_spaces { 0 }
    furnished { false }
    condominium_fee { 0.0 }
    iptu { 0.0 }
    year_built { nil }
    address { "Rua Exemplo, 123" }
    neighborhood { "Centro" }
    city { "Cidade" }
    state { "SP" }
    zip_code { nil }
    status { :available }
    association :agent, factory: :user
  end
end
