class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  before_action :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    # para atualização de conta
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
    # se quiser permitir na criação de conta também
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  private

  def set_locale
    I18n.locale = :'pt-BR'
  end
end
