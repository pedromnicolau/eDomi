FactoryBot.define do
  factory :notification do
    association :user
    title { "Aviso" }
    body { "Corpo da notificação" }
    read { false }
  end
end
