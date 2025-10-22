FactoryBot.define do
  factory :sale do
    association :property
    association :agent, factory: :user
    association :buyer, factory: :user
    sale_price { 50_000.00 }
    sale_date { Date.today }
    after(:build) do |sale|
      # se agent não informado, usar agent da property
      sale.agent ||= sale.property.agent if sale.property
    end
  end
end
