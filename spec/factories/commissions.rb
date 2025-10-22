FactoryBot.define do
  factory :commission do
    association :sale
    association :agent, factory: :user
    percentage { 5.0 }
    value { 2500.0 }
    paid { false }
    paid_at { nil }
    after(:build) do |commission|
      # se agent não informado, usar agent da sale
      commission.agent ||= commission.sale.agent if commission.sale
    end
  end
end
