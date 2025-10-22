class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [ :create ]

  # Cria o usuário e efetua login imediato em caso de sucesso.
  def create
    build_resource(sign_up_params)
    resource.save
    yield resource if block_given?

    if resource.persisted?
      # força o sign in para garantir que o usuário fique logado imediatamente
      sign_in(resource_name, resource)
      set_flash_message! :notice, :signed_up if is_flashing_format?
      respond_with resource, location: after_sign_up_path_for(resource)
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
  end

  def after_sign_up_path_for(resource)
    root_path
  end

  def after_inactive_sign_up_path_for(resource)
    root_path
  end
end
