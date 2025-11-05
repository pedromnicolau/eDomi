class Person < ApplicationRecord
  has_many :addresses, as: :addressable, dependent: :destroy
  belongs_to :assigned_agent, class_name: "User", optional: true, foreign_key: "assigned_agent_id"
  has_one :user, dependent: :nullify

  enum :status, { prospect: 0, client: 1, inactive: 2 }
  enum :preferred_contact_method, { phone: 0, email: 1, whatsapp: 2 }

  validates :name, presence: true
  validates :email, uniqueness: true, allow_blank: true, format: { with: URI::MailTo::EMAIL_REGEXP }, if: -> { email.present? }

  before_validation :strip_whitespace

  def assigned_agent_name
    assigned_agent&.name
  end

  private

  def strip_whitespace
    self.name = name.strip if name.present?
    self.email = email.strip.downcase if email.present?
  end
end
