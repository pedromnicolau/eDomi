class Commission < ApplicationRecord
  # associations
  belongs_to :sale
  belongs_to :agent, class_name: "User"

  # ensure associations present so validation errors are populated as expected
  validates :sale, presence: true
  validates :agent, presence: true

  # validations
  validates :percentage,
            presence: true,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  validates :value,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }

  # ensure one commission per agent per sale
  validates :agent_id, uniqueness: { scope: :sale_id }
end
