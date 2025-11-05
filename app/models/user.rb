class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { buyer: 0, agent: 1, admin: 2 }

  has_many :notifications, dependent: :destroy
  belongs_to :person, optional: true

  # cria automaticamente uma Person associada após criar o User (se ainda não houver)
  after_create :ensure_person_exists

  def display_name
    name.presence || email
  end

  private

  def ensure_person_exists
    return if person.present?

    person_attrs = {
      name: (name.presence || email),
      email: (email.presence || nil)
    }

    p = Person.new(person_attrs)
    if p.save
      # evita callbacks adicionais ao apenas gravar o id
      update_column(:person_id, p.id)
    else
      Rails.logger.warn("Failed to create Person for User##{id}: #{p.errors.full_messages.join('; ')}")
    end
  end
end
