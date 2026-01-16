class Person < ApplicationRecord
  has_many :addresses, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :addresses, allow_destroy: true, reject_if: :all_blank
  belongs_to :assigned_agent, class_name: "User", optional: true, foreign_key: "assigned_agent_id"
  has_one :user, dependent: :nullify

  enum :status, { prospect: 0, client: 1, inactive: 2 }
  enum :preferred_contact_method, { phone: 0, email: 1, whatsapp: 2 }
  enum :role, {
    cliente: 0,
    investidor: 1,
    proprietario: 2,
    corretor: 3,
    parceiro: 4,
    inquilino: 5,
    lead: 6
  }

  validates :name, presence: true
  validates :email, uniqueness: { case_sensitive: false }, allow_blank: true, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
  validate :phone_format

  before_validation :strip_whitespace

  def assigned_agent_name
    assigned_agent&.name
  end

  private

  def strip_whitespace
    self.name = name.strip if name.present?
    if email.present?
      self.email = email.strip.downcase
      self.email = nil if self.email.empty?
    end
  end

  def phone_format
    return if phone.blank?

    # Remove formatação
    digits = phone.gsub(/\D/, "")

    # Detecta e remove código do país
    country_code = nil
    if digits.start_with?("55") && digits.length >= 12
      # Brasil: +55
      country_code = "55"
      digits = digits[2..-1]

      # Valida formato brasileiro
      unless [ 10, 11 ].include?(digits.length)
        errors.add(:phone, "deve ter 10 ou 11 dígitos")
        return
      end

      # Valida DDD (11-99)
      ddd = digits[0..1].to_i
      unless (11..99).cover?(ddd)
        errors.add(:phone, "DDD inválido")
        return
      end

      # Celular (11 dígitos) deve começar com 9
      if digits.length == 11 && digits[2] != "9"
        errors.add(:phone, "celular deve começar com 9 após o DDD")
        return
      end

      # Fixo (10 dígitos) não pode começar com 9
      if digits.length == 10 && digits[2] == "9"
        errors.add(:phone, "telefone fixo não pode começar com 9")
      end

    elsif digits.start_with?("1") && digits.length == 11
      # EUA/Canadá: +1
      country_code = "1"
      digits = digits[1..-1]

      unless digits.length == 10
        errors.add(:phone, "deve ter 10 dígitos para EUA/Canadá")
      end

    elsif digits.start_with?("351") && digits.length == 12
      # Portugal: +351
      country_code = "351"
      digits = digits[3..-1]

      unless digits.length == 9
        errors.add(:phone, "deve ter 9 dígitos para Portugal")
      end

    elsif digits.start_with?("44") && digits.length >= 12
      # Reino Unido: +44
      country_code = "44"
      digits = digits[2..-1]

      unless [ 10, 11 ].include?(digits.length)
        errors.add(:phone, "deve ter 10 ou 11 dígitos para Reino Unido")
      end

    elsif [ 10, 11 ].include?(digits.length)
      # Sem código de país - assume Brasil
      # Valida DDD (11-99)
      ddd = digits[0..1].to_i
      unless (11..99).cover?(ddd)
        errors.add(:phone, "DDD inválido")
        return
      end

      # Celular (11 dígitos) deve começar com 9
      if digits.length == 11 && digits[2] != "9"
        errors.add(:phone, "celular deve começar com 9 após o DDD")
        return
      end

      # Fixo (10 dígitos) não pode começar com 9
      if digits.length == 10 && digits[2] == "9"
        errors.add(:phone, "telefone fixo não pode começar com 9")
      end

    else
      # Validação genérica para outros países
      unless (8..15).cover?(digits.length)
        errors.add(:phone, "formato inválido")
      end
    end
  end
end
