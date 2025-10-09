class Visit < ApplicationRecord
  enum :status, { pending: 0, confirmed: 1, completed: 2, cancelled: 3 }

  belongs_to :property
  belongs_to :buyer, class_name: "User", foreign_key: :buyer_id
  belongs_to :agent, class_name: "User", foreign_key: :agent_id

  validates :scheduled_at, presence: true
end
