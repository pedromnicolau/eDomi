class Person < ApplicationRecord
  has_many :addresses, as: :addressable, dependent: :destroy
  belongs_to :assigned_agent, class_name: "User", optional: true, foreign_key: "assigned_agent_id"

  enum :status, { prospect: 0, client: 1, inactive: 2 }
  enum :preferred_contact_method, { phone: 0, email: 1, whatsapp: 2 }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, allow_blank: false

  def assigned_agent_name
    assigned_agent&.name
  end
end
