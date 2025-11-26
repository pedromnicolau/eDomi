class Users::PasswordsController < Devise::PasswordsController
  skip_before_action :verify_authenticity_token, only: [ :create, :update ]
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

  protected

  def after_resetting_password_path_for(resource)
    root_path
  end

  def after_sending_reset_password_instructions_path_for(resource_name)
    new_user_session_path
  end
end
