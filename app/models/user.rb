class User < ApplicationRecord
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
    devise :database_authenticatable, :registerable,
      :recoverable, :rememberable, :validatable,
      :omniauthable, omniauth_providers: [ :google_oauth2 ]

  enum :role, { buyer: 0, agent: 1, admin: 2 }

  has_many :notifications, dependent: :destroy
  belongs_to :person, optional: true

  # cria automaticamente uma Person associada após criar o User (se ainda não houver)
  after_create :ensure_person_exists
  before_validation :normalize_phone

  # Validação de telefone (opcional para existir conta; obrigatório para solicitar visita no controller)
  # Aceita dígitos com ou sem +; normalizamos removendo caracteres não numéricos.
  validates :phone, allow_blank: true, format: { with: /\A\+?\d{10,15}\z/, message: "inválido. Use somente números (DDD + número). Ex: 11987654321" }

  def display_name
    name.presence || email
  end

  def self.from_omniauth(auth)
    return nil unless auth

    provider = auth.provider
    uid = auth.uid
    info = auth.info || {}
    email = info.email.to_s.downcase
    name = info.name.presence || info.first_name || info.last_name || email

    user = where(provider: provider, uid: uid).first
    return user if user

    if email.present?
      user = find_by(email: email)
      if user
        user.update(provider: provider, uid: uid)
        return user
      end
    end

    create(
      provider: provider,
      uid: uid,
      email: email.presence || "user-#{provider}-#{uid}@example.invalid",
      name: name,
      password: Devise.friendly_token[0, 20],
      must_set_password: true
    )
  end

  private

  def normalize_phone
    return if phone.blank?
    digits = phone.gsub(/\D/, "")
    # Se começar com '55' mantemos +55, senão apenas dígitos.
    if digits.start_with?("55")
      self.phone = "+#{digits}"
    else
      self.phone = digits
    end
  end

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
