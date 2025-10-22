class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { buyer: 0, agent: 1, admin: 2 }

  has_many :notifications, dependent: :destroy

  def display_name
    name.presence || email
  end
end
