class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  respond_to :json

  # Cria usuário (já tem)
  def create
    build_resource(sign_up_params)
    resource.save
    yield resource if block_given?

    if resource.persisted?
      sign_in(resource_name, resource)
      set_flash_message! :notice, :signed_up if is_flashing_format?
      respond_with resource, location: after_sign_up_path_for(resource)
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  # Atualiza usuário via JSON
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)

    if account_update_params[:current_password].present?
      if resource.update_with_password(account_update_params)
        render json: { name: resource.name, email: resource.email }, status: :ok
      else
        render json: { error: resource.errors.full_messages.join(', ') }, status: :unprocessable_entity
      end
    else
      if resource.update(account_update_params.except(:current_password))
        render json: { name: resource.name, email: resource.email }, status: :ok
      else
        render json: { error: resource.errors.full_messages.join(', ') }, status: :unprocessable_entity
      end
    end
  end

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :current_password, :password, :password_confirmation])
  end

  def account_update_params
    params.require(:user).permit(:name, :email, :current_password, :password, :password_confirmation)
  end
end
