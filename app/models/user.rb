class User < ApplicationRecord
  # Devise
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { admin: 0, agent: 1, buyer: 2 }

  has_many :properties, foreign_key: :agent_id, dependent: :nullify
  has_many :visits_as_buyer, class_name: "Visit", foreign_key: :buyer_id, dependent: :nullify
  has_many :visits_as_agent, class_name: "Visit", foreign_key: :agent_id, dependent: :nullify
  has_many :sales_as_agent, class_name: "Sale", foreign_key: :agent_id, dependent: :nullify
  has_many :sales_as_buyer, class_name: "Sale", foreign_key: :buyer_id, dependent: :nullify
  has_many :commissions, foreign_key: :agent_id, dependent: :nullify
  has_many :notifications, dependent: :destroy

  has_one_attached :avatar
end
