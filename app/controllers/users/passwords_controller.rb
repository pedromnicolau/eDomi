class Users::PasswordsController < Devise::PasswordsController
  skip_before_action :verify_authenticity_token, only: [ :create, :update, :set ]
  respond_to :json

  # POST /users/password
  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      render json: { message: "Email enviado com instruções para redefinir sua senha." }, status: :ok
    else
      render json: { error: resource.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end

  # PUT /users/password
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    yield resource if block_given?

    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      if Devise.sign_in_after_reset_password
        resource.after_database_authentication
        sign_in(resource_name, resource)
      end
      render json: { message: "Senha redefinida com sucesso!" }, status: :ok
    else
      render json: { error: resource.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end

  # POST /users/password/set
  # Allows first-time OAuth users to set their password without current_password
  def set
    unless current_user
      render json: { error: "Não autenticado" }, status: :unauthorized and return
    end

    unless current_user.must_set_password?
      render json: { error: "Operação não permitida" }, status: :forbidden and return
    end

    pw = params.dig(:user, :password).to_s
    pwc = params.dig(:user, :password_confirmation).to_s

    if pw.blank? || pwc.blank?
      render json: { error: "Informe a nova senha e a confirmação." }, status: :unprocessable_entity and return
    end
    if pw.length < 6
      render json: { error: "A nova senha deve ter no mínimo 6 caracteres." }, status: :unprocessable_entity and return
    end
    if pw != pwc
      render json: { error: "As senhas não coincidem." }, status: :unprocessable_entity and return
    end

    if current_user.update(password: pw, password_confirmation: pwc, must_set_password: false)
      # Re-autentica o usuário após definir a senha
      sign_in(current_user, bypass: true)
      render json: { message: "Senha definida com sucesso." }, status: :ok
    else
      render json: { error: current_user.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end

  protected

  def after_resetting_password_path_for(resource)
    root_path
  end

  def after_sending_reset_password_instructions_path_for(resource_name)
    new_user_session_path
  end
end
