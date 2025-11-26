class Users::RegistrationsController < Devise::RegistrationsController
  skip_before_action :verify_authenticity_token, only: [ :create, :update, :destroy ]

  before_action :configure_sign_up_params, only: [ :create ]
  before_action :configure_account_update_params, only: [ :update ]

  respond_to :json

  def create
    build_resource(sign_up_params)

    if resource.save
      sign_in(resource_name, resource)
      render json: {
        id: resource.id,
        email: resource.email,
        name: resource.name
      }, status: :created
    else
      render json: {
        error: resource.errors.full_messages.join(", "),
        errors: resource.errors.messages
      }, status: :unprocessable_entity
    end
  end

  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)

    if account_update_params[:current_password].present?
      if resource.update_with_password(account_update_params)
        render json: { name: resource.name, email: resource.email }, status: :ok
      else
        render json: { error: resource.errors.full_messages.join(", ") }, status: :unprocessable_entity
      end
    else
      if resource.update(account_update_params.except(:current_password))
        render json: { name: resource.name, email: resource.email }, status: :ok
      else
        render json: { error: resource.errors.full_messages.join(", ") }, status: :unprocessable_entity
      end
    end
  end

  def destroy
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)

    if params[:user] && params[:user][:current_password].present?
      unless resource.valid_password?(params[:user][:current_password])
        render json: { error: "Senha atual incorreta" }, status: :unprocessable_entity
        return
      end
    else
      render json: { error: "Senha atual é obrigatória para excluir a conta" }, status: :unprocessable_entity
      return
    end

    resource.destroy
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)

    render json: { message: "Conta excluída com sucesso" }, status: :ok
  end

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name, :current_password, :password, :password_confirmation ])
  end

  def account_update_params
    params.require(:user).permit(:name, :email, :current_password, :password, :password_confirmation)
  end
end
